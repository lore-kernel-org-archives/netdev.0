From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 1/3 net] ibmvnic: Driver Version 1.01
Date: Mon, 17 Oct 2016 15:28:08 -0500
Message-ID: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43064 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757730AbcJQU2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:28:20 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HKQtIW016492
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:19 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2651gw3r6d-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:19 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Mon, 17 Oct 2016 14:28:19 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
        by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DD68F3E4003F
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:15 -0600 (MDT)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
        by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9HKSFQW16253190
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:28:15 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id B29EB78038
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:15 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.83.172])
        by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP id D203E78041
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:12 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increment driver version to reflect features that have
been added since release.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index bfc84c7..d244e29 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -27,7 +27,7 @@
 /**************************************************************************/
 
 #define IBMVNIC_NAME		"ibmvnic"
-#define IBMVNIC_DRIVER_VERSION	"1.0"
+#define IBMVNIC_DRIVER_VERSION	"1.01"
 #define IBMVNIC_INVALID_MAP	-1
 #define IBMVNIC_STATS_TIMEOUT	1
 /* basic structures plus 100 2k buffers */
-- 
2.7.4
