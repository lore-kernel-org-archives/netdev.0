From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 03/18] igb: cleanup function header
	comments
Date: Fri, 27 Jun 2008 10:59:59 -0700
Message-ID: <20080627175953.22428.37167.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Function header comments do not match function name.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   48 +++++++++++++++---------------
 drivers/net/igb/e1000_mac.c   |   66 +++++++++++++++++++++--------------------
 drivers/net/igb/e1000_nvm.c   |   30 +++++++++----------
 drivers/net/igb/e1000_phy.c   |   62 +++++++++++++++++++--------------------
 4 files changed, 103 insertions(+), 103 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 39d44dc..e6dd387 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -226,7 +226,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_phy_82575 - Acquire rights to access PHY
+ *  igb_acquire_phy_82575 - Acquire rights to access PHY
  *  @hw: pointer to the HW structure
  *
  *  Acquire access rights to the correct PHY.  This is a
@@ -242,7 +242,7 @@ static s32 igb_acquire_phy_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_phy_82575 - Release rights to access PHY
+ *  igb_release_phy_82575 - Release rights to access PHY
  *  @hw: pointer to the HW structure
  *
  *  A wrapper to release access rights to the correct PHY.  This is a
@@ -257,7 +257,7 @@ static void igb_release_phy_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_phy_reg_sgmii_82575 - Read PHY register using sgmii
+ *  igb_read_phy_reg_sgmii_82575 - Read PHY register using sgmii
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -310,7 +310,7 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 }
 
 /**
- *  e1000_write_phy_reg_sgmii_82575 - Write PHY register using sgmii
+ *  igb_write_phy_reg_sgmii_82575 - Write PHY register using sgmii
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -365,7 +365,7 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 }
 
 /**
- *  e1000_get_phy_id_82575 - Retreive PHY addr and id
+ *  igb_get_phy_id_82575 - Retrieve PHY addr and id
  *  @hw: pointer to the HW structure
  *
  *  Retreives the PHY address and ID for both PHY's which do and do not use
@@ -426,7 +426,7 @@ out:
 }
 
 /**
- *  e1000_phy_hw_reset_sgmii_82575 - Performs a PHY reset
+ *  igb_phy_hw_reset_sgmii_82575 - Performs a PHY reset
  *  @hw: pointer to the HW structure
  *
  *  Resets the PHY using the serial gigabit media independent interface.
@@ -457,7 +457,7 @@ out:
 }
 
 /**
- *  e1000_set_d0_lplu_state_82575 - Set Low Power Linkup D0 state
+ *  igb_set_d0_lplu_state_82575 - Set Low Power Linkup D0 state
  *  @hw: pointer to the HW structure
  *  @active: true to enable LPLU, false to disable
  *
@@ -543,7 +543,7 @@ out:
 }
 
 /**
- *  e1000_acquire_nvm_82575 - Request for access to EEPROM
+ *  igb_acquire_nvm_82575 - Request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Acquire the necessary semaphores for exclussive access to the EEPROM.
@@ -569,7 +569,7 @@ out:
 }
 
 /**
- *  e1000_release_nvm_82575 - Release exclusive access to EEPROM
+ *  igb_release_nvm_82575 - Release exclusive access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit,
@@ -582,7 +582,7 @@ static void igb_release_nvm_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_swfw_sync_82575 - Acquire SW/FW semaphore
+ *  igb_acquire_swfw_sync_82575 - Acquire SW/FW semaphore
  *  @hw: pointer to the HW structure
  *  @mask: specifies which semaphore to acquire
  *
@@ -632,7 +632,7 @@ out:
 }
 
 /**
- *  e1000_release_swfw_sync_82575 - Release SW/FW semaphore
+ *  igb_release_swfw_sync_82575 - Release SW/FW semaphore
  *  @hw: pointer to the HW structure
  *  @mask: specifies which semaphore to acquire
  *
@@ -654,7 +654,7 @@ static void igb_release_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 }
 
 /**
- *  e1000_get_cfg_done_82575 - Read config done bit
+ *  igb_get_cfg_done_82575 - Read config done bit
  *  @hw: pointer to the HW structure
  *
  *  Read the management control register for the config done bit for
@@ -690,7 +690,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_link_82575 - Check for link
+ *  igb_check_for_link_82575 - Check for link
  *  @hw: pointer to the HW structure
  *
  *  If sgmii is enabled, then use the pcs register to determine link, otherwise
@@ -713,7 +713,7 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
+ *  igb_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -768,7 +768,7 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  e1000_rar_set_82575 - Set receive address register
+ *  igb_rar_set_82575 - Set receive address register
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
  *  @index: receive address array register
@@ -785,7 +785,7 @@ static void igb_rar_set_82575(struct e1000_hw *hw, u8 *addr, u32 index)
 }
 
 /**
- *  e1000_reset_hw_82575 - Reset hardware
+ *  igb_reset_hw_82575 - Reset hardware
  *  @hw: pointer to the HW structure
  *
  *  This resets the hardware into a known state.  This is a
@@ -842,7 +842,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_init_hw_82575 - Initialize hardware
+ *  igb_init_hw_82575 - Initialize hardware
  *  @hw: pointer to the HW structure
  *
  *  This inits the hardware readying it for operation.
@@ -886,7 +886,7 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_setup_copper_link_82575 - Configure copper link settings
+ *  igb_setup_copper_link_82575 - Configure copper link settings
  *  @hw: pointer to the HW structure
  *
  *  Configures the link for auto-neg or forced speed and duplex.  Then we check
@@ -974,7 +974,7 @@ out:
 }
 
 /**
- *  e1000_setup_fiber_serdes_link_82575 - Setup link for fiber/serdes
+ *  igb_setup_fiber_serdes_link_82575 - Setup link for fiber/serdes
  *  @hw: pointer to the HW structure
  *
  *  Configures speed and duplex for fiber and serdes links.
@@ -1038,7 +1038,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_configure_pcs_link_82575 - Configure PCS link
+ *  igb_configure_pcs_link_82575 - Configure PCS link
  *  @hw: pointer to the HW structure
  *
  *  Configure the physical coding sub-layer (PCS) link.  The PCS link is
@@ -1103,7 +1103,7 @@ out:
 }
 
 /**
- *  e1000_sgmii_active_82575 - Return sgmii state
+ *  igb_sgmii_active_82575 - Return sgmii state
  *  @hw: pointer to the HW structure
  *
  *  82575 silicon has a serialized gigabit media independent interface (sgmii)
@@ -1129,7 +1129,7 @@ out:
 }
 
 /**
- *  e1000_reset_init_script_82575 - Inits HW defaults after reset
+ *  igb_reset_init_script_82575 - Inits HW defaults after reset
  *  @hw: pointer to the HW structure
  *
  *  Inits recommended HW defaults after a reset when there is no EEPROM
@@ -1165,7 +1165,7 @@ static s32 igb_reset_init_script_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_mac_addr_82575 - Read device MAC address
+ *  igb_read_mac_addr_82575 - Read device MAC address
  *  @hw: pointer to the HW structure
  **/
 static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
@@ -1179,7 +1179,7 @@ static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_clear_hw_cntrs_82575 - Clear device specific hardware counters
+ *  igb_clear_hw_cntrs_82575 - Clear device specific hardware counters
  *  @hw: pointer to the HW structure
  *
  *  Clears the hardware counters by reading the counter registers.
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 3e84a3f..0dadcfd 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -39,7 +39,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
 static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
 /**
- *  e1000_remove_device - Free device specific structure
+ *  igb_remove_device - Free device specific structure
  *  @hw: pointer to the HW structure
  *
  *  If a device specific structure was allocated, this function will
@@ -73,7 +73,7 @@ static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 }
 
 /**
- *  e1000_get_bus_info_pcie - Get PCIe bus information
+ *  igb_get_bus_info_pcie - Get PCIe bus information
  *  @hw: pointer to the HW structure
  *
  *  Determines and stores the system bus information for a particular
@@ -113,7 +113,7 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_clear_vfta - Clear VLAN filter table
+ *  igb_clear_vfta - Clear VLAN filter table
  *  @hw: pointer to the HW structure
  *
  *  Clears the register array which contains the VLAN filter table by
@@ -130,7 +130,7 @@ void igb_clear_vfta(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_write_vfta - Write value to VLAN filter table
+ *  igb_write_vfta - Write value to VLAN filter table
  *  @hw: pointer to the HW structure
  *  @offset: register offset in VLAN filter table
  *  @value: register value written to VLAN filter table
@@ -145,7 +145,7 @@ void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 }
 
 /**
- *  e1000_init_rx_addrs - Initialize receive address's
+ *  igb_init_rx_addrs - Initialize receive address's
  *  @hw: pointer to the HW structure
  *  @rar_count: receive address registers
  *
@@ -173,7 +173,7 @@ void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 }
 
 /**
- *  e1000_check_alt_mac_addr - Check for alternate MAC addr
+ *  igb_check_alt_mac_addr - Check for alternate MAC addr
  *  @hw: pointer to the HW structure
  *
  *  Checks the nvm for an alternate MAC address.  An alternate MAC address
@@ -233,7 +233,7 @@ out:
 }
 
 /**
- *  e1000_rar_set - Set receive address register
+ *  igb_rar_set - Set receive address register
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
  *  @index: receive address array register
@@ -263,7 +263,7 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 }
 
 /**
- *  e1000_mta_set - Set multicast filter table address
+ *  igb_mta_set - Set multicast filter table address
  *  @hw: pointer to the HW structure
  *  @hash_value: determines the MTA register and bit to set
  *
@@ -298,7 +298,7 @@ static void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 }
 
 /**
- *  e1000_update_mc_addr_list - Update Multicast addresses
+ *  igb_update_mc_addr_list - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -352,7 +352,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 }
 
 /**
- *  e1000_hash_mc_addr - Generate a multicast hash value
+ *  igb_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
  *
@@ -423,7 +423,7 @@ static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  e1000_clear_hw_cntrs_base - Clear base hardware counters
+ *  igb_clear_hw_cntrs_base - Clear base hardware counters
  *  @hw: pointer to the HW structure
  *
  *  Clears the base hardware counters by reading the counter registers.
@@ -472,7 +472,7 @@ void igb_clear_hw_cntrs_base(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_copper_link - Check for link (Copper)
+ *  igb_check_for_copper_link - Check for link (Copper)
  *  @hw: pointer to the HW structure
  *
  *  Checks to see of the link status of the hardware has changed.  If a
@@ -547,7 +547,7 @@ out:
 }
 
 /**
- *  e1000_setup_link - Setup flow control and link settings
+ *  igb_setup_link - Setup flow control and link settings
  *  @hw: pointer to the HW structure
  *
  *  Determines which flow control settings to use, then configures flow
@@ -606,7 +606,7 @@ out:
 }
 
 /**
- *  e1000_config_collision_dist - Configure collision distance
+ *  igb_config_collision_dist - Configure collision distance
  *  @hw: pointer to the HW structure
  *
  *  Configures the collision distance to the default value and is used
@@ -627,7 +627,7 @@ void igb_config_collision_dist(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_fc_watermarks - Set flow control high/low watermarks
+ *  igb_set_fc_watermarks - Set flow control high/low watermarks
  *  @hw: pointer to the HW structure
  *
  *  Sets the flow control high/low threshold (watermark) registers.  If
@@ -665,7 +665,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_default_fc - Set flow control default values
+ *  igb_set_default_fc - Set flow control default values
  *  @hw: pointer to the HW structure
  *
  *  Read the EEPROM for the default values for flow control and store the
@@ -706,7 +706,7 @@ out:
 }
 
 /**
- *  e1000_force_mac_fc - Force the MAC's flow control settings
+ *  igb_force_mac_fc - Force the MAC's flow control settings
  *  @hw: pointer to the HW structure
  *
  *  Force the MAC's flow control settings.  Sets the TFCE and RFCE bits in the
@@ -770,7 +770,7 @@ out:
 }
 
 /**
- *  e1000_config_fc_after_link_up - Configures flow control after link
+ *  igb_config_fc_after_link_up - Configures flow control after link
  *  @hw: pointer to the HW structure
  *
  *  Checks the status of auto-negotiation after link up to ensure that the
@@ -991,7 +991,7 @@ out:
 }
 
 /**
- *  e1000_get_speed_and_duplex_copper - Retreive current speed/duplex
+ *  igb_get_speed_and_duplex_copper - Retreive current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1028,7 +1028,7 @@ s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  e1000_get_hw_semaphore - Acquire hardware semaphore
+ *  igb_get_hw_semaphore - Acquire hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Acquire the HW semaphore to access the PHY or NVM
@@ -1081,7 +1081,7 @@ out:
 }
 
 /**
- *  e1000_put_hw_semaphore - Release hardware semaphore
+ *  igb_put_hw_semaphore - Release hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Release hardware semaphore used to access the PHY or NVM
@@ -1098,7 +1098,7 @@ void igb_put_hw_semaphore(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_auto_rd_done - Check for auto read completion
+ *  igb_get_auto_rd_done - Check for auto read completion
  *  @hw: pointer to the HW structure
  *
  *  Check EEPROM for Auto Read done bit.
@@ -1127,7 +1127,7 @@ out:
 }
 
 /**
- *  e1000_valid_led_default - Verify a valid default LED config
+ *  igb_valid_led_default - Verify a valid default LED config
  *  @hw: pointer to the HW structure
  *  @data: pointer to the NVM (EEPROM)
  *
@@ -1152,7 +1152,7 @@ out:
 }
 
 /**
- *  e1000_id_led_init -
+ *  igb_id_led_init -
  *  @hw: pointer to the HW structure
  *
  **/
@@ -1217,7 +1217,7 @@ out:
 }
 
 /**
- *  e1000_cleanup_led - Set LED config to default operation
+ *  igb_cleanup_led - Set LED config to default operation
  *  @hw: pointer to the HW structure
  *
  *  Remove the current LED configuration and set the LED configuration
@@ -1230,7 +1230,7 @@ s32 igb_cleanup_led(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_blink_led - Blink LED
+ *  igb_blink_led - Blink LED
  *  @hw: pointer to the HW structure
  *
  *  Blink the led's which are set to be on.
@@ -1263,7 +1263,7 @@ s32 igb_blink_led(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_off - Turn LED off
+ *  igb_led_off - Turn LED off
  *  @hw: pointer to the HW structure
  *
  *  Turn LED off.
@@ -1290,7 +1290,7 @@ s32 igb_led_off(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_disable_pcie_master - Disables PCI-express master access
+ *  igb_disable_pcie_master - Disables PCI-express master access
  *  @hw: pointer to the HW structure
  *
  *  Returns 0 (0) if successful, else returns -10
@@ -1332,7 +1332,7 @@ out:
 }
 
 /**
- *  e1000_reset_adaptive - Reset Adaptive Interframe Spacing
+ *  igb_reset_adaptive - Reset Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Reset the Adaptive Interframe Spacing throttle to default values.
@@ -1361,7 +1361,7 @@ out:
 }
 
 /**
- *  e1000_update_adaptive - Update Adaptive Interframe Spacing
+ *  igb_update_adaptive - Update Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Update the Adaptive Interframe Spacing Throttle value based on the
@@ -1402,7 +1402,7 @@ out:
 }
 
 /**
- *  e1000_validate_mdi_setting - Verify MDI/MDIx settings
+ *  igb_validate_mdi_setting - Verify MDI/MDIx settings
  *  @hw: pointer to the HW structure
  *
  *  Verify that when not using auto-negotitation that MDI/MDIx is correctly
@@ -1424,7 +1424,7 @@ out:
 }
 
 /**
- *  e1000_write_8bit_ctrl_reg - Write a 8bit CTRL register
+ *  igb_write_8bit_ctrl_reg - Write a 8bit CTRL register
  *  @hw: pointer to the HW structure
  *  @reg: 32bit register offset such as E1000_SCTL
  *  @offset: register offset to write to
@@ -1462,7 +1462,7 @@ out:
 }
 
 /**
- *  e1000_enable_mng_pass_thru - Enable processing of ARP's
+ *  igb_enable_mng_pass_thru - Enable processing of ARP's
  *  @hw: pointer to the HW structure
  *
  *  Verifies the hardware needs to allow ARPs to be processed by the host.
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 2897106..780ba79 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -32,7 +32,7 @@
 #include "e1000_nvm.h"
 
 /**
- *  e1000_raise_eec_clk - Raise EEPROM clock
+ *  igb_raise_eec_clk - Raise EEPROM clock
  *  @hw: pointer to the HW structure
  *  @eecd: pointer to the EEPROM
  *
@@ -47,7 +47,7 @@ static void igb_raise_eec_clk(struct e1000_hw *hw, u32 *eecd)
 }
 
 /**
- *  e1000_lower_eec_clk - Lower EEPROM clock
+ *  igb_lower_eec_clk - Lower EEPROM clock
  *  @hw: pointer to the HW structure
  *  @eecd: pointer to the EEPROM
  *
@@ -62,7 +62,7 @@ static void igb_lower_eec_clk(struct e1000_hw *hw, u32 *eecd)
 }
 
 /**
- *  e1000_shift_out_eec_bits - Shift data bits our to the EEPROM
+ *  igb_shift_out_eec_bits - Shift data bits our to the EEPROM
  *  @hw: pointer to the HW structure
  *  @data: data to send to the EEPROM
  *  @count: number of bits to shift out
@@ -105,7 +105,7 @@ static void igb_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
 }
 
 /**
- *  e1000_shift_in_eec_bits - Shift data bits in from the EEPROM
+ *  igb_shift_in_eec_bits - Shift data bits in from the EEPROM
  *  @hw: pointer to the HW structure
  *  @count: number of bits to shift in
  *
@@ -143,7 +143,7 @@ static u16 igb_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
 }
 
 /**
- *  e1000_poll_eerd_eewr_done - Poll for EEPROM read/write completion
+ *  igb_poll_eerd_eewr_done - Poll for EEPROM read/write completion
  *  @hw: pointer to the HW structure
  *  @ee_reg: EEPROM flag for polling
  *
@@ -174,7 +174,7 @@ static s32 igb_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 }
 
 /**
- *  e1000_acquire_nvm - Generic request for access to EEPROM
+ *  igb_acquire_nvm - Generic request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
@@ -210,7 +210,7 @@ s32 igb_acquire_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_standby_nvm - Return EEPROM to standby state
+ *  igb_standby_nvm - Return EEPROM to standby state
  *  @hw: pointer to the HW structure
  *
  *  Return the EEPROM to a standby state.
@@ -273,7 +273,7 @@ static void e1000_stop_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_nvm - Release exclusive access to EEPROM
+ *  igb_release_nvm - Release exclusive access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
@@ -290,7 +290,7 @@ void igb_release_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_ready_nvm_eeprom - Prepares EEPROM for read/write
+ *  igb_ready_nvm_eeprom - Prepares EEPROM for read/write
  *  @hw: pointer to the HW structure
  *
  *  Setups the EEPROM for reading and writing.
@@ -348,7 +348,7 @@ out:
 }
 
 /**
- *  e1000_read_nvm_eerd - Reads EEPROM using EERD register
+ *  igb_read_nvm_eerd - Reads EEPROM using EERD register
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -391,7 +391,7 @@ out:
 }
 
 /**
- *  e1000_write_nvm_spi - Write to EEPROM using SPI
+ *  igb_write_nvm_spi - Write to EEPROM using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset within the EEPROM to be written to
  *  @words: number of words to write
@@ -475,7 +475,7 @@ out:
 }
 
 /**
- *  e1000_read_part_num - Read device part number
+ *  igb_read_part_num - Read device part number
  *  @hw: pointer to the HW structure
  *  @part_num: pointer to device part number
  *
@@ -506,7 +506,7 @@ out:
 }
 
 /**
- *  e1000_read_mac_addr - Read device MAC address
+ *  igb_read_mac_addr - Read device MAC address
  *  @hw: pointer to the HW structure
  *
  *  Reads the device MAC address from the EEPROM and stores the value.
@@ -541,7 +541,7 @@ out:
 }
 
 /**
- *  e1000_validate_nvm_checksum - Validate EEPROM checksum
+ *  igb_validate_nvm_checksum - Validate EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
@@ -573,7 +573,7 @@ out:
 }
 
 /**
- *  e1000_update_nvm_checksum - Update EEPROM checksum
+ *  igb_update_nvm_checksum - Update EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 08a86b1..220e471 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -61,7 +61,7 @@ static const u16 e1000_igp_2_cable_length_table[] =
 		 sizeof(e1000_igp_2_cable_length_table[0]))
 
 /**
- *  e1000_check_reset_block - Check if PHY reset is blocked
+ *  igb_check_reset_block - Check if PHY reset is blocked
  *  @hw: pointer to the HW structure
  *
  *  Read the PHY management control register and check whether a PHY reset
@@ -79,7 +79,7 @@ s32 igb_check_reset_block(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_id - Retrieve the PHY ID and revision
+ *  igb_get_phy_id - Retrieve the PHY ID and revision
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY registers and stores the PHY ID and possibly the PHY
@@ -109,7 +109,7 @@ out:
 }
 
 /**
- *  e1000_phy_reset_dsp - Reset PHY DSP
+ *  igb_phy_reset_dsp - Reset PHY DSP
  *  @hw: pointer to the HW structure
  *
  *  Reset the digital signal processor.
@@ -129,7 +129,7 @@ out:
 }
 
 /**
- *  e1000_read_phy_reg_mdic - Read MDI control register
+ *  igb_read_phy_reg_mdic - Read MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -188,7 +188,7 @@ out:
 }
 
 /**
- *  e1000_write_phy_reg_mdic - Write MDI control register
+ *  igb_write_phy_reg_mdic - Write MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write to register at offset
@@ -246,7 +246,7 @@ out:
 }
 
 /**
- *  e1000_read_phy_reg_igp - Read igp PHY register
+ *  igb_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -284,7 +284,7 @@ out:
 }
 
 /**
- *  e1000_write_phy_reg_igp - Write igp PHY register
+ *  igb_write_phy_reg_igp - Write igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -321,7 +321,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_setup_m88 - Setup m88 PHY's for copper link
+ *  igb_copper_link_setup_m88 - Setup m88 PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up MDI/MDI-X and polarity for m88 PHY's.  If necessary, transmit clock
@@ -432,7 +432,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_setup_igp - Setup igp PHY's for copper link
+ *  igb_copper_link_setup_igp - Setup igp PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up LPLU, MDI/MDI-X, polarity, Smartspeed and Master/Slave config for
@@ -570,7 +570,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_autoneg - Setup/Enable autoneg for copper link
+ *  igb_copper_link_autoneg - Setup/Enable autoneg for copper link
  *  @hw: pointer to the HW structure
  *
  *  Performs initial bounds checking on autoneg advertisement parameter, then
@@ -638,7 +638,7 @@ out:
 }
 
 /**
- *  e1000_phy_setup_autoneg - Configure PHY for auto-negotiation
+ *  igb_phy_setup_autoneg - Configure PHY for auto-negotiation
  *  @hw: pointer to the HW structure
  *
  *  Reads the MII auto-neg advertisement register and/or the 1000T control
@@ -805,7 +805,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
+ *  igb_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
@@ -878,7 +878,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
+ *  igb_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
@@ -993,7 +993,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
+ *  igb_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
  *  @hw: pointer to the HW structure
  *  @phy_ctrl: pointer to current value of PHY_CONTROL
  *
@@ -1054,7 +1054,7 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 }
 
 /**
- *  e1000_set_d3_lplu_state - Sets low power link up state for D3
+ *  igb_set_d3_lplu_state - Sets low power link up state for D3
  *  @hw: pointer to the HW structure
  *  @active: boolean used to enable/disable lplu
  *
@@ -1146,7 +1146,7 @@ out:
 }
 
 /**
- *  e1000_check_downshift - Checks whether a downshift in speed occured
+ *  igb_check_downshift - Checks whether a downshift in speed occured
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns 1
@@ -1188,7 +1188,7 @@ out:
 }
 
 /**
- *  e1000_check_polarity_m88 - Checks the polarity.
+ *  igb_check_polarity_m88 - Checks the polarity.
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
@@ -1212,7 +1212,7 @@ static s32 igb_check_polarity_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_polarity_igp - Checks the polarity.
+ *  igb_check_polarity_igp - Checks the polarity.
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
@@ -1260,7 +1260,7 @@ out:
 }
 
 /**
- *  e1000_wait_autoneg - Wait for auto-neg compeletion
+ *  igb_wait_autoneg - Wait for auto-neg compeletion
  *  @hw: pointer to the HW structure
  *
  *  Waits for auto-negotiation to complete or for the auto-negotiation time
@@ -1292,7 +1292,7 @@ static s32 igb_wait_autoneg(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_has_link - Polls PHY for link
+ *  igb_phy_has_link - Polls PHY for link
  *  @hw: pointer to the HW structure
  *  @iterations: number of times to poll for link
  *  @usec_interval: delay between polling attempts
@@ -1332,7 +1332,7 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 }
 
 /**
- *  e1000_get_cable_length_m88 - Determine cable length for m88 PHY
+ *  igb_get_cable_length_m88 - Determine cable length for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY specific status register to retrieve the cable length
@@ -1369,7 +1369,7 @@ out:
 }
 
 /**
- *  e1000_get_cable_length_igp_2 - Determine cable length for igp2 PHY
+ *  igb_get_cable_length_igp_2 - Determine cable length for igp2 PHY
  *  @hw: pointer to the HW structure
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
@@ -1442,7 +1442,7 @@ out:
 }
 
 /**
- *  e1000_get_phy_info_m88 - Retrieve PHY information
+ *  igb_get_phy_info_m88 - Retrieve PHY information
  *  @hw: pointer to the HW structure
  *
  *  Valid for only copper links.  Read the PHY status register (sticky read)
@@ -1523,7 +1523,7 @@ out:
 }
 
 /**
- *  e1000_get_phy_info_igp - Retrieve igp PHY information
+ *  igb_get_phy_info_igp - Retrieve igp PHY information
  *  @hw: pointer to the HW structure
  *
  *  Read PHY status to determine if link is up.  If link is up, then
@@ -1590,7 +1590,7 @@ out:
 }
 
 /**
- *  e1000_phy_sw_reset - PHY software reset
+ *  igb_phy_sw_reset - PHY software reset
  *  @hw: pointer to the HW structure
  *
  *  Does a software reset of the PHY by reading the PHY control register and
@@ -1617,7 +1617,7 @@ out:
 }
 
 /**
- *  e1000_phy_hw_reset - PHY hardware reset
+ *  igb_phy_hw_reset - PHY hardware reset
  *  @hw: pointer to the HW structure
  *
  *  Verify the reset block is not blocking us from resetting.  Acquire
@@ -1663,7 +1663,7 @@ out:
 /* Internal function pointers */
 
 /**
- *  e1000_get_phy_cfg_done - Generic PHY configuration done
+ *  igb_get_phy_cfg_done - Generic PHY configuration done
  *  @hw: pointer to the HW structure
  *
  *  Return success if silicon family did not implement a family specific
@@ -1678,7 +1678,7 @@ static s32 igb_get_phy_cfg_done(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_phy - Generic release PHY
+ *  igb_release_phy - Generic release PHY
  *  @hw: pointer to the HW structure
  *
  *  Return if silicon family does not require a semaphore when accessing the
@@ -1691,7 +1691,7 @@ static void igb_release_phy(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_phy - Generic acquire PHY
+ *  igb_acquire_phy - Generic acquire PHY
  *  @hw: pointer to the HW structure
  *
  *  Return success if silicon family does not require a semaphore when
@@ -1706,7 +1706,7 @@ static s32 igb_acquire_phy(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex - Generic force PHY speed/duplex
+ *  igb_phy_force_speed_duplex - Generic force PHY speed/duplex
  *  @hw: pointer to the HW structure
  *
  *  When the silicon family has not implemented a forced speed/duplex
@@ -1721,7 +1721,7 @@ s32 igb_phy_force_speed_duplex(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_init_script_igp3 - Inits the IGP3 PHY
+ *  igb_phy_init_script_igp3 - Inits the IGP3 PHY
  *  @hw: pointer to the HW structure
  *
  *  Initializes a Intel Gigabit PHY3 when an EEPROM is not present.


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
