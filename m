From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 1/3 net v2] ibmvnic: Driver Version 1.0.1
Date: Mon, 17 Oct 2016 15:56:29 -0500
Message-ID: <1476737789-17127-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56077 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932626AbcJQU4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:56:35 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HKsb95057605
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:56:34 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 265465w9d9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:56:34 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Mon, 17 Oct 2016 16:56:32 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
        by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CE2CD38C8054
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:56:29 -0400 (EDT)
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
        by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9HKuUbC6160766
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 20:56:30 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id DD17EAE034
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:56:29 -0400 (EDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.83.172])
        by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP id A2C7DAE03B
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:56:29 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increment driver version to reflect features that have
been added since release.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
Sorry about the extra noise.

v2: revise version format to be consistent with other IBM virtual drivers
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
+#define IBMVNIC_DRIVER_VERSION	"1.0.1"
 #define IBMVNIC_INVALID_MAP	-1
 #define IBMVNIC_STATS_TIMEOUT	1
 /* basic structures plus 100 2k buffers */
-- 
2.7.4
