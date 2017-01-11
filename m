From: Joe Perches <joe@perches.com>
Subject: [PATCH] tilepro: Fix non-void return from void function
Date: Wed, 11 Jan 2017 14:52:20 -0800
Message-ID: <fb9071cb1b950cd3328d838f511231d11d07990c.1484175023.git.joe@perches.com>
Cc: stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit bc1f44709cf2 ("net: make ndo_get_stats64 a void function")
mistakenly used a return value for this void conversion.

Fix it.

Signed-off-by: Joe Perches <joe@perches.com>
cc: stephen hemminger <stephen@networkplumber.org>
---
 drivers/net/ethernet/tile/tilepro.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 30cfea62a356..44f153713791 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2090,12 +2090,8 @@ static void tile_net_get_stats64(struct net_device *dev,
 	stats->tx_bytes   = tx_bytes;
 	stats->rx_errors  = rx_errors;
 	stats->rx_dropped = rx_dropped;
-
-	return stats;
 }
 
-
-
 /*
  * Change the Ethernet Address of the NIC.
  *
-- 
2.10.0.rc2.1.g053435c
