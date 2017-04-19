From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/10] ibmvnic: Updates and bug fixes
Date: Wed, 19 Apr 2017 13:44:22 -0400
Message-ID: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40988 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934567AbdDSNz0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:55:26 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDriYH021665
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:24 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29x75neg8a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:24 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches is a series of updates to remove some unneeded
and unused code in the driver as well as bug fixes for the
ibmvnic driver.

---

Brian King (4):
      ibmvnic: Unmap longer term buffer before free
      ibmvnic: Fixup atomic API usage
      ibmvnic: Do not disable IRQ after scheduling tasklet
      ibmvnic: Disable irq prior to close

Murilo Fossa Vicentini (1):
      ibmvnic: Fix ibmvnic_change_mac_addr struct format

Nathan Fontenot (4):
      ibmvnic: Remove inflight list
      ibmvnic: Correct crq and resource releasing
      ibmvnic: Allocate zero-filled memory for sub crqs
      ibmvnic: Remove unused bouce buffer

Thomas Falcon (1):
      ibmvnic: Report errors when failing to release sub-crqs


 drivers/net/ethernet/ibm/ibmvnic.c |  223 ++++++++++--------------------------
 drivers/net/ethernet/ibm/ibmvnic.h |   15 --
 2 files changed, 61 insertions(+), 177 deletions(-)
