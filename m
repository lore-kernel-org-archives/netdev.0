From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: declare functions as static
Date: Wed, 13 Oct 2010 01:20:59 -0700
Message-ID: <20101013082056.24491.93910.stgit@localhost.localdomain>
References: <20101013081759.24491.46846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:36045 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753123Ab0JMIVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 04:21:21 -0400
In-Reply-To: <20101013081759.24491.46846.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Following patch fixes warnings reported by `make namespacecheck`

Reported by Stephen Hemminger

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c     |   30 +++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_common.c    |    5 +++--
 drivers/net/ixgbe/ixgbe_common.h    |    1 -
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    8 ++++----
 drivers/net/ixgbe/ixgbe_dcb_82598.h |   11 -----------
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   12 ++++++------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |   12 ------------
 drivers/net/ixgbe/ixgbe_mbx.c       |   19 +++----------------
 drivers/net/ixgbe/ixgbe_mbx.h       |    3 ---
 drivers/net/ixgbe/ixgbe_sriov.c     |   17 +++++++++--------
 drivers/net/ixgbe/ixgbe_sriov.h     |    8 --------
 11 files changed, 40 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 344c5d6..0bd8fbb 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -39,20 +39,20 @@
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
 
-void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
-void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
-void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
-s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
-                                          ixgbe_link_speed speed,
-                                          bool autoneg,
-                                          bool autoneg_wait_to_complete);
+static void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
+static void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
+static void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
+static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
+						 ixgbe_link_speed speed,
+						 bool autoneg,
+						 bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
                                            ixgbe_link_speed speed,
                                            bool autoneg,
                                            bool autoneg_wait_to_complete);
-s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
-                               bool autoneg_wait_to_complete);
-s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
+				      bool autoneg_wait_to_complete);
+static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
                                ixgbe_link_speed speed,
                                bool autoneg,
                                bool autoneg_wait_to_complete);
@@ -369,7 +369,7 @@ out:
  *  Configures link settings based on values in the ixgbe_hw struct.
  *  Restarts the link.  Performs autonegotiation if needed.
  **/
-s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
                                bool autoneg_wait_to_complete)
 {
 	u32 autoc_reg;
@@ -418,7 +418,7 @@ s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
   *  PHY states.  This includes selectively shutting down the Tx
   *  laser on the PHY, effectively halting physical link.
   **/
-void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+static void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
 
@@ -437,7 +437,7 @@ void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
  *  PHY states.  This includes selectively turning on the Tx
  *  laser on the PHY, effectively starting physical link.
  **/
-void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+static void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
 
@@ -460,7 +460,7 @@ void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
  *  end.  This is consistent with true clause 37 autoneg, which also
  *  involves a loss of signal.
  **/
-void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+static void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	hw_dbg(hw, "ixgbe_flap_tx_laser_multispeed_fiber\n");
 
@@ -729,7 +729,7 @@ out:
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
                                ixgbe_link_speed speed, bool autoneg,
                                bool autoneg_wait_to_complete)
 {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 939e60f..e3eca13 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -52,6 +52,7 @@ static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
+static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 /**
  *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
@@ -637,7 +638,7 @@ out:
  *  Polls the status bit (bit 1) of the EERD or EEWR to determine when the
  *  read or write is done respectively.
  **/
-s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
+static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
 {
 	u32 i;
 	u32 reg;
@@ -2449,7 +2450,7 @@ s32 ixgbe_init_uta_tables_generic(struct ixgbe_hw *hw)
  *  return the VLVF index where this VLAN id should be placed
  *
  **/
-s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan)
+static s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan)
 {
 	u32 bits = 0;
 	u32 first_empty_slot = 0;
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 5cf15aa..424c223 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -52,7 +52,6 @@ s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
 s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
                                            u16 *checksum_val);
 s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw);
-s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
                           u32 enable_addr);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 6e9c8bb..50288bc 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -78,7 +78,7 @@ static s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
  *
  * Configure Rx Data Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
                                       struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc    *p;
@@ -135,7 +135,7 @@ s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
  *
  * Configure Tx Descriptor Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
                                            struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc *p;
@@ -183,7 +183,7 @@ s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
  *
  * Configure Tx Data Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
                                            struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc *p;
@@ -296,7 +296,7 @@ out:
  * Configure queue statistics registers, all queues belonging to same traffic
  * class uses a single set of queue statistics counters.
  */
-s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
 {
 	u32 reg = 0;
 	u8  i   = 0;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index def907f..abc03cc 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -73,17 +73,6 @@
 /* DCB PFC functions */
 s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
-/* DCB traffic class stats */
-s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *);
-
-/* DCB config arbiters */
-s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *,
-                                           struct ixgbe_dcb_config *);
-s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *,
-                                           struct ixgbe_dcb_config *);
-s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *,
-                                      struct ixgbe_dcb_config *);
-
 /* DCB hw initialization */
 s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 1364718..67c219f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -37,7 +37,7 @@
  *
  * Configure packet buffers for DCB mode.
  */
-s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
                                           struct ixgbe_dcb_config *dcb_config)
 {
 	s32 ret_val = 0;
@@ -79,7 +79,7 @@ s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
  *
  * Configure Rx Packet Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
                                       struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc    *p;
@@ -134,7 +134,7 @@ s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
  *
  * Configure Tx Descriptor Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
                                            struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc *p;
@@ -181,7 +181,7 @@ s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
  *
  * Configure Tx Packet Arbiter and credits for each traffic class.
  */
-s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
+static s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
                                            struct ixgbe_dcb_config *dcb_config)
 {
 	struct tc_bw_alloc *p;
@@ -302,7 +302,7 @@ out:
  * Configure queue statistics registers, all queues belonging to same traffic
  * class uses a single set of queue statistics counters.
  */
-s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
 {
 	u32 reg = 0;
 	u8  i   = 0;
@@ -355,7 +355,7 @@ s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
  *
  * Configure general DCB parameters.
  */
-s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
 {
 	u32 reg;
 	u32 q;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 88819b2..18d7fbf 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -102,18 +102,6 @@
 s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
                                struct ixgbe_dcb_config *dcb_config);
 
-/* DCB traffic class stats */
-s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw);
-
-/* DCB config arbiters */
-s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config);
-s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config);
-s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
-                                      struct ixgbe_dcb_config *dcb_config);
-
-
 /* DCB hw initialization */
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
                               struct ixgbe_dcb_config *config);
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index d75f914..435e028 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -200,7 +200,8 @@ out:
  *  returns SUCCESS if it successfully received a message notification and
  *  copied it into the receive buffer.
  **/
-s32 ixgbe_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+static s32 ixgbe_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size,
+				 u16 mbx_id)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	s32 ret_val = IXGBE_ERR_MBX;
@@ -227,7 +228,7 @@ out:
  *  returns SUCCESS if it successfully copied message into the buffer and
  *  received an ack to that message within delay * timeout period
  **/
-s32 ixgbe_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size,
+static s32 ixgbe_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size,
                            u16 mbx_id)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
@@ -247,20 +248,6 @@ out:
 	return ret_val;
 }
 
-/**
- *  ixgbe_init_mbx_ops_generic - Initialize MB function pointers
- *  @hw: pointer to the HW structure
- *
- *  Setup the mailbox read and write message function pointers
- **/
-void ixgbe_init_mbx_ops_generic(struct ixgbe_hw *hw)
-{
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
-
-	mbx->ops.read_posted = ixgbe_read_posted_mbx;
-	mbx->ops.write_posted = ixgbe_write_posted_mbx;
-}
-
 static s32 ixgbe_check_for_bit_pf(struct ixgbe_hw *hw, u32 mask, s32 index)
 {
 	u32 mbvficr = IXGBE_READ_REG(hw, IXGBE_MBVFICR(index));
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index be7ab33..c5ae4b4 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -83,12 +83,9 @@
 
 s32 ixgbe_read_mbx(struct ixgbe_hw *, u32 *, u16, u16);
 s32 ixgbe_write_mbx(struct ixgbe_hw *, u32 *, u16, u16);
-s32 ixgbe_read_posted_mbx(struct ixgbe_hw *, u32 *, u16, u16);
-s32 ixgbe_write_posted_mbx(struct ixgbe_hw *, u32 *, u16, u16);
 s32 ixgbe_check_for_msg(struct ixgbe_hw *, u16);
 s32 ixgbe_check_for_ack(struct ixgbe_hw *, u16);
 s32 ixgbe_check_for_rst(struct ixgbe_hw *, u16);
-void ixgbe_init_mbx_ops_generic(struct ixgbe_hw *hw);
 void ixgbe_init_mbx_params_pf(struct ixgbe_hw *);
 
 extern struct ixgbe_mbx_operations mbx_ops_82599;
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 49661a1..a6b720a 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -43,8 +43,8 @@
 
 #include "ixgbe_sriov.h"
 
-int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
-			    int entries, u16 *hash_list, u32 vf)
+static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
+				   int entries, u16 *hash_list, u32 vf)
 {
 	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -104,13 +104,14 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 	}
 }
 
-int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid, u32 vf)
+static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
+			     u32 vf)
 {
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 
 
-void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
+static void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 {
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
 	vmolr |= (IXGBE_VMOLR_ROMPE |
@@ -134,7 +135,7 @@ static void ixgbe_set_vmvir(struct ixgbe_adapter *adapter, u32 vid, u32 vf)
 		IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), 0);
 }
 
-inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
+static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
@@ -162,8 +163,8 @@ inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	hw->mac.ops.clear_rar(hw, rar_entry);
 }
 
-int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
-                          int vf, unsigned char *mac_addr)
+static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
+			    int vf, unsigned char *mac_addr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
@@ -197,7 +198,7 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 	return 0;
 }
 
-inline void ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
+static inline void ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 reg;
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index 184730e..9a424bb 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -28,16 +28,8 @@
 #ifndef _IXGBE_SRIOV_H_
 #define _IXGBE_SRIOV_H_
 
-int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
-                            int entries, u16 *hash_list, u32 vf);
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
-int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid, u32 vf);
-void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe);
-void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf);
-void ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf);
 void ixgbe_msg_task(struct ixgbe_adapter *adapter);
-int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
-                     int vf, unsigned char *mac_addr);
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask);
 void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);

