From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 3/3] s390/lcs: remove trailing space at end of dev_err message
Date: Wed, 12 Oct 2016 12:38:51 +0200
Message-ID: <684d55b5d05a64e1b360b1d436a14774aa78fff1.1476263985.git.ursula.braun@de.ibm.com>
References: <cover.1476263985.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50291 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753548AbcJLKjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 06:39:39 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CAd0ug070582
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:02 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 261fq93nsu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:01 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 12 Oct 2016 11:38:58 +0100
In-Reply-To: <cover.1476263985.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1476263985.git.ursula.braun@de.ibm.com>
References: <cover.1476263985.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com> 

There is a trailing white space at the end of a dev_err
message that does nothing useful - remove it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/lcs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 251db0a..211b31d 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1888,7 +1888,7 @@ lcs_stop_device(struct net_device *dev)
 	rc = lcs_stopcard(card);
 	if (rc)
 		dev_err(&card->dev->dev,
-			" Shutting down the LCS device failed\n ");
+			" Shutting down the LCS device failed\n");
 	return rc;
 }
 
-- 
2.8.4
