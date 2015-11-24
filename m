From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH 4/4] staging: rtl8712: Rename local variable
Date: Tue, 24 Nov 2015 10:19:42 -0200
Message-ID: <1448367582-8041-5-git-send-email-mukadr@gmail.com>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36778 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbbKXMU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 07:20:26 -0500
Received: by qgcc31 with SMTP id c31so8750323qgc.3
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 04:20:25 -0800 (PST)
In-Reply-To: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make all instances of struct oid_par_priv be called oid
in rtl871x_ioctl_rtl.c and rtl871x_ioctl_rtl.h.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 287 +++++++++++++---------------
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.h | 123 ++++--------
 2 files changed, 176 insertions(+), 234 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
index 9317370..3bbca78 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
@@ -40,140 +40,139 @@
 #include "rtl871x_mp.h"
 #include "rtl871x_mp_ioctl.h"
 
-uint oid_rt_get_signal_quality_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_signal_quality_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_smallpacket_crcerr;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = adapter->recvpriv.rx_smallpacket_crcerr;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_middlepacket_crcerr;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = adapter->recvpriv.rx_middlepacket_crcerr;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_largepacket_crcerr;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = adapter->recvpriv.rx_largepacket_crcerr;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_tx_retry_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_tx_retry_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_rx_retry_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_rx_retry_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*oid->bytes_rw = oid->information_buf_len;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf =
+	*(u32 *)oid->information_buf =
 			adapter->recvpriv.rx_pkts + adapter->recvpriv.rx_drop;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_tx_beacon_ok_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_tx_beacon_ok_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_tx_beacon_err_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_tx_beacon_err_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32)) 
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(uint *)poid_par_priv->information_buf = adapter->recvpriv.rx_icv_err;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(uint *)oid->information_buf = adapter->recvpriv.rx_icv_err;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_set_encryption_algorithm_hdl(struct oid_par_priv
-						*poid_par_priv)
+uint oid_rt_set_encryption_algorithm_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	u32 preamblemode = 0;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
 	if (adapter->registrypriv.preamble == PREAMBLE_LONG)
@@ -183,60 +182,58 @@ uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
 	else if (adapter->registrypriv.preamble == PREAMBLE_SHORT)
 		preamblemode = 2;
 
-	*(u32 *)poid_par_priv->information_buf = preamblemode;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = preamblemode;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_ap_ip_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_ap_ip_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_channelplan_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	struct eeprom_priv *peeprompriv = &adapter->eeprompriv;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	*(u16 *)poid_par_priv->information_buf = peeprompriv->channel_plan;
+	*oid->bytes_rw = oid->information_buf_len;
+	*(u16 *)oid->information_buf = peeprompriv->channel_plan;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_set_channelplan_hdl(struct oid_par_priv
-				       *poid_par_priv)
+uint oid_rt_set_channelplan_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	struct eeprom_priv *peeprompriv = &adapter->eeprompriv;
 
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	peeprompriv->channel_plan = *(u16 *)poid_par_priv->information_buf;
+	peeprompriv->channel_plan = *(u16 *)oid->information_buf;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
-					 *poid_par_priv)
+uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	u32 preamblemode = 0;
 
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	preamblemode = *(u32 *)poid_par_priv->information_buf;
+	preamblemode = *(u32 *)oid->information_buf;
 	if (preamblemode == 0)
 		adapter->registrypriv.preamble = PREAMBLE_LONG;
 	else if (preamblemode == 1)
@@ -244,89 +241,83 @@ uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 	else if (preamblemode == 2)
 		adapter->registrypriv.preamble = PREAMBLE_SHORT;
 
-	*(u32 *)poid_par_priv->information_buf = preamblemode;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = preamblemode;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_set_bcn_intvl_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_set_bcn_intvl_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_dedicate_probe_hdl(struct oid_par_priv
-				      *poid_par_priv)
+uint oid_rt_dedicate_probe_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
-					  *poid_par_priv)
+uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf = adapter->xmitpriv.tx_bytes;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = adapter->xmitpriv.tx_bytes;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv
-					  *poid_par_priv)
+uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
-	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_bytes;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = adapter->recvpriv.rx_bytes;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_current_tx_power_level_hdl(struct oid_par_priv
-					      *poid_par_priv)
+uint oid_rt_current_tx_power_level_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_enc_key_mismatch_count_hdl(struct oid_par_priv
-						  *poid_par_priv)
+uint oid_rt_get_enc_key_mismatch_count_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_enc_key_match_count_hdl(struct oid_par_priv
-					       *poid_par_priv)
+uint oid_rt_get_enc_key_match_count_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_channel_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_channel_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	struct NDIS_802_11_CONFIGURATION *pnic_Config;
 	u32   channelnum;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (check_fwstate(pmlmepriv, _FW_LINKED) ||
 	    check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE))
@@ -335,139 +326,131 @@ uint oid_rt_get_channel_hdl(struct oid_par_priv *poid_par_priv)
 		pnic_Config = &adapter->registrypriv.dev_network.
 			      Configuration;
 	channelnum = pnic_Config->DSConfig;
-	*(u32 *)poid_par_priv->information_buf = channelnum;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = channelnum;
+	*oid->bytes_rw = oid->information_buf_len;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_hardware_radio_off_hdl(struct oid_par_priv
-			 *poid_par_priv)
+uint oid_rt_get_hardware_radio_off_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_key_mismatch_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_key_mismatch_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_supported_wireless_mode_hdl(struct oid_par_priv
-					       *poid_par_priv)
+uint oid_rt_supported_wireless_mode_hdl(struct oid_par_priv *oid)
 {
 	u32 ulInfo = 0;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len < sizeof(u32))
+	if (oid->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
 	ulInfo |= 0x0100; /* WIRELESS_MODE_B */
 	ulInfo |= 0x0200; /* WIRELESS_MODE_G */
 	ulInfo |= 0x0400; /* WIRELESS_MODE_A */
-	*(u32 *) poid_par_priv->information_buf = ulInfo;
-	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+	*(u32 *) oid->information_buf = ulInfo;
+	*oid->bytes_rw = oid->information_buf_len;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_channel_list_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_channel_list_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_scan_in_progress_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_scan_in_progress_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
 
-uint oid_rt_forced_data_rate_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_forced_data_rate_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_wireless_mode_for_scan_list_hdl(struct oid_par_priv
-						   *poid_par_priv)
+uint oid_rt_wireless_mode_for_scan_list_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_get_bss_wireless_mode_hdl(struct oid_par_priv
-					     *poid_par_priv)
+uint oid_rt_get_bss_wireless_mode_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_scan_with_magic_packet_hdl(struct oid_par_priv
-					      *poid_par_priv)
+uint oid_rt_scan_with_magic_packet_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_ap_get_associated_station_list_hdl(struct oid_par_priv
-						      *poid_par_priv)
+uint oid_rt_ap_get_associated_station_list_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_ap_switch_into_ap_mode_hdl(struct oid_par_priv*
-					      poid_par_priv)
+uint oid_rt_ap_switch_into_ap_mode_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_ap_supported_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_ap_supported_hdl(struct oid_par_priv *oid)
 {
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_ap_set_passphrase_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_ap_set_passphrase_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
-					     poid_par_priv)
+uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
+	if (oid->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len != (sizeof(unsigned long) * 3))
+	if (oid->information_buf_len != (sizeof(unsigned long) * 3))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
 	if (!r8712_setrfreg_cmd(adapter,
-	    *(unsigned char *)poid_par_priv->information_buf,
-	    (unsigned long)(*((unsigned long *)poid_par_priv->information_buf + 2))))
+	    *(unsigned char *)oid->information_buf,
+	    (unsigned long)(*((unsigned long *)oid->information_buf + 2))))
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 
-	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
+	if (oid->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
-	if (poid_par_priv->information_buf_len != (sizeof(unsigned long) * 3))
+	if (oid->information_buf_len != (sizeof(unsigned long) * 3))
 		return RNDIS_STATUS_INVALID_LENGTH;
 
 	if (adapter->mppriv.act_in_progress)
@@ -478,7 +461,7 @@ uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 	adapter->mppriv.workparam.bcompleted = false;
 	adapter->mppriv.workparam.act_type = MPT_READ_RF;
 	adapter->mppriv.workparam.io_offset = *(unsigned long *)
-				poid_par_priv->information_buf;
+				oid->information_buf;
 	adapter->mppriv.workparam.io_value = 0xcccccccc;
 
 	/* RegOffsetValue	- The offset of RF register to read.
@@ -489,7 +472,7 @@ uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 	 * RegDataValue =  *((unsigned long *)InformationBuffer+2);
 	 */
 	if (!r8712_getrfreg_cmd(adapter,
-	    *(unsigned char *)poid_par_priv->information_buf,
+	    *(unsigned char *)oid->information_buf,
 	    (unsigned char *)&adapter->mppriv.workparam.io_value))
 		return RNDIS_STATUS_NOT_ACCEPTED;
 
@@ -503,13 +486,13 @@ enum _CONNECT_STATE_ {
 	NOTASSOCIATED
 };
 
-uint oid_rt_get_connect_state_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_get_connect_state_hdl(struct oid_par_priv *oid)
 {
-	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = oid->adapter_context;
 	struct mlme_priv *pmlmepriv = &(adapter->mlmepriv);
 	u32 ulInfo;
 
-	if (poid_par_priv->type_of_oid != QUERY_OID)
+	if (oid->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	/* nStatus==0	CheckingStatus
 	 * nStatus==1	Associated
@@ -524,14 +507,14 @@ uint oid_rt_get_connect_state_hdl(struct oid_par_priv *poid_par_priv)
 		ulInfo = ADHOCMODE;
 	else
 		ulInfo = NOTASSOCIATED;
-	*(u32 *)poid_par_priv->information_buf = ulInfo;
-	*poid_par_priv->bytes_rw =  poid_par_priv->information_buf_len;
+	*(u32 *)oid->information_buf = ulInfo;
+	*oid->bytes_rw =  oid->information_buf_len;
 	return RNDIS_STATUS_SUCCESS;
 }
 
-uint oid_rt_set_default_key_id_hdl(struct oid_par_priv *poid_par_priv)
+uint oid_rt_set_default_key_id_hdl(struct oid_par_priv *oid)
 {
-	if (poid_par_priv->type_of_oid != SET_OID)
+	if (oid->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	return RNDIS_STATUS_SUCCESS;
 }
diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.h b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.h
index 3bcceae..fb2aa0c 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.h
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.h
@@ -30,92 +30,51 @@
 #include "drv_types.h"
 
 /*************** oid_rtl_seg_01_01 **************/
-uint oid_rt_get_signal_quality_hdl(
-			struct oid_par_priv *poid_par_priv);/*84*/
-uint oid_rt_get_small_packet_crc_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_middle_packet_crc_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_large_packet_crc_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_tx_retry_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_rx_retry_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_rx_total_packet_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_tx_beacon_ok_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_tx_beacon_err_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_rx_icv_err_hdl(
-			struct oid_par_priv *poid_par_priv);/*93*/
-uint oid_rt_set_encryption_algorithm_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_preamble_mode_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_ap_ip_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_channelplan_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_set_channelplan_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_set_preamble_mode_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_set_bcn_intvl_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_dedicate_probe_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_total_tx_bytes_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_total_rx_bytes_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_current_tx_power_level_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_enc_key_mismatch_count_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_enc_key_match_count_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_channel_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_hardware_radio_off_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_key_mismatch_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_supported_wireless_mode_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_channel_list_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_scan_in_progress_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_forced_data_rate_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_wireless_mode_for_scan_list_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_get_bss_wireless_mode_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_scan_with_magic_packet_hdl(
-			struct oid_par_priv *poid_par_priv);
+uint oid_rt_get_signal_quality_hdl(struct oid_par_priv *oid);/*84*/
+uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_tx_retry_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_rx_retry_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_tx_beacon_ok_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_tx_beacon_err_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *oid);/*93*/
+uint oid_rt_set_encryption_algorithm_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_ap_ip_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_channelplan_hdl(struct oid_par_priv *oid);
+uint oid_rt_set_channelplan_hdl(struct oid_par_priv *oid);
+uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv *oid);
+uint oid_rt_set_bcn_intvl_hdl(struct oid_par_priv *oid);
+uint oid_rt_dedicate_probe_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv *oid);
+uint oid_rt_current_tx_power_level_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_enc_key_mismatch_count_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_enc_key_match_count_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_channel_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_hardware_radio_off_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_key_mismatch_hdl(struct oid_par_priv *oid);
+uint oid_rt_supported_wireless_mode_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_channel_list_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_scan_in_progress_hdl(struct oid_par_priv *oid);
+uint oid_rt_forced_data_rate_hdl(struct oid_par_priv *oid);
+uint oid_rt_wireless_mode_for_scan_list_hdl(struct oid_par_priv *oid);
+uint oid_rt_get_bss_wireless_mode_hdl(struct oid_par_priv *oid);
+uint oid_rt_scan_with_magic_packet_hdl(struct oid_par_priv *oid);
 
 /**************  oid_rtl_seg_01_03 section start **************/
-uint oid_rt_ap_get_associated_station_list_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_ap_switch_into_ap_mode_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_ap_supported_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_ap_set_passphrase_hdl(
-			struct oid_par_priv *poid_par_priv);
+uint oid_rt_ap_get_associated_station_list_hdl(struct oid_par_priv *oid);
+uint oid_rt_ap_switch_into_ap_mode_hdl(struct oid_par_priv *oid);
+uint oid_rt_ap_supported_hdl(struct oid_par_priv *oid);
+uint oid_rt_ap_set_passphrase_hdl(struct oid_par_priv *oid);
 /* oid_rtl_seg_01_11 */
-uint oid_rt_pro_rf_write_registry_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_pro_rf_read_registry_hdl(
-			struct oid_par_priv *poid_par_priv);
+uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv *oid);
+uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *oid);
 /***************  oid_rtl_seg_03_00 section start **************/
-uint oid_rt_get_connect_state_hdl(
-			struct oid_par_priv *poid_par_priv);
-uint oid_rt_set_default_key_id_hdl(
-			struct oid_par_priv *poid_par_priv);
+uint oid_rt_get_connect_state_hdl(struct oid_par_priv *oid);
+uint oid_rt_set_default_key_id_hdl(struct oid_par_priv *oid);
 
 #endif
 
-- 
2.6.3
