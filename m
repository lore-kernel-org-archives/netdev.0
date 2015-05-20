From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/12] spider_net: Use DECLARE_BITMAP
Date: Tue, 19 May 2015 18:37:55 -0700
Message-ID: <07f70eba606c0bd11cba37f50dfb62e7a9e0c898.1432085659.git.joe@perches.com>
References: <cover.1432085659.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1432085659.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the generic mechanism to declare a bitmap instead of unsigned long.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/toshiba/spider_net.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 8e9371a..3c54a2c 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -604,8 +604,7 @@ spider_net_set_multi(struct net_device *netdev)
 	int i;
 	u32 reg;
 	struct spider_net_card *card = netdev_priv(netdev);
-	unsigned long bitmask[SPIDER_NET_MULTICAST_HASHES / BITS_PER_LONG] =
-		{0, };
+	DECLARE_BITMAP(bitmask, SPIDER_NET_MULTICAST_HASHES) = {};
 
 	spider_net_set_promisc(card);
 
-- 
2.1.2
