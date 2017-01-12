From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 05/12] s390/qeth: Remove QETH_IP_HEADER_SIZE
Date: Thu, 12 Jan 2017 15:48:36 +0100
Message-ID: <20170112144843.33463-6-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33472 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750994AbdALOuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:50:02 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEnku8122024
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:56 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27x7mhtsw2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:53 -0500
Received: from localhost
        by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:56 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Remove unused define QETH_IP_HEADER_SIZE.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 41e4665..774ae51 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -281,8 +281,6 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_HIGH_WATERMARK_PACK 5
 #define QETH_WATERMARK_PACK_FUZZ 1
 
-#define QETH_IP_HEADER_SIZE 40
-
 /* large receive scatter gather copy break */
 #define QETH_RX_SG_CB (PAGE_SIZE >> 1)
 #define QETH_RX_PULL_LEN 256
-- 
2.8.4
