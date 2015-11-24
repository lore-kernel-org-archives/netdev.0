From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH 1/4] staging: rtl8712: Remove casts between void * and type *
Date: Tue, 24 Nov 2015 10:19:39 -0200
Message-ID: <1448367582-8041-2-git-send-email-mukadr@gmail.com>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34028 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbbKXMUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 07:20:16 -0500
Received: by qkfo3 with SMTP id o3so4358491qkf.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 04:20:15 -0800 (PST)
In-Reply-To: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleaning rtl871x_ioctl_rtl.c.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 45 ++++++++++-------------------
 1 file changed, 15 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
index 7c346a4..c7f2e51 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
@@ -49,8 +49,7 @@ uint oid_rt_get_signal_quality_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -66,8 +65,7 @@ uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -83,8 +81,7 @@ uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -115,8 +112,7 @@ uint oid_rt_get_rx_retry_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -147,8 +143,7 @@ uint oid_rt_get_tx_beacon_err_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -172,8 +167,7 @@ uint oid_rt_set_encryption_algorithm_hdl(struct oid_par_priv
 
 uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	u32 preamblemode = 0;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
@@ -202,8 +196,7 @@ uint oid_rt_get_ap_ip_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	struct eeprom_priv *peeprompriv = &padapter->eeprompriv;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
@@ -216,8 +209,7 @@ uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 				       *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	struct eeprom_priv *peeprompriv = &padapter->eeprompriv;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
@@ -229,8 +221,7 @@ uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 					 *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	u32 preamblemode = 0;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
@@ -267,8 +258,7 @@ uint oid_rt_dedicate_probe_hdl(struct oid_par_priv
 uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 					  *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -285,8 +275,7 @@ uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv
 					  *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -325,8 +314,7 @@ uint oid_rt_get_enc_key_match_count_hdl(struct oid_par_priv
 
 uint oid_rt_get_channel_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				    (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct NDIS_802_11_CONFIGURATION *pnic_Config;
 	u32   channelnum;
@@ -449,8 +437,7 @@ uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
 					     poid_par_priv)
 {
 	uint status = RNDIS_STATUS_SUCCESS;
-	struct _adapter *Adapter = (struct _adapter *)
-			(poid_par_priv->adapter_context);
+	struct _adapter *Adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -470,8 +457,7 @@ uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
 uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 {
 	uint status = RNDIS_STATUS_SUCCESS;
-	struct _adapter *Adapter = (struct _adapter *)
-			(poid_par_priv->adapter_context);
+	struct _adapter *Adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -516,8 +502,7 @@ enum _CONNECT_STATE_ {
 
 uint oid_rt_get_connect_state_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = (struct _adapter *)
-				     (poid_par_priv->adapter_context);
+	struct _adapter *padapter = poid_par_priv->adapter_context;
 	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
 	u32 ulInfo;
 
-- 
2.6.3
