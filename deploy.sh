#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    echo "deploy ${VERSION} to pr namespace, using HOCS-CASEWORK_PR drone secret"
    export KUBE_TOKEN=${HOCS-CASEWORK_PR}
else
    if [[ ${ENVIRONMENT} == "test" ]] ; then
        echo "deploy ${VERSION} to test namespace, using HOCS-CASEWORK_QA drone secret"
        export KUBE_TOKEN=${HOCS-CASEWORK_QA}
    else
        echo "deploy ${VERSION} to dev namespace, using HOCS-CASEWORK_DEV drone secret"
        export KUBE_TOKEN=${HOCS-CASEWORK_DEV}
    fi
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

cd kd

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f deployment.yaml \
    -f service.yaml