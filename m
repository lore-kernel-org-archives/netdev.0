From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/7] drivers/net/tehuti.c: trivial checkpatch cleanups
Date: Mon, 15 Feb 2010 10:34:24 -0800
Message-ID: <864b86bd554b60128bd24fde4c34863c1eac86fd.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tehuti.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index fdf87ea..b295b92 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -419,7 +419,7 @@ static int bdx_hw_start(struct bdx_priv *priv)
 	WRITE_REG(priv, regGMAC_RXF_A, GMAC_RX_FILTER_OSEN |
 		  GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB);
 
-#define BDX_IRQ_TYPE	((priv->nic->irq_type == IRQ_MSI)?0:IRQF_SHARED)
+#define BDX_IRQ_TYPE	((priv->nic->irq_type == IRQ_MSI) ? 0 : IRQF_SHARED)
 
 	rc = request_irq(priv->pdev->irq, bdx_isr_napi, BDX_IRQ_TYPE,
 			 ndev->name, ndev);
@@ -1605,7 +1605,7 @@ static inline int bdx_tx_space(struct bdx_priv *priv)
 	fsize = f->m.rptr - f->m.wptr;
 	if (fsize <= 0)
 		fsize = f->m.memsz + fsize;
-	return (fsize);
+	return fsize;
 }
 
 /* bdx_tx_transmit - send packet to NIC
@@ -2295,13 +2295,13 @@ bdx_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecoal)
 /* Convert RX fifo size to number of pending packets */
 static inline int bdx_rx_fifo_size_to_packets(int rx_size)
 {
-	return ((FIFO_SIZE * (1 << rx_size)) / sizeof(struct rxf_desc));
+	return (FIFO_SIZE * (1 << rx_size)) / sizeof(struct rxf_desc);
 }
 
 /* Convert TX fifo size to number of pending packets */
 static inline int bdx_tx_fifo_size_to_packets(int tx_size)
 {
-	return ((FIFO_SIZE * (1 << tx_size)) / BDX_TXF_DESC_SZ);
+	return (FIFO_SIZE * (1 << tx_size)) / BDX_TXF_DESC_SZ;
 }
 
 /*
@@ -2393,10 +2393,10 @@ static int bdx_get_sset_count(struct net_device *netdev, int stringset)
 	case ETH_SS_STATS:
 		BDX_ASSERT(ARRAY_SIZE(bdx_stat_names)
 			   != sizeof(struct bdx_stats) / sizeof(u64));
-		return ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0);
-	default:
-		return -EINVAL;
+		return (priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0;
 	}
+
+	return -EINVAL;
 }
 
 /*
-- 
1.7.0.14.g7e948
