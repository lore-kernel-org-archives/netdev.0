From: akpm@linux-foundation.org
Subject: [patch 06/11] dm9000-use-delayed-work-to-update-mii-phy-state-fix
Date: Wed, 14 May 2008 16:20:12 -0700
Message-ID: <200805142320.m4ENKDWX026626@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ben-linux@fluff.org, enrico.scholz@sigma-chemnitz.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56358 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751839AbYENXWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

use cancel_delayed_work_sync()

Cc: Ben Dooks <ben-linux@fluff.org>
Cc: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/dm9000.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/dm9000.c~dm9000-use-delayed-work-to-update-mii-phy-state-fix drivers/net/dm9000.c
--- a/drivers/net/dm9000.c~dm9000-use-delayed-work-to-update-mii-phy-state-fix
+++ a/drivers/net/dm9000.c
@@ -903,7 +903,7 @@ dm9000_stop(struct net_device *ndev)
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
-	cancel_delayed_work(&db->phy_poll);
+	cancel_delayed_work_sync(&db->phy_poll);
 
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
_
