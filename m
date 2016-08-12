From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: bfin_mac: Fix a few spelling fixes
Date: Fri, 12 Aug 2016 14:58:02 +0200
Message-ID: <1471006682-27036-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
	sudipm.mukherjee@gmail.com, a@unstable.cc, treding@nvidia.com,
	linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch respell some word badly spelled.
- Invidate instead of Invalidate
- proble instead of probe

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 38eaea1..00f9ee3 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -192,8 +192,8 @@ static int desc_list_init(struct net_device *dev)
 			goto init_error;
 
 		skb_reserve(new_skb, NET_IP_ALIGN);
-		/* Invidate the data cache of skb->data range when it is write back
-		 * cache. It will prevent overwritting the new data from DMA
+		/* Invalidate the data cache of skb->data range when it is write back
+		 * cache. It will prevent overwriting the new data from DMA
 		 */
 		blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
 					 (unsigned long)new_skb->end);
@@ -1205,7 +1205,7 @@ static void bfin_mac_rx(struct bfin_mac_local *lp)
 	}
 	/* reserve 2 bytes for RXDWA padding */
 	skb_reserve(new_skb, NET_IP_ALIGN);
-	/* Invidate the data cache of skb->data range when it is write back
+	/* Invalidate the data cache of skb->data range when it is write back
 	 * cache. It will prevent overwritting the new data from DMA
 	 */
 	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
@@ -1599,7 +1599,7 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	*(__le16 *) (&(ndev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
 
 	/* probe mac */
-	/*todo: how to proble? which is revision_register */
+	/*todo: how to probe? which is revision_register */
 	bfin_write_EMAC_ADDRLO(0x12345678);
 	if (bfin_read_EMAC_ADDRLO() != 0x12345678) {
 		dev_err(&pdev->dev, "Cannot detect Blackfin on-chip ethernet MAC controller!\n");
-- 
2.7.3
