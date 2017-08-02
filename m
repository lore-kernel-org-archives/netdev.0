From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/4] ibmvnic: Improve ethtool functionality
Date: Wed, 2 Aug 2017 16:42:49 -0500
Message-ID: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52633 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750850AbdHBVnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 17:43:01 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72LfubB098597
        for <netdev@vger.kernel.org>; Wed, 2 Aug 2017 17:43:01 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c3hrwy3xf-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 17:43:00 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Wed, 2 Aug 2017 17:42:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series improves ibmvnic ethtool functionality by adding support
for ethtool -l and -g options, correcting existing statistics reporting,
and augmenting the existing statistics with counters for each tx and rx
queue.

John Allen (4):
  ibmvnic: Implement per-queue statistics reporting
  ibmvnic: Convert vnic server reported statistics to cpu endian
  ibmvnic: Implement .get_ringparam
  ibmvnic: Implement .get_channels

 drivers/net/ethernet/ibm/ibmvnic.c | 115 ++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/ibm/ibmvnic.h |  17 ++++++
 2 files changed, 125 insertions(+), 7 deletions(-)

-- 
2.12.3
