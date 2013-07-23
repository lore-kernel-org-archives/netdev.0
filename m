From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 13/13] tile: remove deprecated NETIF_F_LLTX flag from tile drivers
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <35bc25d89bd6750ee1d9dfe589107805068d74b4.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:23566 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934437Ab3GWUWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:22:03 -0400
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c  | 1 -
 drivers/net/ethernet/tile/tilepro.c | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index e4a0994..dd55c2c 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2019,7 +2019,6 @@ static void tile_net_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
-	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_HW_CSUM;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_TSO;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 7182855..303c1ec 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2224,9 +2224,6 @@ static void tile_net_setup(struct net_device *dev)
 
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
 
-	/* We want lockless xmit. */
-	dev->features |= NETIF_F_LLTX;
-
 	/* We support hardware tx checksums. */
 	dev->features |= NETIF_F_HW_CSUM;
 
-- 
1.8.3.1
