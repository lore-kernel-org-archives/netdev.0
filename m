From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/7] ibmvnic: Additional updates and bug fixes
Date: Fri, 21 Apr 2017 15:38:29 -0400
Message-ID: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34386 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1041950AbdDUSdr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:33:47 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmirw104533
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:39 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29xxm39v6v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:38 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:49:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches is an additional set of updates and bug fixes to
the ibmvnic driver which applies on top of the previous set of updates
sent out on 4/19.

---

Murilo Fossa Vicentini (1):
      ibmvnic: Insert header on VLAN tagged received frame

Nathan Fontenot (4):
      ibmvnic: Only retrieve error info if present
      ibmvnic: Move initialization of the stats token to ibmvnic_open
      ibmvnic: Add set_link_state routine for setting adapter link state
      ibmvnic: Validate napi exist before disabling them

Thomas Falcon (2):
      ibmvnic: Set real number of rx queues
      ibmvnic: Free skb's in cases of failure in transmit


 drivers/net/ethernet/ibm/ibmvnic.c |  223 ++++++++++++++++++++++++++++--------
 drivers/net/ethernet/ibm/ibmvnic.h |    3 
 2 files changed, 175 insertions(+), 51 deletions(-)
