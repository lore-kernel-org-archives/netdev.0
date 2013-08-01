From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 12/13] tile: remove deprecated NETIF_F_LLTX flag from tile drivers
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <0415298704a27a9b52ec5e82e8d7d0ed72febb0d.1375385120.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c  | 1 -
 drivers/net/ethernet/tile/tilepro.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 7302e84..0beed7e 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1963,7 +1963,6 @@ static void tile_net_setup(struct net_device *dev)
 	dev->watchdog_timeo = TILE_NET_TIMEOUT;
 	dev->mtu = 1500;
 
-	features |= NETIF_F_LLTX;
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
 	features |= NETIF_F_TSO;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index fd17af5..106be47 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2253,7 +2253,6 @@ static void tile_net_setup(struct net_device *dev)
 	dev->tx_queue_len = TILE_NET_TX_QUEUE_LEN;
 	dev->mtu = TILE_NET_MTU;
 
-	features |= NETIF_F_LLTX;
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
 
-- 
1.8.3.1
