From: Ravinder Atla <rednivaralat@gmail.com>
Subject: [PATCH] /net/ethernet/3com/3c59x.c:Fixed coding style errors and warnings.
Date: Fri, 21 Aug 2015 20:57:05 +0530
Message-ID: <1440170825-4370-1-git-send-email-rednivaralat@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ravinder Atla <rednivaralat@gmail.com>
To: klassert@mathematik.tu-chemnitz.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Checks are also cleared
Signed-off-by: Ravinder Atla <rednivaralat@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 2d1ce3c..18d242c 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -208,15 +208,18 @@ limit of 4K.
    of the drivers, and will likely be provided by some future kernel.
 */
 enum pci_flags_bit {
-	PCI_USES_MASTER=4,
+	PCI_USES_MASTER = 4,
 };
 
-enum {	IS_VORTEX=1, IS_BOOMERANG=2, IS_CYCLONE=4, IS_TORNADO=8,
-	EEPROM_8BIT=0x10,	/* AKPM: Uses 0x230 as the base bitmaps for EEPROM reads */
-	HAS_PWR_CTRL=0x20, HAS_MII=0x40, HAS_NWAY=0x80, HAS_CB_FNS=0x100,
-	INVERT_MII_PWR=0x200, INVERT_LED_PWR=0x400, MAX_COLLISION_RESET=0x800,
-	EEPROM_OFFSET=0x1000, HAS_HWCKSM=0x2000, WNO_XCVR_PWR=0x4000,
-	EXTRA_PREAMBLE=0x8000, EEPROM_RESET=0x10000, };
+enum {	IS_VORTEX=1, IS_BOOMERANG = 2, IS_CYCLONE = 4, IS_TORNADO = 8,
+	EEPROM_8BIT = 0x10,
+	/* AKPM: Uses 0x230 as the base bitmaps for EEPROM reads */
+	HAS_PWR_CTRL = 0x20, HAS_MII = 0x40, HAS_NWAY = 0x80,
+	HAS_CB_FNS = 0x100,
+	INVERT_MII_PWR = 0x200, INVERT_LED_PWR = 0x400,
+	MAX_COLLISION_RESET = 0x800,
+	EEPROM_OFFSET = 0x1000, HAS_HWCKSM = 0x2000, WNO_XCVR_PWR = 0x4000,
+	EXTRA_PREAMBLE = 0x8000, EEPROM_RESET = 0x10000, };
 
 enum vortex_chips {
 	CH_3C590 = 0,
@@ -267,7 +270,6 @@ enum vortex_chips {
 	CH_920B_EMB_WNM,
 };
 
-
 /* note: this array directly indexed by above enums, and MUST
  * be kept in sync with both the enums above, and the PCI device
  * table below
@@ -280,9 +282,9 @@ static struct vortex_chip_info {
 } vortex_info_tbl[] = {
 	{"3c590 Vortex 10Mbps",
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
-	{"3c592 EISA 10Mbps Demon/Vortex",					/* AKPM: from Don's 3c59x_cb.c 0.49H */
+	{"3c592 EISA 10Mbps Demon/Vortex",	/* AKPM: from Don's 3c59x_cb.c 0.49H */
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
-	{"3c597 EISA Fast Demon/Vortex",					/* AKPM: from Don's 3c59x_cb.c 0.49H */
+	{"3c597 EISA Fast Demon/Vortex",	/* AKPM: from Don's 3c59x_cb.c 0.49H */
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
 	{"3c595 Vortex 100baseTx",
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
@@ -292,15 +294,15 @@ static struct vortex_chip_info {
 	{"3c595 Vortex 100base-MII",
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
 	{"3c900 Boomerang 10baseT",
-	 PCI_USES_MASTER, IS_BOOMERANG|EEPROM_RESET, 64, },
+	 PCI_USES_MASTER, IS_BOOMERANG | EEPROM_RESET, 64, },
 	{"3c900 Boomerang 10Mbps Combo",
-	 PCI_USES_MASTER, IS_BOOMERANG|EEPROM_RESET, 64, },
-	{"3c900 Cyclone 10Mbps TPO",						/* AKPM: from Don's 0.99M */
+	 PCI_USES_MASTER, IS_BOOMERANG | EEPROM_RESET, 64, },
+	{"3c900 Cyclone 10Mbps TPO",		/* AKPM: from Don's 0.99M */
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c900 Cyclone 10Mbps Combo",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 
-	{"3c900 Cyclone 10Mbps TPC",						/* AKPM: from Don's 0.99M */
+	{"3c900 Cyclone 10Mbps TPC",		/* AKPM: from Don's 0.99M */
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c900B-FL Cyclone 10base-FL",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
@@ -331,8 +333,8 @@ static struct vortex_chip_info {
 	{"3c555 Laptop Hurricane",
 	 PCI_USES_MASTER, IS_CYCLONE|EEPROM_8BIT|HAS_HWCKSM, 128, },
 	{"3c556 Laptop Tornado",
-	 PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|EEPROM_8BIT|HAS_CB_FNS|INVERT_MII_PWR|
-									HAS_HWCKSM, 128, },
+	 PCI_USES_MASTER, IS_TORNADO | HAS_NWAY | EEPROM_8BIT | HAS_CB_FNS | 
+			INVERT_MII_PWR | HAS_HWCKSM, 128, },
 	{"3c556B Laptop Hurricane",
 	 PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|EEPROM_OFFSET|HAS_CB_FNS|INVERT_MII_PWR|
 	                                WNO_XCVR_PWR|HAS_HWCKSM, 128, },
@@ -474,13 +476,14 @@ enum vortex_status {
    On the Vortex this window is always mapped at offsets 0x10-0x1f. */
 enum Window1 {
 	TX_FIFO = 0x10,  RX_FIFO = 0x10,  RxErrors = 0x14,
-	RxStatus = 0x18,  Timer=0x1A, TxStatus = 0x1B,
+	RxStatus = 0x18,  Timer = 0x1A, TxStatus = 0x1B,
 	TxFree = 0x1C, /* Remaining free bytes in Tx buffer. */
 };
+
 enum Window0 {
 	Wn0EepromCmd = 10,		/* Window 0: EEPROM command register. */
 	Wn0EepromData = 12,		/* Window 0: EEPROM results register. */
-	IntrStatus=0x0E,		/* Valid in all windows. */
+	IntrStatus = 0x0E,		/* Valid in all windows. */
 };
 enum Win0_EEPROM_bits {
 	EEPROM_Read = 0x80, EEPROM_WRITE = 0x40, EEPROM_ERASE = 0xC0,
-- 
1.9.1
