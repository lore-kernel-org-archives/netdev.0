From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 3/3] tilegx net: use eth_hw_addr_random(), not random_ether_addr()
Date: Wed, 18 Jul 2012 12:53:03 -0400
Message-ID: <201207181653.q6IGrwxw007622@lab-41.internal.tilera.com>
References: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index f78effc..4e2a162 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1851,7 +1851,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 		memcpy(dev->dev_addr, mac, 6);
 		dev->addr_len = 6;
 	} else {
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	}
 
 	/* Register the network device. */
-- 
1.7.10.3
