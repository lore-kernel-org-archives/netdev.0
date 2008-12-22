From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 13/27] drivers/net/ixgbe: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:16:50 +0100
Message-ID: <20081222191650.11807.36848.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbYLVTQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:16:56 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/ixgbe/ixgbe_82598.c:180:5: warning: symbol 'ixgbe_get_copper_link_capabilities_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:245:5: warning: symbol 'ixgbe_setup_fc_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:729:5: warning: symbol 'ixgbe_set_vmdq_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:773:5: warning: symbol 'ixgbe_set_vfta_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:897:5: warning: symbol 'ixgbe_read_analog_reg8_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:919:5: warning: symbol 'ixgbe_write_analog_reg8_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:940:5: warning: symbol 'ixgbe_read_i2c_eeprom_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_82598.c:1000:5: warning: symbol 'ixgbe_get_supported_physical_layer_82598' was not declared. Should it be static?
  drivers/net/ixgbe/ixgbe_dcb_82598.c:100:5: warning: symbol 'ixgbe_dcb_config_packet_buffers_82598' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/ixgbe/ixgbe_82598.c     |   24 ++++++++++++------------
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    4 ++--
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 7e09dab..ad5699d 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -177,9 +177,9 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
  *
  *  Determines the link capabilities by reading the AUTOC register.
  **/
-s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
-                                             ixgbe_link_speed *speed,
-                                             bool *autoneg)
+static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
+						    ixgbe_link_speed *speed,
+						    bool *autoneg)
 {
 	s32 status = IXGBE_ERR_LINK_SETUP;
 	u16 speed_ability;
@@ -242,7 +242,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
  *  Configures the flow control settings based on SW configuration.  This
  *  function is used for 802.3x flow control configuration only.
  **/
-s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
+static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 {
 	u32 frctl_reg;
 	u32 rmcs_reg;
@@ -726,7 +726,7 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
  *  @rar: receive address register index to associate with a VMDq index
  *  @vmdq: VMDq set index
  **/
-s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+static s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 {
 	u32 rar_high;
 
@@ -770,8 +770,8 @@ static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
  *
  *  Turn on/off specified VLAN in the VLAN filter table.
  **/
-s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
-                         bool vlan_on)
+static s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+				bool vlan_on)
 {
 	u32 regindex;
 	u32 bitindex;
@@ -894,7 +894,7 @@ static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index)
  *
  *  Performs read operation to Atlas analog register specified.
  **/
-s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
+static s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
 {
 	u32  atlas_ctl;
 
@@ -916,7 +916,7 @@ s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
  *
  *  Performs write operation to Atlas analog register specified.
  **/
-s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
+static s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
 {
 	u32  atlas_ctl;
 
@@ -937,8 +937,8 @@ s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
  *
  *  Performs byte read operation to SFP module's EEPROM over I2C interface.
  **/
-s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
-                                u8 *eeprom_data)
+static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
+				       u8 *eeprom_data)
 {
 	s32 status = 0;
 	u16 sfp_addr = 0;
@@ -997,7 +997,7 @@ out:
  *
  *  Determines physical layer capabilities of the current configuration.
  **/
-s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 {
 	s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index fce6867..2c046b0 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -97,8 +97,8 @@ s32 ixgbe_dcb_get_pfc_stats_82598(struct ixgbe_hw *hw,
  *
  * Configure packet buffers for DCB mode.
  */
-s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
-                                          struct ixgbe_dcb_config *dcb_config)
+static s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
+						 struct ixgbe_dcb_config *dcb_config)
 {
 	s32 ret_val = 0;
 	u32 value = IXGBE_RXPBSIZE_64KB;

