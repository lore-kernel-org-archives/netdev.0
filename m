From: Joe Perches <joe@perches.com>
Subject: [PATCH 34/62] drivers/net: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:39 -0700
Message-ID: <97ba916fa3822e9c8771af8a64b9a644a2bc3a06.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1137 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351AbZF1Q1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:50 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/arcnet/arc-rawmode.c       |    1 -
 drivers/net/arcnet/capmode.c           |    1 -
 drivers/net/gianfar_ethtool.c          |    2 +-
 drivers/net/ibm_newemac/core.c         |    8 ++++----
 drivers/net/ll_temac_main.c            |    2 +-
 drivers/net/ni52.c                     |    4 ++--
 drivers/net/vxge/vxge-config.h         |    2 +-
 drivers/net/vxge/vxge-main.c           |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c |    8 ++++----
 9 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 646dfc5..8ea9c75 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -123,7 +123,6 @@ static void rx(struct net_device *dev, int bufnum,
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
 
 	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
-;
 	netif_rx(skb);
 }
 
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 083e210..66bcbbb 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -149,7 +149,6 @@ static void rx(struct net_device *dev, int bufnum,
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
 
 	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
-;
 	netif_rx(skb);
 }
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index dbf06e9..1c1790d 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -293,7 +293,7 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	rxtime  = get_ictt_value(priv->rxic);
 	rxcount = get_icft_value(priv->rxic);
 	txtime  = get_ictt_value(priv->txic);
-	txcount = get_icft_value(priv->txic);;
+	txcount = get_icft_value(priv->txic);
 	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, rxtime);
 	cvals->rx_max_coalesced_frames = rxcount;
 
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index beb8421..d4531ef 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2557,13 +2557,13 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	if (emac_read_uint_prop(np, "mdio-device", &dev->mdio_ph, 0))
 		dev->mdio_ph = 0;
 	if (emac_read_uint_prop(np, "zmii-device", &dev->zmii_ph, 0))
-		dev->zmii_ph = 0;;
+		dev->zmii_ph = 0;
 	if (emac_read_uint_prop(np, "zmii-channel", &dev->zmii_port, 0))
-		dev->zmii_port = 0xffffffff;;
+		dev->zmii_port = 0xffffffff;
 	if (emac_read_uint_prop(np, "rgmii-device", &dev->rgmii_ph, 0))
-		dev->rgmii_ph = 0;;
+		dev->rgmii_ph = 0;
 	if (emac_read_uint_prop(np, "rgmii-channel", &dev->rgmii_port, 0))
-		dev->rgmii_port = 0xffffffff;;
+		dev->rgmii_port = 0xffffffff;
 	if (emac_read_uint_prop(np, "fifo-entry-size", &dev->fifo_entry_size, 0))
 		dev->fifo_entry_size = 16;
 	if (emac_read_uint_prop(np, "mal-burst-size", &dev->mal_burst_size, 0))
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 96e7248..d23e817 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -865,7 +865,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	dcrs = dcr_resource_start(np, 0);
 	if (dcrs == 0) {
 		dev_err(&op->dev, "could not get DMA register address\n");
-		goto nodev;;
+		goto nodev;
 	}
 	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
 	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 77d44a0..3679e2b 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -615,10 +615,10 @@ static int init586(struct net_device *dev)
 	/* addr_len |!src_insert |pre-len |loopback */
 	writeb(0x2e, &cfg_cmd->adr_len);
 	writeb(0x00, &cfg_cmd->priority);
-	writeb(0x60, &cfg_cmd->ifs);;
+	writeb(0x60, &cfg_cmd->ifs);
 	writeb(0x00, &cfg_cmd->time_low);
 	writeb(0xf2, &cfg_cmd->time_high);
-	writeb(0x00, &cfg_cmd->promisc);;
+	writeb(0x00, &cfg_cmd->promisc);
 	if (dev->flags & IFF_ALLMULTI) {
 		int len = ((char __iomem *)p->iscp - (char __iomem *)ptr - 8) / 6;
 		if (num_addrs > len) {
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index afbdf6f..e65a381 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -1547,7 +1547,7 @@ void vxge_hw_ring_rxd_1b_info_get(
 	rxd_info->l4_cksum_valid =
 		(u32)VXGE_HW_RING_RXD_L4_CKSUM_CORRECT_GET(rxdp->control_0);
 	rxd_info->l4_cksum =
-		(u32)VXGE_HW_RING_RXD_L4_CKSUM_GET(rxdp->control_0);;
+		(u32)VXGE_HW_RING_RXD_L4_CKSUM_GET(rxdp->control_0);
 	rxd_info->frame =
 		(u32)VXGE_HW_RING_RXD_ETHER_ENCAP_GET(rxdp->control_0);
 	rxd_info->proto =
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 6034497..fb7e6b1 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2341,7 +2341,7 @@ static int vxge_enable_msix(struct vxgedev *vdev)
 	enum vxge_hw_status status;
 	/* 0 - Tx, 1 - Rx  */
 	int tim_msix_id[4];
-	int alarm_msix_id = 0, msix_intr_vect = 0;;
+	int alarm_msix_id = 0, msix_intr_vect = 0;
 	vdev->intr_cnt = 0;
 
 	/* allocate msix vectors */
diff --git a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
index d73cf96..4cec54e 100644
--- a/drivers/net/wireless/iwmc3200wifi/rx.c
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c
@@ -779,16 +779,16 @@ static int iwm_mlme_mgt_frame(struct iwm_priv *iwm, u8 *buf,
 		    le16_to_cpu(mgt_frame->len));
 
 	if (ieee80211_is_assoc_req(mgt->frame_control)) {
-		ie = mgt->u.assoc_req.variable;;
+		ie = mgt->u.assoc_req.variable;
 		event = IWEVASSOCREQIE;
 	} else if (ieee80211_is_reassoc_req(mgt->frame_control)) {
-		ie = mgt->u.reassoc_req.variable;;
+		ie = mgt->u.reassoc_req.variable;
 		event = IWEVASSOCREQIE;
 	} else if (ieee80211_is_assoc_resp(mgt->frame_control)) {
-		ie = mgt->u.assoc_resp.variable;;
+		ie = mgt->u.assoc_resp.variable;
 		event = IWEVASSOCRESPIE;
 	} else if (ieee80211_is_reassoc_resp(mgt->frame_control)) {
-		ie = mgt->u.reassoc_resp.variable;;
+		ie = mgt->u.reassoc_resp.variable;
 		event = IWEVASSOCRESPIE;
 	} else {
 		IWM_ERR(iwm, "Unsupported management frame");
-- 
1.6.3.1.10.g659a0.dirty

