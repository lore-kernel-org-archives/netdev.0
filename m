From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 17/25] ixgb: fix spelling errors
Date: Tue, 08 Jul 2008 15:52:28 -0700
Message-ID: <20080708225228.6925.37458.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34140 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453AbYGHWwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:39 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    4 ++--
 drivers/net/ixgb/ixgb_ee.c   |    6 +++---
 drivers/net/ixgb/ixgb_ee.h   |   10 +++++-----
 drivers/net/ixgb/ixgb_hw.c   |    4 ++--
 drivers/net/ixgb/ixgb_main.c |    2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 69529ec..6cb4dde 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -94,8 +94,8 @@ struct ixgb_adapter;
 #define MIN_TXD	  64
 
 /* hardware cannot reliably support more than 512 descriptors owned by
- * hardware descrioptor cache otherwise an unreliable ring under heavy
- * recieve load may result */
+ * hardware descriptor cache otherwise an unreliable ring under heavy
+ * receive load may result */
 /* #define DEFAULT_RXD	   1024 */
 /* #define MAX_RXD	   4096 */
 #define DEFAULT_RXD	512
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 8bc9716..aa71b9b 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -205,7 +205,7 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
-	/*  Deselct EEPROM  */
+	/*  Deselect EEPROM  */
 	eecd_reg &= ~(IXGB_EECD_CS | IXGB_EECD_SK);
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
 	udelay(50);
@@ -293,7 +293,7 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 	 */
 	ixgb_standby_eeprom(hw);
 
-	/* Now read DO repeatedly until is high (equal to '1').  The EEEPROM will
+	/* Now read DO repeatedly until is high (equal to '1').  The EEPROM will
 	 * signal that the command has been completed by raising the DO signal.
 	 * If DO does not go high in 10 milliseconds, then error out.
 	 */
@@ -365,7 +365,7 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  * reg - offset within the EEPROM to be written to
- * data - 16 bit word to be writen to the EEPROM
+ * data - 16 bit word to be written to the EEPROM
  *
  * If ixgb_update_eeprom_checksum is not called after this function, the
  * EEPROM will most likely contain an invalid checksum.
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 4b7bd0d..12136b6 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -34,11 +34,11 @@
 #define IXGB_ETH_LENGTH_OF_ADDRESS   6
 
 /* EEPROM Commands */
-#define EEPROM_READ_OPCODE  0x6	/* EERPOM read opcode */
-#define EEPROM_WRITE_OPCODE 0x5	/* EERPOM write opcode */
-#define EEPROM_ERASE_OPCODE 0x7	/* EERPOM erase opcode */
-#define EEPROM_EWEN_OPCODE  0x13	/* EERPOM erase/write enable */
-#define EEPROM_EWDS_OPCODE  0x10	/* EERPOM erast/write disable */
+#define EEPROM_READ_OPCODE  0x6	/* EEPROM read opcode */
+#define EEPROM_WRITE_OPCODE 0x5	/* EEPROM write opcode */
+#define EEPROM_ERASE_OPCODE 0x7	/* EEPROM erase opcode */
+#define EEPROM_EWEN_OPCODE  0x13	/* EEPROM erase/write enable */
+#define EEPROM_EWDS_OPCODE  0x10	/* EEPROM erase/write disable */
 
 /* EEPROM MAP (Word Offsets) */
 #define EEPROM_IA_1_2_REG        0x0000
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index d023fb5..3694e8c 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -371,7 +371,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Places the MAC address in receive address register 0 and clears the rest
- * of the receive addresss registers. Clears the multicast table. Assumes
+ * of the receive address registers. Clears the multicast table. Assumes
  * the receiver is in reset when the routine is called.
  *****************************************************************************/
 static void
@@ -964,7 +964,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 }
 
 /******************************************************************************
- * Check for a bad link condition that may have occured.
+ * Check for a bad link condition that may have occurred.
  * The indication is that the RFC / LFC registers may be incrementing
  * continually.  A full adapter reset is required to recover.
  *
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index fc211a3..796f011 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2248,7 +2248,7 @@ static pci_ers_result_t ixgb_io_error_detected(struct pci_dev *pdev,
  * ixgb_io_slot_reset - called after the pci bus has been reset.
  * @pdev    pointer to pci device with error
  *
- * This callback is called after the PCI buss has been reset.
+ * This callback is called after the PCI bus has been reset.
  * Basically, this tries to restart the card from scratch.
  * This is a shortened version of the device probe/discovery code,
  * it resembles the first-half of the ixgb_probe() routine.

