From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 0/2 net-next] ibmvnic: Correct long-term-mapped buffer error handling
Date: Wed, 21 Jun 2017 14:52:59 -0500
Message-ID: <1498074781-17565-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42448 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751038AbdFUTxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:53:10 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LJnVF9146330
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:53:09 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b7ts760qj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:53:09 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 21 Jun 2017 13:53:09 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the error-handling of long-term-mapped buffers
during adapter initialization and reset. The first patch fixes a bug
in an incorrectly defined descriptor that was keeping the return
codes from the VIO server from being properly checked. The second patch
fixes and cleans up the error-handling implementation.

Thomas Falcon (2):
  ibmvnic: Fix incorrectly defined ibmvnic_request_map_rsp structure
  ibmvnic: Fix error handling when registering long-term-mapped buffers

 drivers/net/ethernet/ibm/ibmvnic.c | 79 ++++++++++++++++----------------------
 drivers/net/ethernet/ibm/ibmvnic.h |  3 +-
 2 files changed, 36 insertions(+), 46 deletions(-)

-- 
1.8.5.6
