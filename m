From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v3 2/3] net/macb: Add whitespace around arithmetic operators
Date: Thu, 15 Jan 2015 15:45:15 -0600
Message-ID: <1421358316-23660-2-git-send-email-xander.huff@ni.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CAC999F@AcuExch.aculab.com>
 <1421358316-23660-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	brad.mouring@ni.com, linux-kernel@vger.kernel.org,
	cyrille.pitchen@atmel.com, Xander Huff <xander.huff@ni.com>
To: davem@davemloft.net, nicolas.ferre@atmel.com,
	david.light@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421358316-23660-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spaces should surround add, multiply, and bitshift operators.

Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index dd8c202..9edd787 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1691,7 +1691,7 @@ static int hash_get_index(__u8 *addr)
 
 	for (j = 0; j < 6; j++) {
 		for (i = 0, bitval = 0; i < 8; i++)
-			bitval ^= hash_bit_value(i*6 + j, addr);
+			bitval ^= hash_bit_value(i * 6 + j, addr);
 
 		hash_index |= (bitval << j);
 	}
@@ -1832,15 +1832,15 @@ static void gem_update_stats(struct macb *bp)
 
 	for (i = 0; i < GEM_STATS_LEN; ++i, ++p) {
 		u32 offset = gem_statistics[i].offset;
-		u64 val = __raw_readl(bp->regs+offset);
+		u64 val = __raw_readl(bp->regs + offset);
 
 		bp->ethtool_stats[i] += val;
 		*p += val;
 
 		if (offset == GEM_OCTTXL || offset == GEM_OCTRXL) {
 			/* Add GEM_OCTTXH, GEM_OCTRXH */
-			val = __raw_readl(bp->regs+offset+4);
-			bp->ethtool_stats[i] += ((u64)val)<<32;
+			val = __raw_readl(bp->regs + offset + 4);
+			bp->ethtool_stats[i] += ((u64)val) << 32;
 			*(++p) += val;
 		}
 	}
@@ -1891,7 +1891,7 @@ static void gem_get_ethtool_stats(struct net_device *dev,
 
 	bp = netdev_priv(dev);
 	gem_update_stats(bp);
-	memcpy(data, &bp->ethtool_stats, sizeof(u64)*GEM_STATS_LEN);
+	memcpy(data, &bp->ethtool_stats, sizeof(u64) * GEM_STATS_LEN);
 }
 
 static int gem_get_sset_count(struct net_device *dev, int sset)
-- 
1.9.1
