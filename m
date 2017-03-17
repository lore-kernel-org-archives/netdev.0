From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net 0/4] ibmvnic: Initialization fixes and improvements
Date: Fri, 17 Mar 2017 17:13:39 -0500
Message-ID: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55329 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751105AbdCQX3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 19:29:10 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2HM8wvh009430
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:13:52 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0b-001b2d01.pphosted.com with ESMTP id 297wd1tg0y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:13:51 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 17 Mar 2017 18:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches resolve issues with the ibmvnic initialization process.

John Allen (1):
  ibmvnic: Move login and queue negotiation into ibmvnic_open

Nathan Fontenot (3):
  ibmvnic: Move login to its own routine
  ibmvnic: Move ibmvnic adapter intialization to its own routine
  ibmvnic: Correct ibmvnic handling of device open/close

 drivers/net/ethernet/ibm/ibmvnic.c | 320 +++++++++++++++++++++----------------
 drivers/net/ethernet/ibm/ibmvnic.h |   1 +
 2 files changed, 180 insertions(+), 141 deletions(-)

-- 
2.7.4
