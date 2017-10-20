From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/2] ibmvnic: Tunable parameter support
Date: Fri, 20 Oct 2017 16:00:54 -0500
Message-ID: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41454 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752005AbdJTVA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:00:59 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KKws3b117344
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:00:58 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dqmaqtrdj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:00:58 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 20 Oct 2017 17:00:57 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements support for changing tunable parameters such as the
mtu, number of tx/rx queues, and number of buffers per queue via ethtool
and ifconfig.

John Allen (2):
  ibmvnic: Update reset infrastructure to support tunable parameters
  ibmvnic: Fix failover error path for non-fatal resets

 drivers/net/ethernet/ibm/ibmvnic.c | 222 ++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ibm/ibmvnic.h |  24 +++-
 2 files changed, 216 insertions(+), 30 deletions(-)

-- 
1.8.3.1
