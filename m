From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2] net: tile: fix unused variable warning
Date: Mon, 16 Jun 2014 13:14:05 -0400
Message-ID: <201406161816.s5GIGptF028053@farm-0039.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'i' is unused in tile_net_dev_init() after commit d581ebf5a1f
("net: tile: Use helpers from linux/etherdevice.h to check/set MAC").

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v2: includes previous commit's summary line as suggested by Sergei Shtylyov.

 drivers/net/ethernet/tile/tilegx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 14389f841d43..4c70360967c2 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2191,7 +2191,6 @@ static void tile_net_setup(struct net_device *dev)
 static void tile_net_dev_init(const char *name, const uint8_t *mac)
 {
 	int ret;
-	int i;
 	struct net_device *dev;
 	struct tile_net_priv *priv;
 
-- 
1.8.3.1
