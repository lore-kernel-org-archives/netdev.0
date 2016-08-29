From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath10k: Spelling and miscellaneous neatening
Date: Mon, 29 Aug 2016 10:05:51 -0700
Message-ID: <95a6b65277914d88178ed2b15e182455067cca60.1472490319.git.joe@perches.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct some trivial comment typos.
Remove unnecessary parentheses in a long line.
Convert a return; before the end of a void function definition to just ;

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath10k/ce.c        |  2 +-
 drivers/net/wireless/ath/ath10k/core.c      |  2 +-
 drivers/net/wireless/ath/ath10k/htt.h       |  8 ++++----
 drivers/net/wireless/ath/ath10k/hw.c        |  2 +-
 drivers/net/wireless/ath/ath10k/hw.h        |  2 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h |  2 +-
 drivers/net/wireless/ath/ath10k/wmi.h       | 24 ++++++++++++------------
 7 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ce.c b/drivers/net/wireless/ath/ath10k/ce.c
index 9fb8d74..cea9684 100644
--- a/drivers/net/wireless/ath/ath10k/ce.c
+++ b/drivers/net/wireless/ath/ath10k/ce.c
@@ -39,7 +39,7 @@
  * chooses what to send (buffer address, length). The destination
  * side keeps a supply of "anonymous receive buffers" available and
  * it handles incoming data as it arrives (when the destination
- * recieves an interrupt).
+ * receives an interrupt).
  *
  * The sender may send a simple buffer (address/length) or it may
  * send a small list of buffers.  When a small list is sent, hardware
diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index e889829..1e8147a 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -2118,7 +2118,7 @@ err:
 	/* TODO: It's probably a good idea to release device from the driver
 	 * but calling device_release_driver() here will cause a deadlock.
 	 */
-	return;
+	;
 }
 
 int ath10k_core_register(struct ath10k *ar, u32 chip_id)
diff --git a/drivers/net/wireless/ath/ath10k/htt.h b/drivers/net/wireless/ath/ath10k/htt.h
index 430a83e..cedb4e8 100644
--- a/drivers/net/wireless/ath/ath10k/htt.h
+++ b/drivers/net/wireless/ath/ath10k/htt.h
@@ -595,7 +595,7 @@ enum htt_rx_mpdu_status {
 	/* only accept EAPOL frames */
 	HTT_RX_IND_MPDU_STATUS_UNAUTH_PEER,
 	HTT_RX_IND_MPDU_STATUS_OUT_OF_SYNC,
-	/* Non-data in promiscous mode */
+	/* Non-data in promiscuous mode */
 	HTT_RX_IND_MPDU_STATUS_MGMT_CTRL,
 	HTT_RX_IND_MPDU_STATUS_TKIP_MIC_ERR,
 	HTT_RX_IND_MPDU_STATUS_DECRYPT_ERR,
@@ -900,7 +900,7 @@ struct htt_rx_in_ord_ind {
  *     Purpose: indicate how many 32-bit integers follow the message header
  *   - NUM_CHARS
  *     Bits 31:16
- *     Purpose: indicate how many 8-bit charaters follow the series of integers
+ *     Purpose: indicate how many 8-bit characters follow the series of integers
  */
 struct htt_rx_test {
 	u8 num_ints;
@@ -1042,10 +1042,10 @@ struct htt_dbg_stats_wal_tx_stats {
 	/* illegal rate phy errors  */
 	__le32 illgl_rate_phy_err;
 
-	/* wal pdev continous xretry */
+	/* wal pdev continuous xretry */
 	__le32 pdev_cont_xretry;
 
-	/* wal pdev continous xretry */
+	/* wal pdev continuous xretry */
 	__le32 pdev_tx_timeout;
 
 	/* wal pdev resets  */
diff --git a/drivers/net/wireless/ath/ath10k/hw.c b/drivers/net/wireless/ath/ath10k/hw.c
index f903d46..ed917cb 100644
--- a/drivers/net/wireless/ath/ath10k/hw.c
+++ b/drivers/net/wireless/ath/ath10k/hw.c
@@ -85,7 +85,7 @@ const struct ath10k_hw_regs qca99x0_regs = {
 	.ce7_base_address			= 0x0004bc00,
 	/* Note: qca99x0 supports upto 12 Copy Engines. Other than address of
 	 * CE0 and CE1 no other copy engine is directly referred in the code.
-	 * It is not really neccessary to assign address for newly supported
+	 * It is not really necessary to assign address for newly supported
 	 * CEs in this address table.
 	 *	Copy Engine		Address
 	 *	CE8			0x0004c000
diff --git a/drivers/net/wireless/ath/ath10k/hw.h b/drivers/net/wireless/ath/ath10k/hw.h
index e014cd7..93ca128 100644
--- a/drivers/net/wireless/ath/ath10k/hw.h
+++ b/drivers/net/wireless/ath/ath10k/hw.h
@@ -284,7 +284,7 @@ void ath10k_hw_fill_survey_time(struct ath10k *ar, struct survey_info *survey,
 #define QCA_REV_9377(ar) ((ar)->hw_rev == ATH10K_HW_QCA9377)
 #define QCA_REV_40XX(ar) ((ar)->hw_rev == ATH10K_HW_QCA4019)
 
-/* Known pecularities:
+/* Known peculiarities:
  *  - raw appears in nwifi decap, raw and nwifi appear in ethernet decap
  *  - raw have FCS, nwifi doesn't
  *  - ethernet frames have 802.11 header decapped and parts (base hdr, cipher
diff --git a/drivers/net/wireless/ath/ath10k/targaddrs.h b/drivers/net/wireless/ath/ath10k/targaddrs.h
index aaf53a8..a47cab4 100644
--- a/drivers/net/wireless/ath/ath10k/targaddrs.h
+++ b/drivers/net/wireless/ath/ath10k/targaddrs.h
@@ -405,7 +405,7 @@ Fw Mode/SubMode Mask
  * 1. target firmware would check magic number and if it's a match, firmware
  *    would consider the bits[0:15] are valid and base on that to calculate
  *    the end of DRAM. Early allocation would be located at that area and
- *    may be reclaimed when necesary
+ *    may be reclaimed when necessary
  * 2. if no magic number is found, early allocation would happen at "_end"
  *    symbol of ROM which is located before the app-data and might NOT be
  *    re-claimable. If this is adopted, link script should keep this in
diff --git a/drivers/net/wireless/ath/ath10k/wmi.h b/drivers/net/wireless/ath/ath10k/wmi.h
index 3ef4688..452790e 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.h
+++ b/drivers/net/wireless/ath/ath10k/wmi.h
@@ -55,7 +55,7 @@
  *    type.
  *
  * 6. Comment each parameter part of the WMI command/event structure by
- *    using the 2 stars at the begining of C comment instead of one star to
+ *    using the 2 stars at the beginning of C comment instead of one star to
  *    enable HTML document generation using Doxygen.
  *
  */
@@ -2082,7 +2082,7 @@ struct wmi_resource_config {
 	 * In offload mode target supports features like WOW, chatter and
 	 * other protocol offloads. In order to support them some
 	 * functionalities like reorder buffering, PN checking need to be
-	 * done in target. This determines maximum number of peers suported
+	 * done in target. This determines maximum number of peers supported
 	 * by target in offload mode
 	 */
 	__le32 num_offload_peers;
@@ -2263,7 +2263,7 @@ struct wmi_resource_config {
 	 * Max. number of Tx fragments per MSDU
 	 *  This parameter controls the max number of Tx fragments per MSDU.
 	 *  This is sent by the target as part of the WMI_SERVICE_READY event
-	 *  and is overriden by the OS shim as required.
+	 *  and is overridden by the OS shim as required.
 	 */
 	__le32 max_frag_entries;
 } __packed;
@@ -2445,7 +2445,7 @@ struct wmi_resource_config_10x {
 	 * Max. number of Tx fragments per MSDU
 	 *  This parameter controls the max number of Tx fragments per MSDU.
 	 *  This is sent by the target as part of the WMI_SERVICE_READY event
-	 *  and is overriden by the OS shim as required.
+	 *  and is overridden by the OS shim as required.
 	 */
 	__le32 max_frag_entries;
 } __packed;
@@ -2739,7 +2739,7 @@ struct wmi_init_cmd {
 	struct wmi_host_mem_chunks mem_chunks;
 } __packed;
 
-/* _10x stucture is from 10.X FW API */
+/* _10x structure is from 10.X FW API */
 struct wmi_init_cmd_10x {
 	struct wmi_resource_config_10x resource_config;
 	struct wmi_host_mem_chunks mem_chunks;
@@ -3962,7 +3962,7 @@ struct wmi_pdev_stats_tx {
 	/* illegal rate phy errors  */
 	__le32 illgl_rate_phy_err;
 
-	/* wal pdev continous xretry */
+	/* wal pdev continuous xretry */
 	__le32 pdev_cont_xretry;
 
 	/* wal pdev continous xretry */
@@ -4456,9 +4456,9 @@ struct wmi_vdev_start_request_cmd {
 	__le32 flags;
 	/* ssid field. Only valid for AP/GO/IBSS/BTAmp VDEV type. */
 	struct wmi_ssid ssid;
-	/* beacon/probe reponse xmit rate. Applicable for SoftAP. */
+	/* beacon/probe response xmit rate. Applicable for SoftAP. */
 	__le32 bcn_tx_rate;
-	/* beacon/probe reponse xmit power. Applicable for SoftAP. */
+	/* beacon/probe response xmit power. Applicable for SoftAP. */
 	__le32 bcn_tx_power;
 	/* number of p2p NOA descriptor(s) from scan entry */
 	__le32 num_noa_descriptors;
@@ -4686,7 +4686,7 @@ enum wmi_vdev_param {
 	WMI_VDEV_PARAM_BEACON_INTERVAL,
 	/* Listen interval in TUs */
 	WMI_VDEV_PARAM_LISTEN_INTERVAL,
-	/* muticast rate in Mbps */
+	/* multicast rate in Mbps */
 	WMI_VDEV_PARAM_MULTICAST_RATE,
 	/* management frame rate in Mbps */
 	WMI_VDEV_PARAM_MGMT_TX_RATE,
@@ -4817,7 +4817,7 @@ enum wmi_10x_vdev_param {
 	WMI_10X_VDEV_PARAM_BEACON_INTERVAL,
 	/* Listen interval in TUs */
 	WMI_10X_VDEV_PARAM_LISTEN_INTERVAL,
-	/* muticast rate in Mbps */
+	/* multicast rate in Mbps */
 	WMI_10X_VDEV_PARAM_MULTICAST_RATE,
 	/* management frame rate in Mbps */
 	WMI_10X_VDEV_PARAM_MGMT_TX_RATE,
@@ -5062,7 +5062,7 @@ struct wmi_vdev_simple_event {
 } __packed;
 
 /* VDEV start response status codes */
-/* VDEV succesfully started */
+/* VDEV successfully started */
 #define WMI_INIFIED_VDEV_START_RESPONSE_STATUS_SUCCESS	0x0
 
 /* requested VDEV not found */
@@ -5378,7 +5378,7 @@ enum wmi_sta_ps_param_pspoll_count {
 #define WMI_UAPSD_AC_TYPE_TRIG 1
 
 #define WMI_UAPSD_AC_BIT_MASK(ac, type) \
-	((type ==  WMI_UAPSD_AC_TYPE_DELI) ? (1 << (ac << 1)) : (1 << ((ac << 1) + 1)))
+	(type == WMI_UAPSD_AC_TYPE_DELI ? 1 << (ac << 1) : 1 << ((ac << 1) + 1))
 
 enum wmi_sta_ps_param_uapsd {
 	WMI_STA_PS_UAPSD_AC0_DELIVERY_EN = (1 << 0),
-- 
2.8.0.rc4.16.g56331f8
