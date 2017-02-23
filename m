From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] forcedeth: Remove return from a void function
Date: Thu, 23 Feb 2017 03:22:49 -0500
Message-ID: <1487838169-26207-1-git-send-email-yanjun.zhu@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:22105 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdBWIYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 03:24:46 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1N8ONTx009924
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 08:24:24 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a void function, it is not necessary to append a return statement in it.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 3913f07..a992595 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3274,8 +3274,6 @@ static void nv_force_linkspeed(struct net_device *dev, int speed, int duplex)
 	pci_push(base);
 	writel(np->linkspeed, base + NvRegLinkSpeed);
 	pci_push(base);
-
-	return;
 }
 
 /**
-- 
2.7.4
