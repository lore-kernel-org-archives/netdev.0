From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/3] ibmvnic: Enable SG and TSO feature support
Date: Tue, 17 Oct 2017 12:36:53 -0500
Message-ID: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41744 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753310AbdJQRhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:37:10 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9HHan8v063579
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:10 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dnk981vd9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:09 -0400
Received: from localhost
        by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 17 Oct 2017 11:37:08 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is fairly straightforward. The first patch enables
scatter-gather support in the ibmvnic driver. The following patch
then enables the TCP Segmentation offload feature. The final patch 
allows users to enable or disable net device features using ethtool.

Enabling SG and TSO grants a large increase in throughput with TX
speed increasing from 1Gb/s to 9Gb/s in our initial test runs.

Thomas Falcon (3):
  ibmvnic: Enable scatter-gather support
  ibmvnic: Enable TSO support
  ibmvnic: Let users change net device features

 drivers/net/ethernet/ibm/ibmvnic.c | 81 +++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ibm/ibmvnic.h |  5 +++
 2 files changed, 76 insertions(+), 10 deletions(-)

-- 
1.8.3.1
