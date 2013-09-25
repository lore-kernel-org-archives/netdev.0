From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] iwlegacy: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:25 -0700
Message-ID: <6890ba72f5e1061261e26e04dcb936da4d10a1b1.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlegacy/3945.h   | 82 ++++++++++++++++------------------
 drivers/net/wireless/iwlegacy/4965.h   |  2 +-
 drivers/net/wireless/iwlegacy/common.h | 66 +++++++++++++--------------
 3 files changed, 73 insertions(+), 77 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945.h b/drivers/net/wireless/iwlegacy/3945.h
index 9a8703d..00030d4 100644
--- a/drivers/net/wireless/iwlegacy/3945.h
+++ b/drivers/net/wireless/iwlegacy/3945.h
@@ -189,15 +189,14 @@ struct il3945_ibss_seq {
  * for use by iwl-*.c
  *
  *****************************************************************************/
-extern int il3945_calc_db_from_ratio(int sig_ratio);
-extern void il3945_rx_replenish(void *data);
-extern void il3945_rx_queue_reset(struct il_priv *il, struct il_rx_queue *rxq);
-extern unsigned int il3945_fill_beacon_frame(struct il_priv *il,
-					     struct ieee80211_hdr *hdr,
-					     int left);
-extern int il3945_dump_nic_event_log(struct il_priv *il, bool full_log,
-				     char **buf, bool display);
-extern void il3945_dump_nic_error_log(struct il_priv *il);
+int il3945_calc_db_from_ratio(int sig_ratio);
+void il3945_rx_replenish(void *data);
+void il3945_rx_queue_reset(struct il_priv *il, struct il_rx_queue *rxq);
+unsigned int il3945_fill_beacon_frame(struct il_priv *il,
+				      struct ieee80211_hdr *hdr, int left);
+int il3945_dump_nic_event_log(struct il_priv *il, bool full_log, char **buf,
+			      bool display);
+void il3945_dump_nic_error_log(struct il_priv *il);
 
 /******************************************************************************
  *
@@ -215,39 +214,36 @@ extern void il3945_dump_nic_error_log(struct il_priv *il);
  * il3945_mac_     <-- mac80211 callback
  *
  ****************************************************************************/
-extern void il3945_hw_handler_setup(struct il_priv *il);
-extern void il3945_hw_setup_deferred_work(struct il_priv *il);
-extern void il3945_hw_cancel_deferred_work(struct il_priv *il);
-extern int il3945_hw_rxq_stop(struct il_priv *il);
-extern int il3945_hw_set_hw_params(struct il_priv *il);
-extern int il3945_hw_nic_init(struct il_priv *il);
-extern int il3945_hw_nic_stop_master(struct il_priv *il);
-extern void il3945_hw_txq_ctx_free(struct il_priv *il);
-extern void il3945_hw_txq_ctx_stop(struct il_priv *il);
-extern int il3945_hw_nic_reset(struct il_priv *il);
-extern int il3945_hw_txq_attach_buf_to_tfd(struct il_priv *il,
-					   struct il_tx_queue *txq,
-					   dma_addr_t addr, u16 len, u8 reset,
-					   u8 pad);
-extern void il3945_hw_txq_free_tfd(struct il_priv *il, struct il_tx_queue *txq);
-extern int il3945_hw_get_temperature(struct il_priv *il);
-extern int il3945_hw_tx_queue_init(struct il_priv *il, struct il_tx_queue *txq);
-extern unsigned int il3945_hw_get_beacon_cmd(struct il_priv *il,
-					     struct il3945_frame *frame,
-					     u8 rate);
+void il3945_hw_handler_setup(struct il_priv *il);
+void il3945_hw_setup_deferred_work(struct il_priv *il);
+void il3945_hw_cancel_deferred_work(struct il_priv *il);
+int il3945_hw_rxq_stop(struct il_priv *il);
+int il3945_hw_set_hw_params(struct il_priv *il);
+int il3945_hw_nic_init(struct il_priv *il);
+int il3945_hw_nic_stop_master(struct il_priv *il);
+void il3945_hw_txq_ctx_free(struct il_priv *il);
+void il3945_hw_txq_ctx_stop(struct il_priv *il);
+int il3945_hw_nic_reset(struct il_priv *il);
+int il3945_hw_txq_attach_buf_to_tfd(struct il_priv *il, struct il_tx_queue *txq,
+				    dma_addr_t addr, u16 len, u8 reset, u8 pad);
+void il3945_hw_txq_free_tfd(struct il_priv *il, struct il_tx_queue *txq);
+int il3945_hw_get_temperature(struct il_priv *il);
+int il3945_hw_tx_queue_init(struct il_priv *il, struct il_tx_queue *txq);
+unsigned int il3945_hw_get_beacon_cmd(struct il_priv *il,
+				      struct il3945_frame *frame, u8 rate);
 void il3945_hw_build_tx_cmd_rate(struct il_priv *il, struct il_device_cmd *cmd,
 				 struct ieee80211_tx_info *info,
 				 struct ieee80211_hdr *hdr, int sta_id);
-extern int il3945_hw_reg_send_txpower(struct il_priv *il);
-extern int il3945_hw_reg_set_txpower(struct il_priv *il, s8 power);
-extern void il3945_hdl_stats(struct il_priv *il, struct il_rx_buf *rxb);
+int il3945_hw_reg_send_txpower(struct il_priv *il);
+int il3945_hw_reg_set_txpower(struct il_priv *il, s8 power);
+void il3945_hdl_stats(struct il_priv *il, struct il_rx_buf *rxb);
 void il3945_hdl_c_stats(struct il_priv *il, struct il_rx_buf *rxb);
-extern void il3945_disable_events(struct il_priv *il);
-extern int il4965_get_temperature(const struct il_priv *il);
-extern void il3945_post_associate(struct il_priv *il);
-extern void il3945_config_ap(struct il_priv *il);
+void il3945_disable_events(struct il_priv *il);
+int il4965_get_temperature(const struct il_priv *il);
+void il3945_post_associate(struct il_priv *il);
+void il3945_config_ap(struct il_priv *il);
 
-extern int il3945_commit_rxon(struct il_priv *il);
+int il3945_commit_rxon(struct il_priv *il);
 
 /**
  * il3945_hw_find_station - Find station id for a given BSSID
@@ -257,14 +253,14 @@ extern int il3945_commit_rxon(struct il_priv *il);
  * not yet been merged into a single common layer for managing the
  * station tables.
  */
-extern u8 il3945_hw_find_station(struct il_priv *il, const u8 * bssid);
+u8 il3945_hw_find_station(struct il_priv *il, const u8 *bssid);
 
-extern __le32 il3945_get_antenna_flags(const struct il_priv *il);
-extern int il3945_init_hw_rate_table(struct il_priv *il);
-extern void il3945_reg_txpower_periodic(struct il_priv *il);
-extern int il3945_txpower_set_from_eeprom(struct il_priv *il);
+__le32 il3945_get_antenna_flags(const struct il_priv *il);
+int il3945_init_hw_rate_table(struct il_priv *il);
+void il3945_reg_txpower_periodic(struct il_priv *il);
+int il3945_txpower_set_from_eeprom(struct il_priv *il);
 
-extern int il3945_rs_next_rate(struct il_priv *il, int rate);
+int il3945_rs_next_rate(struct il_priv *il, int rate);
 
 /* scanning */
 int il3945_request_scan(struct il_priv *il, struct ieee80211_vif *vif);
diff --git a/drivers/net/wireless/iwlegacy/4965.h b/drivers/net/wireless/iwlegacy/4965.h
index 1b15b0b..337dfcf 100644
--- a/drivers/net/wireless/iwlegacy/4965.h
+++ b/drivers/net/wireless/iwlegacy/4965.h
@@ -272,7 +272,7 @@ il4965_hw_valid_rtc_data_addr(u32 addr)
 	((t) < IL_TX_POWER_TEMPERATURE_MIN || \
 	 (t) > IL_TX_POWER_TEMPERATURE_MAX)
 
-extern void il4965_temperature_calib(struct il_priv *il);
+void il4965_temperature_calib(struct il_priv *il);
 /********************* END TEMPERATURE ***************************************/
 
 /********************* START TXPOWER *****************************************/
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 83f8ed8..ad123d6 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -858,9 +858,9 @@ struct il_hw_params {
  * il4965_mac_     <-- mac80211 callback
  *
  ****************************************************************************/
-extern void il4965_update_chain_flags(struct il_priv *il);
+void il4965_update_chain_flags(struct il_priv *il);
 extern const u8 il_bcast_addr[ETH_ALEN];
-extern int il_queue_space(const struct il_queue *q);
+int il_queue_space(const struct il_queue *q);
 static inline int
 il_queue_used(const struct il_queue *q, int i)
 {
@@ -1727,7 +1727,7 @@ int il_alloc_txq_mem(struct il_priv *il);
 void il_free_txq_mem(struct il_priv *il);
 
 #ifdef CONFIG_IWLEGACY_DEBUGFS
-extern void il_update_stats(struct il_priv *il, bool is_tx, __le16 fc, u16 len);
+void il_update_stats(struct il_priv *il, bool is_tx, __le16 fc, u16 len);
 #else
 static inline void
 il_update_stats(struct il_priv *il, bool is_tx, __le16 fc, u16 len)
@@ -1760,12 +1760,12 @@ void il_chswitch_done(struct il_priv *il, bool is_success);
 /*****************************************************
 * TX
 ******************************************************/
-extern void il_txq_update_write_ptr(struct il_priv *il, struct il_tx_queue *txq);
-extern int il_tx_queue_init(struct il_priv *il, u32 txq_id);
-extern void il_tx_queue_reset(struct il_priv *il, u32 txq_id);
-extern void il_tx_queue_unmap(struct il_priv *il, int txq_id);
-extern void il_tx_queue_free(struct il_priv *il, int txq_id);
-extern void il_setup_watchdog(struct il_priv *il);
+void il_txq_update_write_ptr(struct il_priv *il, struct il_tx_queue *txq);
+int il_tx_queue_init(struct il_priv *il, u32 txq_id);
+void il_tx_queue_reset(struct il_priv *il, u32 txq_id);
+void il_tx_queue_unmap(struct il_priv *il, int txq_id);
+void il_tx_queue_free(struct il_priv *il, int txq_id);
+void il_setup_watchdog(struct il_priv *il);
 /*****************************************************
  * TX power
  ****************************************************/
@@ -1931,10 +1931,10 @@ il_is_ready_rf(struct il_priv *il)
 	return il_is_ready(il);
 }
 
-extern void il_send_bt_config(struct il_priv *il);
-extern int il_send_stats_request(struct il_priv *il, u8 flags, bool clear);
-extern void il_apm_stop(struct il_priv *il);
-extern void _il_apm_stop(struct il_priv *il);
+void il_send_bt_config(struct il_priv *il);
+int il_send_stats_request(struct il_priv *il, u8 flags, bool clear);
+void il_apm_stop(struct il_priv *il);
+void _il_apm_stop(struct il_priv *il);
 
 int il_apm_init(struct il_priv *il);
 
@@ -1968,15 +1968,15 @@ void il_tx_cmd_protection(struct il_priv *il, struct ieee80211_tx_info *info,
 
 irqreturn_t il_isr(int irq, void *data);
 
-extern void il_set_bit(struct il_priv *p, u32 r, u32 m);
-extern void il_clear_bit(struct il_priv *p, u32 r, u32 m);
-extern bool _il_grab_nic_access(struct il_priv *il);
-extern int _il_poll_bit(struct il_priv *il, u32 addr, u32 bits, u32 mask, int timeout);
-extern int il_poll_bit(struct il_priv *il, u32 addr, u32 mask, int timeout);
-extern u32 il_rd_prph(struct il_priv *il, u32 reg);
-extern void il_wr_prph(struct il_priv *il, u32 addr, u32 val);
-extern u32 il_read_targ_mem(struct il_priv *il, u32 addr);
-extern void il_write_targ_mem(struct il_priv *il, u32 addr, u32 val);
+void il_set_bit(struct il_priv *p, u32 r, u32 m);
+void il_clear_bit(struct il_priv *p, u32 r, u32 m);
+bool _il_grab_nic_access(struct il_priv *il);
+int _il_poll_bit(struct il_priv *il, u32 addr, u32 bits, u32 mask, int timeout);
+int il_poll_bit(struct il_priv *il, u32 addr, u32 mask, int timeout);
+u32 il_rd_prph(struct il_priv *il, u32 reg);
+void il_wr_prph(struct il_priv *il, u32 addr, u32 val);
+u32 il_read_targ_mem(struct il_priv *il, u32 addr);
+void il_write_targ_mem(struct il_priv *il, u32 addr, u32 val);
 
 static inline void
 _il_write8(struct il_priv *il, u32 ofs, u8 val)
@@ -2868,13 +2868,13 @@ il4965_first_antenna(u8 mask)
  * The specific throughput table used is based on the type of network
  * the associated with, including A, B, G, and G w/ TGG protection
  */
-extern void il3945_rate_scale_init(struct ieee80211_hw *hw, s32 sta_id);
+void il3945_rate_scale_init(struct ieee80211_hw *hw, s32 sta_id);
 
 /* Initialize station's rate scaling information after adding station */
-extern void il4965_rs_rate_init(struct il_priv *il, struct ieee80211_sta *sta,
-				u8 sta_id);
-extern void il3945_rs_rate_init(struct il_priv *il, struct ieee80211_sta *sta,
-				u8 sta_id);
+void il4965_rs_rate_init(struct il_priv *il, struct ieee80211_sta *sta,
+			 u8 sta_id);
+void il3945_rs_rate_init(struct il_priv *il, struct ieee80211_sta *sta,
+			 u8 sta_id);
 
 /**
  * il_rate_control_register - Register the rate control algorithm callbacks
@@ -2886,8 +2886,8 @@ extern void il3945_rs_rate_init(struct il_priv *il, struct ieee80211_sta *sta,
  * ieee80211_register_hw
  *
  */
-extern int il4965_rate_control_register(void);
-extern int il3945_rate_control_register(void);
+int il4965_rate_control_register(void);
+int il3945_rate_control_register(void);
 
 /**
  * il_rate_control_unregister - Unregister the rate control callbacks
@@ -2895,11 +2895,11 @@ extern int il3945_rate_control_register(void);
  * This should be called after calling ieee80211_unregister_hw, but before
  * the driver is unloaded.
  */
-extern void il4965_rate_control_unregister(void);
-extern void il3945_rate_control_unregister(void);
+void il4965_rate_control_unregister(void);
+void il3945_rate_control_unregister(void);
 
-extern int il_power_update_mode(struct il_priv *il, bool force);
-extern void il_power_initialize(struct il_priv *il);
+int il_power_update_mode(struct il_priv *il, bool force);
+void il_power_initialize(struct il_priv *il);
 
 extern u32 il_debug_level;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
