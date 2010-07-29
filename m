From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Code style fixes
Date: Thu, 29 Jul 2010 22:34:52 +0900
Message-ID: <4C51837C.4020505@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39359 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab0G2Nqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 09:46:49 -0400
Received: by pzk26 with SMTP id 26so95074pzk.19
        for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 06:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix selected style problems reported by checkpatch.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 8b85c02..8723e3d 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -79,7 +79,7 @@
 
 #define SKY2_EEPROM_MAGIC	0x9955aabb
 
-#define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
+#define RING_NEXT(x, s)	(((x)+1) & ((s)-1))
 
 static const u32 default_msg =
     NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK
@@ -172,7 +172,7 @@ static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 		udelay(10);
 	}
 
-	dev_warn(&hw->pdev->dev,"%s: phy write timeout\n", hw->dev[port]->name);
+	dev_warn(&hw->pdev->dev, "%s: phy write timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
 
 io_error:
@@ -1078,7 +1078,7 @@ static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
 	return le;
 }
 
-static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
+static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
 {
 	unsigned size;
 
@@ -1089,7 +1089,7 @@ static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
 	return (size - 8) / sizeof(u32);
 }
 
-static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
+static unsigned sky2_get_rx_data_size(struct sky2_port *sky2)
 {
 	struct rx_ring_info *re;
 	unsigned size;
@@ -1113,7 +1113,7 @@ static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
 }
 
 /* Build description to hardware for one receive segment */
-static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
+static void sky2_rx_add(struct sky2_port *sky2, u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
@@ -3019,7 +3019,7 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
-	switch(hw->chip_id) {
+	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
 		if (hw->chip_rev < CHIP_REV_YU_XL_A2)
@@ -3690,7 +3690,7 @@ static int sky2_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static void inline sky2_add_filter(u8 filter[8], const u8 *addr)
+static inline void sky2_add_filter(u8 filter[8], const u8 *addr)
 {
 	u32 bit;
 
@@ -3916,7 +3916,7 @@ static int sky2_set_coalesce(struct net_device *dev,
 		return -EINVAL;
 	if (ecmd->rx_max_coalesced_frames > RX_MAX_PENDING)
 		return -EINVAL;
-	if (ecmd->rx_max_coalesced_frames_irq >RX_MAX_PENDING)
+	if (ecmd->rx_max_coalesced_frames_irq > RX_MAX_PENDING)
 		return -EINVAL;
 
 	if (ecmd->tx_coalesce_usecs == 0)
@@ -4381,7 +4381,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 			seq_printf(seq, "%u:", idx);
 		sop = 0;
 
-		switch(le->opcode & ~HW_OWNER) {
+		switch (le->opcode & ~HW_OWNER) {
 		case OP_ADDR64:
 			seq_printf(seq, " %#x:", a);
 			break;
@@ -4450,7 +4450,7 @@ static int sky2_device_event(struct notifier_block *unused,
 	if (dev->netdev_ops->ndo_open != sky2_up || !sky2_debug)
 		return NOTIFY_DONE;
 
-	switch(event) {
+	switch (event) {
 	case NETDEV_CHANGENAME:
 		if (sky2->debugfs) {
 			sky2->debugfs = debugfs_rename(sky2_debug, sky2->debugfs,
@@ -4645,7 +4645,7 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
-	init_waitqueue_head (&hw->msi_wait);
+	init_waitqueue_head(&hw->msi_wait);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
@@ -4762,7 +4762,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	 * this driver uses software swapping.
 	 */
 	reg &= ~PCI_REV_DESC;
-	err = pci_write_config_dword(pdev,PCI_DEV_REG2, reg);
+	err = pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
 	if (err) {
 		dev_err(&pdev->dev, "PCI write config failed\n");
 		goto err_out_free_regions;
-- 
1.5.6.5

