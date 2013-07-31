From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 11/12] tile: remove deprecated NETIF_F_LLTX flag from tile drivers
Date: Wed, 31 Jul 2013 11:05:04 -0400
Message-ID: <84b39d4b2cb68021a43285c492f2dff33c8f98b3.1375283106.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<cover.1375283104.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:31250 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760309Ab3GaPV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:21:57 -0400
In-Reply-To: <cover.1375283104.git.cmetcalf@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c  | 1 -
 drivers/net/ethernet/tile/tilepro.c | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 6696807..dc45a2f 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1959,7 +1959,6 @@ static void tile_net_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->netdev_ops = &tile_net_ops;
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
-	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_HW_CSUM;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_TSO;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index ba40ecd..874c7eb 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2257,9 +2257,6 @@ static void tile_net_setup(struct net_device *dev)
 
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
 
-	/* We want lockless xmit. */
-	dev->features |= NETIF_F_LLTX;
-
 	/* We support hardware tx checksums. */
 	dev->features |= NETIF_F_HW_CSUM;
 
-- 
1.8.3.1
