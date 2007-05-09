From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 13/17] sky2: whitespace cleanups
Date: Tue, 08 May 2007 20:50:02 -0700
Message-ID: <20070509035030.494393573@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:53378 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033254AbXEIEEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:10 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-whitespace.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of extra whitespace and break long lines. Add white space around
operators.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/sky2.c |  135 ++++++++++++++++++++++++++---------------------------
 1 file changed, 67 insertions(+), 68 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:54:56.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 15:57:58.000000000 -0700
@@ -60,7 +60,7 @@
  * similar to Tigon3.
  */
 
-#define RX_LE_SIZE	    	1024
+#define RX_LE_SIZE		1024
 #define RX_LE_BYTES		(RX_LE_SIZE*sizeof(struct sky2_rx_le))
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
@@ -105,7 +105,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) },	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B03) },	/* DGE-550T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) }, /* 88E8021 */
@@ -145,7 +145,7 @@ static const u32 portirq_msk[] = { Y2_IS
 /* This driver supports yukon2 chipset only */
 static const char *yukon2_name[] = {
 	"XL",		/* 0xb3 */
-	"EC Ultra", 	/* 0xb4 */
+	"EC Ultra",	/* 0xb4 */
 	"Extreme",	/* 0xb5 */
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
@@ -170,7 +170,7 @@ static int gm_phy_write(struct sky2_hw *
 	return -ETIMEDOUT;
 }
 
-static int __gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg, u16 *val)
+static int __gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg, u16 * val)
 {
 	int i;
 
@@ -194,11 +194,11 @@ static u16 gm_phy_read(struct sky2_hw *h
 	u16 v;
 
 	if (__gm_phy_read(hw, port, reg, &v) != 0)
-		printk(KERN_WARNING PFX "%s: phy read timeout\n", hw->dev[port]->name);
+		printk(KERN_WARNING PFX "%s: phy read timeout\n",
+		       hw->dev[port]->name);
 	return v;
 }
 
-
 static void sky2_power_on(struct sky2_hw *hw)
 {
 	/* switch power to VCC (WA for VAUX problem) */
@@ -289,7 +289,6 @@ static const u16 gm_fc_disable[] = {
 	[FC_BOTH] = 0,
 };
 
-
 static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
@@ -353,7 +352,7 @@ static void sky2_phy_init(struct sky2_hw
 		ctrl |= PHY_M_MAC_MODE_SEL(PHY_M_MAC_MD_1000BX);
 		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 
-		if (hw->pmd_type  == 'P') {
+		if (hw->pmd_type == 'P') {
 			/* select page 1 to access Fiber registers */
 			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 1);
 
@@ -421,7 +420,7 @@ static void sky2_phy_init(struct sky2_hw
 		} else if (sky2->speed < SPEED_1000)
 			sky2->flow_mode = FC_NONE;
 
- 		reg |= gm_fc_disable[sky2->flow_mode];
+		reg |= gm_fc_disable[sky2->flow_mode];
 
 		/* Forward pause packets to GMAC? */
 		if (sky2->flow_mode & FC_RX)
@@ -607,8 +606,8 @@ static void sky2_wol_init(struct sky2_po
 
 	/* Set GMAC to no flow control and auto update for speed/duplex */
 	gma_write16(hw, port, GM_GP_CTRL,
-		    GM_GPCR_FC_TX_DIS|GM_GPCR_TX_ENA|GM_GPCR_RX_ENA|
-		    GM_GPCR_DUP_FULL|GM_GPCR_FC_RX_DIS|GM_GPCR_AU_FCT_DIS);
+		    GM_GPCR_FC_TX_DIS | GM_GPCR_TX_ENA | GM_GPCR_RX_ENA |
+		    GM_GPCR_DUP_FULL | GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS);
 
 	/* Set WOL address */
 	memcpy_toio(hw->regs + WOL_REGS(port, WOL_MAC_ADDR),
@@ -618,16 +617,18 @@ static void sky2_wol_init(struct sky2_po
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), WOL_CTL_CLEAR_RESULT);
 	ctrl = 0;
 	if (sky2->wol & WAKE_PHY)
-		ctrl |= WOL_CTL_ENA_PME_ON_LINK_CHG|WOL_CTL_ENA_LINK_CHG_UNIT;
+		ctrl |= WOL_CTL_ENA_PME_ON_LINK_CHG | WOL_CTL_ENA_LINK_CHG_UNIT;
 	else
-		ctrl |= WOL_CTL_DIS_PME_ON_LINK_CHG|WOL_CTL_DIS_LINK_CHG_UNIT;
+		ctrl |= WOL_CTL_DIS_PME_ON_LINK_CHG | WOL_CTL_DIS_LINK_CHG_UNIT;
 
 	if (sky2->wol & WAKE_MAGIC)
-		ctrl |= WOL_CTL_ENA_PME_ON_MAGIC_PKT|WOL_CTL_ENA_MAGIC_PKT_UNIT;
+		ctrl |=
+		    WOL_CTL_ENA_PME_ON_MAGIC_PKT | WOL_CTL_ENA_MAGIC_PKT_UNIT;
 	else
-		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;;
+		ctrl |=
+		    WOL_CTL_DIS_PME_ON_MAGIC_PKT | WOL_CTL_DIS_MAGIC_PKT_UNIT;;
 
-	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
+	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN | WOL_CTL_DIS_PATTERN_UNIT;
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
@@ -648,7 +649,7 @@ static void sky2_mac_init(struct sky2_hw
 	const u8 *addr = hw->dev[port]->dev_addr;
 
 	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR|GPC_ENA_PAUSE);
+	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR | GPC_ENA_PAUSE);
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
@@ -727,15 +728,16 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
 
 	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF+1);
+	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF + 1);
 
 	/* Configure Tx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
-		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
-		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U
+	    || hw->chip_id == CHIP_ID_YUKON_EX) {
+		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768 / 8);
+		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024 / 8);
 
 		/* set Tx GMAC FIFO Almost Empty Threshold */
 		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
@@ -757,8 +759,8 @@ static void sky2_ramset(struct sky2_hw *
 	u32 end;
 
 	/* convert from K bytes to qwords used for hw register */
-	start *= 1024/8;
-	space *= 1024/8;
+	start *= 1024 / 8;
+	space *= 1024 / 8;
 	end = start + space - 1;
 
 	sky2_write8(hw, RB_ADDR(q, RB_CTRL), RB_RST_CLR);
@@ -768,18 +770,18 @@ static void sky2_ramset(struct sky2_hw *
 	sky2_write32(hw, RB_ADDR(q, RB_RP), start);
 
 	if (q == Q_R1 || q == Q_R2) {
-		u32 tp = space - space/4;
+		u32 tp = space - space / 4;
 
 		/* On receive queue's set the thresholds
 		 * give receiver priority when > 3/4 full
 		 * send pause when down to 2K
 		 */
 		sky2_write32(hw, RB_ADDR(q, RB_RX_UTHP), tp);
-		sky2_write32(hw, RB_ADDR(q, RB_RX_LTHP), space/2);
+		sky2_write32(hw, RB_ADDR(q, RB_RX_LTHP), space / 2);
 
-		tp = space - 2048/8;
+		tp = space - 2048 / 8;
 		sky2_write32(hw, RB_ADDR(q, RB_RX_UTPP), tp);
-		sky2_write32(hw, RB_ADDR(q, RB_RX_LTPP), space/4);
+		sky2_write32(hw, RB_ADDR(q, RB_RX_LTPP), space / 4);
 	} else {
 		/* Enable store & forward on Tx queue's because
 		 * Tx FIFO is only 1K on Yukon
@@ -797,19 +799,19 @@ static void sky2_qset(struct sky2_hw *hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_RESET);
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_OPER_INIT);
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_FIFO_OP_ON);
-	sky2_write32(hw, Q_ADDR(q, Q_WM),  BMU_WM_DEFAULT);
+	sky2_write32(hw, Q_ADDR(q, Q_WM), BMU_WM_DEFAULT);
 }
 
 /* Setup prefetch unit registers. This is the interface between
  * hardware and driver list elements
  */
 static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
-				      u64 addr, u32 last)
+			       u64 addr, u32 last)
 {
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_RST_CLR);
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_HI), addr >> 32);
-	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_LO), (u32) addr);
+	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_LO), (u32)addr);
 	sky2_write16(hw, Y2_QADDR(qaddr, PREF_UNIT_LAST_IDX), last);
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_OP_ON);
 
@@ -842,7 +844,6 @@ static inline void sky2_put_idx(struct s
 	mmiowb();
 }
 
-
 static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
 {
 	struct sky2_rx_le *le = sky2->rx_le + sky2->rx_put;
@@ -858,7 +859,7 @@ static inline u32 high32(dma_addr_t a)
 }
 
 /* Build description to hardware for one receive segment */
-static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
+static void sky2_rx_add(struct sky2_port *sky2, u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
@@ -889,7 +890,6 @@ static void sky2_rx_submit(struct sky2_p
 		sky2_rx_add(sky2, OP_BUFFER, re->frag_addr[i], PAGE_SIZE);
 }
 
-
 static void sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 			    unsigned size)
 {
@@ -1082,7 +1082,7 @@ static struct sk_buff *sky2_rx_alloc(str
 	if (!skb)
 		goto nomem;
 
-	p = (unsigned long) skb->data;
+	p = (unsigned long)skb->data;
 	skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
@@ -1209,21 +1209,21 @@ static int sky2_up(struct net_device *de
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
 	/*
- 	 * On dual port PCI-X card, there is an problem where status
+	 * On dual port PCI-X card, there is an problem where status
 	 * can be received out of order due to split transactions
 	 */
 	if (otherdev && netif_running(otherdev) &&
- 	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
- 		struct sky2_port *osky2 = netdev_priv(otherdev);
- 		u16 cmd;
+	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+		struct sky2_port *osky2 = netdev_priv(otherdev);
+		u16 cmd;
 
 		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
- 		cmd &= ~PCI_X_CMD_MAX_SPLIT;
- 		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
+		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
 
- 		sky2->rx_csum = 0;
- 		osky2->rx_csum = 0;
- 	}
+		sky2->rx_csum = 0;
+		osky2->rx_csum = 0;
+	}
 
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
@@ -1267,7 +1267,7 @@ static int sky2_up(struct net_device *de
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
-			rxspace = 8 + (2*(ramsize - 16))/3;
+			rxspace = 8 + (2 * (ramsize - 16)) / 3;
 
 		sky2_ramset(hw, rxqaddr[port], 0, rxspace);
 		sky2_ramset(hw, txqaddr[port], rxspace, ramsize - rxspace);
@@ -1365,8 +1365,8 @@ static int sky2_xmit_frame(struct sk_buf
 	u16 mss;
 	u8 ctrl;
 
- 	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
-  		return NETDEV_TX_BUSY;
+	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
+		return NETDEV_TX_BUSY;
 
 	if (unlikely(netif_msg_tx_queued(sky2)))
 		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
@@ -1387,7 +1387,7 @@ static int sky2_xmit_frame(struct sk_buf
 	/* Check for TCP Segmentation Offload */
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss != 0) {
-		mss += tcp_optlen(skb); /* TCP options */
+		mss += tcp_optlen(skb);	/* TCP options */
 		mss += ip_hdrlen(skb) + sizeof(struct tcphdr);
 		mss += ETH_HLEN;
 
@@ -1406,7 +1406,7 @@ static int sky2_xmit_frame(struct sk_buf
 		if (!le) {
 			le = get_tx_le(sky2);
 			le->addr = 0;
-			le->opcode = OP_VLAN|HW_OWNER;
+			le->opcode = OP_VLAN | HW_OWNER;
 		} else
 			le->opcode |= OP_VLAN;
 		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
@@ -1419,7 +1419,7 @@ static int sky2_xmit_frame(struct sk_buf
 		const unsigned offset = skb_transport_offset(skb);
 		u32 tcpsum;
 
-		tcpsum = offset << 16;		/* sum start */
+		tcpsum = offset << 16;	/* sum start */
 		tcpsum |= offset + skb->csum_offset;	/* sum write */
 
 		ctrl = CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
@@ -1504,7 +1504,7 @@ static void sky2_tx_complete(struct sky2
 		struct sky2_tx_le *le = sky2->tx_le + idx;
 		struct tx_ring_info *re = sky2->tx_ring + idx;
 
-		switch(le->opcode & ~HW_OWNER) {
+		switch (le->opcode & ~HW_OWNER) {
 		case OP_LARGESEND:
 		case OP_PACKET:
 			pci_unmap_single(pdev,
@@ -1695,7 +1695,7 @@ static void sky2_link_up(struct sky2_por
 		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
 
-		switch(sky2->speed) {
+		switch (sky2->speed) {
 		case SPEED_10:
 			led |= PHY_M_LEDC_INIT_CTRL(7);
 			break;
@@ -1994,7 +1994,7 @@ static void skb_put_frags(struct sk_buff
 			__free_page(frag->page);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
-			size = min(length, (unsigned) PAGE_SIZE);
+			size = min(length, (unsigned)PAGE_SIZE);
 
 			frag->size = size;
 			skb->data_len += size;
@@ -2041,7 +2041,7 @@ static struct sk_buff *receive_new(struc
 static struct sk_buff *sky2_receive(struct net_device *dev,
 				    u16 length, u32 status)
 {
- 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_port *sky2 = netdev_priv(dev);
 	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
 
@@ -2111,7 +2111,7 @@ static int sky2_status_intr(struct sky2_
 	rmb();
 
 	while (hw->st_idx != hwidx) {
-		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
+		struct sky2_status_le *le = hw->st_le + hw->st_idx;
 		struct net_device *dev;
 		struct sk_buff *skb;
 		u32 status;
@@ -2384,7 +2384,7 @@ static inline void sky2_idle_start(struc
 
 static void sky2_idle(unsigned long arg)
 {
-	struct sky2_hw *hw = (struct sky2_hw *) arg;
+	struct sky2_hw *hw = (struct sky2_hw *)arg;
 	struct net_device *dev = hw->dev[0];
 
 	if (__netif_rx_schedule_prep(dev))
@@ -2876,12 +2876,12 @@ static const struct sky2_stat {
 	{ "rx_mac_pause",  GM_RXF_MPAUSE },
 	{ "collisions",    GM_TXF_COL },
 	{ "late_collision",GM_TXF_LAT_COL },
-	{ "aborted", 	   GM_TXF_ABO_COL },
+	{ "aborted",	   GM_TXF_ABO_COL },
 	{ "single_collisions", GM_TXF_SNG_COL },
 	{ "multi_collisions", GM_TXF_MUL_COL },
 
 	{ "rx_short",      GM_RXF_SHT },
-	{ "rx_runt", 	   GM_RXE_FRAG },
+	{ "rx_runt",	   GM_RXE_FRAG },
 	{ "rx_64_byte_packets", GM_RXF_64B },
 	{ "rx_65_to_127_byte_packets", GM_RXF_127B },
 	{ "rx_128_to_255_byte_packets", GM_RXF_255B },
@@ -3019,7 +3019,7 @@ static int sky2_set_mac_address(struct n
 	return 0;
 }
 
-static void inline sky2_add_filter(u8 filter[8], const u8 *addr)
+static void inline sky2_add_filter(u8 filter[8], const u8 * addr)
 {
 	u32 bit;
 
@@ -3096,7 +3096,7 @@ static void sky2_led(struct sky2_hw *hw,
 
 	default:
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, 0);
-		gm_phy_write(hw, port, PHY_MARV_LED_OVER, 
+		gm_phy_write(hw, port, PHY_MARV_LED_OVER,
 			     on ? PHY_M_LED_ALL : 0);
 	}
 }
@@ -3239,11 +3239,11 @@ static int sky2_set_coalesce(struct net_
 	    ecmd->rx_coalesce_usecs_irq > tmax)
 		return -EINVAL;
 
-	if (ecmd->tx_max_coalesced_frames >= TX_RING_SIZE-1)
+	if (ecmd->tx_max_coalesced_frames >= TX_RING_SIZE - 1)
 		return -EINVAL;
 	if (ecmd->rx_max_coalesced_frames > RX_MAX_PENDING)
 		return -EINVAL;
-	if (ecmd->rx_max_coalesced_frames_irq >RX_MAX_PENDING)
+	if (ecmd->rx_max_coalesced_frames_irq > RX_MAX_PENDING)
 		return -EINVAL;
 
 	if (ecmd->tx_coalesce_usecs == 0)
@@ -3367,7 +3367,6 @@ static int sky2_set_tx_csum(struct net_d
 	return ethtool_op_set_tx_csum(dev, data);
 }
 
-
 static int sky2_set_tso(struct net_device *dev, u32 data)
 {
 	if (data && no_tx_offload(dev))
@@ -3527,7 +3526,7 @@ static int __devinit sky2_test_msi(struc
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
-	init_waitqueue_head (&hw->msi_wait);
+	init_waitqueue_head(&hw->msi_wait);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
@@ -3540,7 +3539,7 @@ static int __devinit sky2_test_msi(struc
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
 	sky2_read8(hw, B0_CTST);
 
-	wait_event_timeout(hw->msi_wait, hw->msi, HZ/10);
+	wait_event_timeout(hw->msi_wait, hw->msi, HZ / 10);
 
 	if (!hw->msi) {
 		/* MSI test failed, go back to INTx mode */
@@ -3675,10 +3674,10 @@ static int __devinit sky2_probe(struct p
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
 		if (err == -EOPNOTSUPP)
- 			pci_disable_msi(pdev);
+			pci_disable_msi(pdev);
 		else if (err)
 			goto err_out_free_netdev;
- 	}
+	}
 
 	err = register_netdev(dev);
 	if (err) {
@@ -3686,7 +3685,7 @@ static int __devinit sky2_probe(struct p
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq,  sky2_intr, hw->msi ? 0 : IRQF_SHARED,
+	err = request_irq(pdev->irq, sky2_intr, hw->msi ? 0 : IRQF_SHARED,
 			  dev->name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
@@ -3711,7 +3710,7 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long)hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
 	sky2_idle_start(hw);

--

