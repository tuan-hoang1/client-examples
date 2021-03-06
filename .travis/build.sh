#!/usr/bin/env bash

set -e

export PULL_REQUEST=${PULL_REQUEST:-true}
export BRANCH=${BRANCH:-master}
export TAG=${TAG:-latest}
export DOCKER_ORG=${DOCKER_ORG:-strimzici}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export DOCKER_TAG=$COMMIT

make build

if [ "$PULL_REQUEST" != "false" ] ; then
  make docker_build
  echo "Building PR: Nothing to push"
else
  if [ "$TAG" = "latest" ] && [ "$BRANCH" != "master" ]; then
    make docker_build
    echo "Not in tag or master branch: Nothing to push"
  else
    export DOCKER_TAG=$TAG
    make docker_build

    echo "In tag or master branch: Pushing images"
    docker login -u $QUAY_USER -p $QUAY_PASS $DOCKER_REGISTRY
    make docker_push
  fi
  
fi
