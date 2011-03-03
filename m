From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] bonding: remove the unused dummy functions when net poll controller isn't enabled
Date: Thu,  3 Mar 2011 12:26:21 +0800
Message-ID: <1299126381-9338-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55237 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081Ab1CCE1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 23:27:01 -0500
Received: by yxs7 with SMTP id 7so227804yxs.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 20:27:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two functions are only used when net poll controller is enabled.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/bonding/bond_main.c |    8 --------
 1 file changed, 8 deletions(-)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0592e6d..912b416 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1380,14 +1380,6 @@ static inline void slave_disable_netpoll(struct slave *slave)
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
 }
-static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
-{
-	return 0;
-}
-static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
-{
-	return NULL;
-}
 #endif
 
 /*---------------------------------- IOCTL ----------------------------------*/
