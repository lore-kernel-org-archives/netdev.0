From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/7] e1000e: fix spelling errors in comments
Date: Thu, 21 Feb 2008 15:11:07 -0800
Message-ID: <20080221231107.5595.45082.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23535 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbYBUXYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:24:06 -0500
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some spelling errors and inconsistencies in comment blocks.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |   10 +++++-----
 drivers/net/e1000e/defines.h |   10 +++++-----
 drivers/net/e1000e/hw.h      |    4 ++--
 drivers/net/e1000e/ich8lan.c |   24 ++++++++++++------------
 drivers/net/e1000e/lib.c     |   16 ++++++++--------
 drivers/net/e1000e/netdev.c  |   16 +++++++++-------
 drivers/net/e1000e/phy.c     |   10 +++++-----
 7 files changed, 46 insertions(+), 44 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index f7ffd35..7fe2031 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -438,7 +438,7 @@ static void e1000_release_nvm_82571(struct e1000_hw *hw)
  *  For non-82573 silicon, write data to EEPROM at offset using SPI interface.
  *
  *  If e1000e_update_nvm_checksum is not called after this function, the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_82571(struct e1000_hw *hw, u16 offset, u16 words,
 				 u16 *data)
@@ -547,7 +547,7 @@ static s32 e1000_validate_nvm_checksum_82571(struct e1000_hw *hw)
  *  poll for completion.
  *
  *  If e1000e_update_nvm_checksum is not called after this function, the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 				      u16 words, u16 *data)
@@ -1053,7 +1053,7 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 		/* If SerDes loopback mode is entered, there is no form
 		 * of reset to take the adapter out of that mode.  So we
 		 * have to explicitly take the adapter out of loopback
-		 * mode.  This prevents drivers from twidling their thumbs
+		 * mode.  This prevents drivers from twiddling their thumbs
 		 * if another tool failed to take it out of loopback mode.
 		 */
 		ew32(SCTL,
@@ -1098,7 +1098,7 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
  *  e1000e_get_laa_state_82571 - Get locally administered address state
  *  @hw: pointer to the HW structure
  *
- *  Retrieve and return the current locally administed address state.
+ *  Retrieve and return the current locally administered address state.
  **/
 bool e1000e_get_laa_state_82571(struct e1000_hw *hw)
 {
@@ -1113,7 +1113,7 @@ bool e1000e_get_laa_state_82571(struct e1000_hw *hw)
  *  @hw: pointer to the HW structure
  *  @state: enable/disable locally administered address
  *
- *  Enable/Disable the current locally administed address state.
+ *  Enable/Disable the current locally administers address state.
  **/
 void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state)
 {
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 6232c3e..a4f511f 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -66,7 +66,7 @@
 #define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
 /* Extended Device Control */
-#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
+#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
@@ -75,12 +75,12 @@
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 
-/* Receive Decriptor bit definitions */
+/* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
 #define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_ERR_CE        0x01    /* CRC Error */
 #define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
@@ -223,7 +223,7 @@
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
 
-/* Constants used to intrepret the masked PCI-X bus speed. */
+/* Constants used to interpret the masked PCI-X bus speed. */
 
 #define HALF_DUPLEX 1
 #define FULL_DUPLEX 2
@@ -517,7 +517,7 @@
 /* PHY 1000 MII Register/Bit Definitions */
 /* PHY Registers defined by IEEE */
 #define PHY_CONTROL      0x00 /* Control Register */
-#define PHY_STATUS       0x01 /* Status Regiser */
+#define PHY_STATUS       0x01 /* Status Register */
 #define PHY_ID1          0x02 /* Phy Id Reg (word 1) */
 #define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
 #define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 3c5862f..916025b 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -184,7 +184,7 @@ enum e1e_registers {
 	E1000_ICRXDMTC = 0x04120, /* Irq Cause Rx Desc MinThreshold Count */
 	E1000_ICRXOC   = 0x04124, /* Irq Cause Receiver Overrun Count */
 	E1000_RXCSUM   = 0x05000, /* RX Checksum Control - RW */
-	E1000_RFCTL    = 0x05008, /* Receive Filter Control*/
+	E1000_RFCTL    = 0x05008, /* Receive Filter Control */
 	E1000_MTA      = 0x05200, /* Multicast Table Array - RW Array */
 	E1000_RA       = 0x05400, /* Receive Address - RW Array */
 	E1000_VFTA     = 0x05600, /* VLAN Filter Table Array - RW Array */
@@ -202,7 +202,7 @@ enum e1e_registers {
 	E1000_FACTPS    = 0x05B30, /* Function Active and Power State to MNG */
 	E1000_SWSM      = 0x05B50, /* SW Semaphore */
 	E1000_FWSM      = 0x05B54, /* FW Semaphore */
-	E1000_HICR      = 0x08F00, /* Host Inteface Control */
+	E1000_HICR      = 0x08F00, /* Host Interface Control */
 };
 
 /* RSS registers */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8f8139d..0ae3955 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -671,7 +671,7 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
  *  e1000_check_polarity_ife_ich8lan - Check cable polarity for IFE PHY
  *  @hw: pointer to the HW structure
  *
- *  Polarity is determined on the polarity reveral feature being enabled.
+ *  Polarity is determined on the polarity reversal feature being enabled.
  *  This function is only called by other family-specific
  *  routines.
  **/
@@ -947,7 +947,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	/* Either we should have a hardware SPI cycle in progress
 	 * bit to check against, in order to start a new cycle or
 	 * FDONE bit should be changed in the hardware so that it
-	 * is 1 after harware reset, which can then be used as an
+	 * is 1 after hardware reset, which can then be used as an
 	 * indication whether a cycle is in progress or has been
 	 * completed.
 	 */
@@ -1155,7 +1155,7 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
  *  which writes the checksum to the shadow ram.  The changes in the shadow
  *  ram are then committed to the EEPROM by processing each bank at a time
  *  checking for the modified bit and writing only the pending changes.
- *  After a succesful commit, the shadow ram is cleared and is ready for
+ *  After a successful commit, the shadow ram is cleared and is ready for
  *  future writes.
  **/
 static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
@@ -1680,7 +1680,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
  *   - initialize LED identification
  *   - setup receive address registers
  *   - setup flow control
- *   - setup transmit discriptors
+ *   - setup transmit descriptors
  *   - clear statistics
  **/
 static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
@@ -1961,7 +1961,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 		     E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 	ew32(PHY_CTRL, phy_ctrl);
 
-	/* Call gig speed drop workaround on Giga disable before accessing
+	/* Call gig speed drop workaround on Gig disable before accessing
 	 * any PHY registers */
 	e1000e_gig_downshift_workaround_ich8lan(hw);
 
@@ -1972,7 +1972,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 /**
  *  e1000_set_kmrn_lock_loss_workaound_ich8lan - Set Kumeran workaround state
  *  @hw: pointer to the HW structure
- *  @state: boolean value used to set the current Kumaran workaround state
+ *  @state: boolean value used to set the current Kumeran workaround state
  *
  *  If ICH8, set the current Kumeran workaround state (enabled - TRUE
  *  /disabled - FALSE).
@@ -2017,7 +2017,7 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 			E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 		ew32(PHY_CTRL, reg);
 
-		/* Call gig speed drop workaround on Giga disable before
+		/* Call gig speed drop workaround on Gig disable before
 		 * accessing any PHY registers */
 		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
@@ -2045,7 +2045,7 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
  *  @hw: pointer to the HW structure
  *
  *  Steps to take when dropping from 1Gb/s (eg. link cable removal (LSC),
- *  LPLU, Giga disable, MDIC PHY reset):
+ *  LPLU, Gig disable, MDIC PHY reset):
  *    1) Set Kumeran Near-end loopback
  *    2) Clear Kumeran Near-end loopback
  *  Should only be called for ICH8[m] devices with IGP_3 Phy.
@@ -2089,10 +2089,10 @@ static s32 e1000_cleanup_led_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_on_ich8lan - Turn LED's on
+ *  e1000_led_on_ich8lan - Turn LEDs on
  *  @hw: pointer to the HW structure
  *
- *  Turn on the LED's.
+ *  Turn on the LEDs.
  **/
 static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
 {
@@ -2105,10 +2105,10 @@ static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_off_ich8lan - Turn LED's off
+ *  e1000_led_off_ich8lan - Turn LEDs off
  *  @hw: pointer to the HW structure
  *
- *  Turn off the LED's.
+ *  Turn off the LEDs.
  **/
 static s32 e1000_led_off_ich8lan(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 341d74e..95f75a4 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1140,7 +1140,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_get_speed_and_duplex_copper - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_copper - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1176,7 +1176,7 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
 }
 
 /**
- *  e1000e_get_speed_and_duplex_fiber_serdes - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_fiber_serdes - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1386,7 +1386,7 @@ s32 e1000e_cleanup_led_generic(struct e1000_hw *hw)
  *  e1000e_blink_led - Blink LED
  *  @hw: pointer to the HW structure
  *
- *  Blink the led's which are set to be on.
+ *  Blink the LEDs which are set to be on.
  **/
 s32 e1000e_blink_led(struct e1000_hw *hw)
 {
@@ -1491,7 +1491,7 @@ void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  *  @hw: pointer to the HW structure
  *
  *  Returns 0 if successful, else returns -10
- *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not casued
+ *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not caused
  *  the master requests to be disabled.
  *
  *  Disables PCI-Express master access and verifies there are no pending
@@ -1852,7 +1852,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_read_nvm_spi - Read EEPROM's using SPI
+ *  e1000e_read_nvm_spi - Reads EEPROM using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -1956,7 +1956,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
  *  Writes data to EEPROM at offset using SPI interface.
  *
  *  If e1000e_update_nvm_checksum is not called after this function , the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
@@ -2198,7 +2198,7 @@ static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
  *
  *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
  *
- *  This function checks whether the HOST IF is enabled for command operaton
+ *  This function checks whether the HOST IF is enabled for command operation
  *  and also checks whether the previous command is completed.  It busy waits
  *  in case of previous command is not completed.
  **/
@@ -2230,7 +2230,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_check_mng_mode - check managament mode
+ *  e1000e_check_mng_mode - check management mode
  *  @hw: pointer to the HW structure
  *
  *  Reads the firmware semaphore register and returns true (>0) if
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3031d6d..7824bc2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1006,7 +1006,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
  * e1000_get_hw_control - get control of the h/w from f/w
  * @adapter: address of board private structure
  *
- * e1000_get_hw_control sets {CTRL_EXT|FWSM}:DRV_LOAD bit.
+ * e1000_get_hw_control sets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that
  * the driver is loaded. For AMT version (only with 82573)
  * of the f/w this means that the network i/f is open.
@@ -1032,7 +1032,7 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
  * e1000_release_hw_control - release control of the h/w to f/w
  * @adapter: address of board private structure
  *
- * e1000_release_hw_control resets {CTRL_EXT|FWSM}:DRV_LOAD bit.
+ * e1000_release_hw_control resets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that the
  * driver is no longer loaded. For AMT version (only with 82573) i
  * of the f/w this means that the network i/f is closed.
@@ -1241,6 +1241,11 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 
 /**
  * e1000_update_itr - update the dynamic ITR value based on statistics
+ * @adapter: pointer to adapter
+ * @itr_setting: current adapter->itr
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ *
  *      Stores a new ITR value based on packets and byte
  *      counts during the last interrupt.  The advantage of per interrupt
  *      computation is faster updates and more accurate ITR for the current
@@ -1250,10 +1255,6 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
  *      while increasing bulk throughput.
  *      this functionality is controlled by the InterruptThrottleRate module
  *      parameter (see e1000_param.c)
- * @adapter: pointer to adapter
- * @itr_setting: current adapter->itr
- * @packets: the number of packets during this measurement interval
- * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 				     u16 itr_setting, int packets,
@@ -1366,6 +1367,7 @@ set_itr_now:
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
+ * @budget: amount of packets driver is allowed to process this poll
  **/
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
@@ -2000,7 +2002,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	    e1000_check_reset_block(hw))
 		return;
 
-	/* managebility (AMT) is enabled */
+	/* manageability (AMT) is enabled */
 	if (er32(MANC) & E1000_MANC_SMBUS_EN)
 		return;
 
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index fc6fee1..dab3c46 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -121,7 +121,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
  *  @offset: register offset to be read
  *  @data: pointer to the read data
  *
- *  Reads the MDI control regsiter in the PHY at offset and stores the
+ *  Reads the MDI control register in the PHY at offset and stores the
  *  information read to data.
  **/
 static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
@@ -1172,7 +1172,7 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 }
 
 /**
- *  e1000e_check_downshift - Checks whether a downshift in speed occured
+ *  e1000e_check_downshift - Checks whether a downshift in speed occurred
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns 1
@@ -1388,8 +1388,8 @@ s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
  *  received signal, adjusting for the attenuation produced by the
- *  cable.  By reading the AGC registers, which reperesent the
- *  cobination of course and fine gain value, the value can be put
+ *  cable.  By reading the AGC registers, which represent the
+ *  combination of course and fine gain value, the value can be put
  *  into a lookup table to obtain the approximate cable length
  *  for each channel.
  **/
@@ -1619,7 +1619,7 @@ s32 e1000e_phy_sw_reset(struct e1000_hw *hw)
  *  Verify the reset block is not blocking us from resetting.  Acquire
  *  semaphore (if necessary) and read/set/write the device control reset
  *  bit in the PHY.  Wait the appropriate delay time for the device to
- *  reset and relase the semaphore (if necessary).
+ *  reset and release the semaphore (if necessary).
  **/
 s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 {

