From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Fix most checkpatch errors
Date: Mon, 26 Jul 2010 08:46:33 -0700
Message-ID: <20100726084633.36fe26d4@nehalam>
References: <4C4D8D67.7080008@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab0GZPqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 11:46:36 -0400
In-Reply-To: <4C4D8D67.7080008@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jul 2010 22:28:07 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Tidy up whitespace and formatting to reduce from
>  38 errors to 4 and 20 fewer warnings.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Please don't bother fixing the stupid checkpatch whitespace noise.
Any patch that just substitutes space for tab (or vice versa) with
no human visible impact is just stupid.

But there are some useful tidbits in there.

--- a/drivers/net/sky2.c	2010-07-26 08:40:37.554612692 -0700
+++ b/drivers/net/sky2.c	2010-07-26 08:44:18.683011839 -0700
@@ -79,7 +79,7 @@
 
 #define SKY2_EEPROM_MAGIC	0x9955aabb
 
-#define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
+#define RING_NEXT(x, s)	(((x)+1) & ((s)-1))
 
 static const u32 default_msg =
     NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK
@@ -172,7 +172,7 @@ static int gm_phy_write(struct sky2_hw *
 		udelay(10);
 	}
 
-	dev_warn(&hw->pdev->dev,"%s: phy write timeout\n", hw->dev[port]->name);
+	dev_warn(&hw->pdev->dev, "%s: phy write timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
 
 io_error:
@@ -1067,7 +1067,7 @@ static inline struct sky2_rx_le *sky2_ne
 	return le;
 }
 
-static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
+static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
 {
 	unsigned size;
 
@@ -1078,7 +1078,7 @@ static unsigned sky2_get_rx_threshold(st
 	return (size - 8) / sizeof(u32);
 }
 
-static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
+static unsigned sky2_get_rx_data_size(struct sky2_port *sky2)
 {
 	struct rx_ring_info *re;
 	unsigned size;
@@ -3014,7 +3014,7 @@ static int __devinit sky2_init(struct sk
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
-	switch(hw->chip_id) {
+	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
 		if (hw->chip_rev < CHIP_REV_YU_XL_A2)
@@ -3685,7 +3685,7 @@ static int sky2_set_mac_address(struct n
 	return 0;
 }
 
-static void inline sky2_add_filter(u8 filter[8], const u8 *addr)
+static inline void sky2_add_filter(u8 filter[8], const u8 *addr)
 {
 	u32 bit;
 
@@ -3911,7 +3911,7 @@ static int sky2_set_coalesce(struct net_
 		return -EINVAL;
 	if (ecmd->rx_max_coalesced_frames > RX_MAX_PENDING)
 		return -EINVAL;
-	if (ecmd->rx_max_coalesced_frames_irq >RX_MAX_PENDING)
+	if (ecmd->rx_max_coalesced_frames_irq > RX_MAX_PENDING)
 		return -EINVAL;
 
 	if (ecmd->tx_coalesce_usecs == 0)
@@ -4372,7 +4372,7 @@ static int sky2_debug_show(struct seq_fi
 			seq_printf(seq, "%u:", idx);
 		sop = 0;
 
-		switch(le->opcode & ~HW_OWNER) {
+		switch (le->opcode & ~HW_OWNER) {
 		case OP_ADDR64:
 			seq_printf(seq, " %#x:", a);
 			break;
@@ -4441,7 +4441,7 @@ static int sky2_device_event(struct noti
 	if (dev->netdev_ops->ndo_open != sky2_up || !sky2_debug)
 		return NOTIFY_DONE;
 
-	switch(event) {
+	switch (event) {
 	case NETDEV_CHANGENAME:
 		if (sky2->debugfs) {
 			sky2->debugfs = debugfs_rename(sky2_debug, sky2->debugfs,
@@ -4636,7 +4636,7 @@ static int __devinit sky2_test_msi(struc
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
-	init_waitqueue_head (&hw->msi_wait);
+	init_waitqueue_head(&hw->msi_wait);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
