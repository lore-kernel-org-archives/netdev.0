From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 0/2] ibmvnic: Tunable parameter support
Date: Mon, 23 Oct 2017 11:30:51 -0500
Message-ID: <0a25df7c-09d4-c6ca-7441-51535c6c3dc5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40122 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751280AbdJWQa4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:30:56 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NGTsA9000705
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 12:30:56 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dsgtxt7fr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 12:30:55 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 23 Oct 2017 10:30:55 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements support for changing tunable parameters such as the
mtu, number of tx/rx queues, and number of buffers per queue via ethtool
and ifconfig.

v2: Fix conflict with Tom's recently applied TSO/SG patches

John Allen (2):
  ibmvnic: Update reset infrastructure to support tunable parameters
  ibmvnic: Fix failover error path for non-fatal resets

 drivers/net/ethernet/ibm/ibmvnic.c | 222 ++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ibm/ibmvnic.h |  24 +++-
 2 files changed, 216 insertions(+), 30 deletions(-)

-- 
1.8.3.1
