From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 11/13] tg3: Remove excessive parenthesis
Date: Thu, 19 May 2011 15:12:54 -0700
Message-ID: <1305843176-32358-12-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1128 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934963Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some excessive parenthesizing.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5bf2ce1..eb8dc7b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -553,7 +553,7 @@ static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 {
 	unsigned long flags;
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) &&
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 &&
 	    (off >= NIC_SRAM_STATS_BLK) && (off < NIC_SRAM_TX_BUFFER_DESC))
 		return;
 
@@ -578,7 +578,7 @@ static void tg3_read_mem(struct tg3 *tp, u32 off, u32 *val)
 {
 	unsigned long flags;
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) &&
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 &&
 	    (off >= NIC_SRAM_STATS_BLK) && (off < NIC_SRAM_TX_BUFFER_DESC)) {
 		*val = 0;
 		return;
@@ -2806,7 +2806,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			    CLOCK_CTRL_PWRDOWN_PLL133, 40);
 	} else if (tg3_flag(tp, 5780_CLASS) ||
 		   tg3_flag(tp, CPMU_PRESENT) ||
-		   (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)) {
+		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		/* do nothing */
 	} else if (!(tg3_flag(tp, 5750_PLUS) && tg3_flag(tp, ENABLE_ASF))) {
 		u32 newbits1, newbits2;
@@ -8646,7 +8646,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714)) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714) {
 		u32 tmp;
 
 		tmp = tr32(SERDES_RX_CTRL);
@@ -11636,7 +11636,7 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 		tw32(NVRAM_CFG1, nvcfg1);
 	}
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) ||
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
 	    tg3_flag(tp, 5780_CLASS)) {
 		switch (nvcfg1 & NVRAM_CFG1_VENDOR_MASK) {
 		case FLASH_VENDOR_ATMEL_FLASH_BUFFERED:
@@ -12640,9 +12640,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 
 		tg3_read_mem(tp, NIC_SRAM_DATA_VER, &ver);
 		ver >>= NIC_SRAM_DATA_VER_SHIFT;
-		if ((GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5703) &&
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5703 &&
 		    (ver > 0) && (ver < 0x100))
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_2, &cfg2);
 
@@ -13498,7 +13498,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
 		static struct tg3_dev_id {
 			u32	vendor;
 			u32	device;
@@ -13598,7 +13598,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    tg3_flag(tp, 5780_CLASS))
 		tg3_flag_set(tp, 5750_PLUS);
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) ||
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
 	    tg3_flag(tp, 5750_PLUS))
 		tg3_flag_set(tp, 5705_PLUS);
 
@@ -13627,9 +13627,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Selectively allow TSO based on operating conditions */
-	if ((tg3_flag(tp, HW_TSO_1) ||
-	     tg3_flag(tp, HW_TSO_2) ||
-	     tg3_flag(tp, HW_TSO_3)) ||
+	if (tg3_flag(tp, HW_TSO_1) ||
+	    tg3_flag(tp, HW_TSO_2) ||
+	    tg3_flag(tp, HW_TSO_3) ||
 	    (tp->fw_needed && !tg3_flag(tp, ENABLE_ASF)))
 		tg3_flag_set(tp, TSO_CAPABLE);
 	else {
@@ -13891,7 +13891,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 * It is also used as eeprom write protect on LOMs.
 	 */
 	tp->grc_local_ctrl = GRC_LCLCTRL_INT_ON_ATTN | GRC_LCLCTRL_AUTO_SEEPROM;
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) ||
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    tg3_flag(tp, EEPROM_WRITE_PROT))
 		tp->grc_local_ctrl |= (GRC_LCLCTRL_GPIO_OE1 |
 				       GRC_LCLCTRL_GPIO_OUTPUT1);
@@ -13943,8 +13943,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->phy_flags |= TG3_PHYFLG_IS_FET;
 
 	/* A few boards don't want Ethernet@WireSpeed phy feature */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) ||
-	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A1)) ||
 	    (tp->phy_flags & TG3_PHYFLG_IS_FET) ||
@@ -14064,7 +14064,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tg3_flag_set(tp, IS_5788);
 
 	if (!tg3_flag(tp, IS_5788) &&
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700))
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700)
 		tg3_flag_set(tp, TAGGED_STATUS);
 	if (tg3_flag(tp, TAGGED_STATUS)) {
 		tp->coalesce_mode |= (HOSTCC_MODE_CLRTICK_RXBD |
@@ -14215,7 +14215,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 #endif
 
 	mac_offset = 0x7c;
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	    tg3_flag(tp, 5780_CLASS)) {
 		if (tr32(TG3PCI_DUAL_MAC_CTRL) & DUAL_MAC_CTRL_ID)
 			mac_offset = 0xcc;
-- 
1.7.3.4


