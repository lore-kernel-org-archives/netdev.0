From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH v2 2/4] staging: rtl8712: Rename local variable
Date: Wed, 25 Nov 2015 15:42:40 -0200
Message-ID: <1448473362-12524-3-git-send-email-mukadr@gmail.com>
References: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33802 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbKYRqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 12:46:46 -0500
Received: by qgeb1 with SMTP id b1so37655363qge.1
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 09:46:45 -0800 (PST)
In-Reply-To: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renames all instances of struct _adapter to adapter in rtl871x_ioctl_rtl.c,
avoiding camel case.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 86 ++++++++++++++---------------
 1 file changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
index c7f2e51..97596aa 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
@@ -49,13 +49,13 @@ uint oid_rt_get_signal_quality_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-				padapter->recvpriv.rx_smallpacket_crcerr;
+				adapter->recvpriv.rx_smallpacket_crcerr;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -65,13 +65,13 @@ uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-				padapter->recvpriv.rx_middlepacket_crcerr;
+				adapter->recvpriv.rx_middlepacket_crcerr;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -81,13 +81,13 @@ uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-				 padapter->recvpriv.rx_largepacket_crcerr;
+				 adapter->recvpriv.rx_largepacket_crcerr;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -112,14 +112,14 @@ uint oid_rt_get_rx_retry_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-					 padapter->recvpriv.rx_pkts +
-					 padapter->recvpriv.rx_drop;
+					 adapter->recvpriv.rx_pkts +
+					 adapter->recvpriv.rx_drop;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -143,13 +143,13 @@ uint oid_rt_get_tx_beacon_err_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
 		*(uint *)poid_par_priv->information_buf =
-					 padapter->recvpriv.rx_icv_err;
+					 adapter->recvpriv.rx_icv_err;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -167,17 +167,17 @@ uint oid_rt_set_encryption_algorithm_hdl(struct oid_par_priv
 
 uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 	u32 preamblemode = 0;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		if (padapter->registrypriv.preamble == PREAMBLE_LONG)
+		if (adapter->registrypriv.preamble == PREAMBLE_LONG)
 			preamblemode = 0;
-		else if (padapter->registrypriv.preamble == PREAMBLE_AUTO)
+		else if (adapter->registrypriv.preamble == PREAMBLE_AUTO)
 			preamblemode = 1;
-		else if (padapter->registrypriv.preamble == PREAMBLE_SHORT)
+		else if (adapter->registrypriv.preamble == PREAMBLE_SHORT)
 			preamblemode = 2;
 		*(u32 *)poid_par_priv->information_buf = preamblemode;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
@@ -196,8 +196,8 @@ uint oid_rt_get_ap_ip_hdl(struct oid_par_priv *poid_par_priv)
 
 uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
-	struct eeprom_priv *peeprompriv = &padapter->eeprompriv;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct eeprom_priv *peeprompriv = &adapter->eeprompriv;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -209,8 +209,8 @@ uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 				       *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
-	struct eeprom_priv *peeprompriv = &padapter->eeprompriv;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct eeprom_priv *peeprompriv = &adapter->eeprompriv;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
@@ -221,7 +221,7 @@ uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 					 *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 	u32 preamblemode = 0;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
@@ -229,11 +229,11 @@ uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
 		preamblemode = *(u32 *)poid_par_priv->information_buf;
 		if (preamblemode == 0)
-			padapter->registrypriv.preamble = PREAMBLE_LONG;
+			adapter->registrypriv.preamble = PREAMBLE_LONG;
 		else if (preamblemode == 1)
-			padapter->registrypriv.preamble = PREAMBLE_AUTO;
+			adapter->registrypriv.preamble = PREAMBLE_AUTO;
 		else if (preamblemode == 2)
-			padapter->registrypriv.preamble = PREAMBLE_SHORT;
+			adapter->registrypriv.preamble = PREAMBLE_SHORT;
 		*(u32 *)poid_par_priv->information_buf = preamblemode;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
@@ -258,13 +258,13 @@ uint oid_rt_dedicate_probe_hdl(struct oid_par_priv
 uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 					  *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-						 padapter->xmitpriv.tx_bytes;
+						 adapter->xmitpriv.tx_bytes;
 		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	} else {
 		return RNDIS_STATUS_INVALID_LENGTH;
@@ -275,13 +275,13 @@ uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv
 					  *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
 		*(u32 *)poid_par_priv->information_buf =
-					   padapter->recvpriv.rx_bytes;
+					   adapter->recvpriv.rx_bytes;
 		*poid_par_priv->bytes_rw = poid_par_priv->
 					   information_buf_len;
 	} else {
@@ -314,8 +314,8 @@ uint oid_rt_get_enc_key_match_count_hdl(struct oid_par_priv
 
 uint oid_rt_get_channel_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
-	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	struct NDIS_802_11_CONFIGURATION *pnic_Config;
 	u32   channelnum;
 
@@ -325,7 +325,7 @@ uint oid_rt_get_channel_hdl(struct oid_par_priv *poid_par_priv)
 	    check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE))
 		pnic_Config = &pmlmepriv->cur_network.network.Configuration;
 	else
-		pnic_Config = &padapter->registrypriv.dev_network.
+		pnic_Config = &adapter->registrypriv.dev_network.
 			      Configuration;
 	channelnum = pnic_Config->DSConfig;
 	*(u32 *)poid_par_priv->information_buf = channelnum;
@@ -437,13 +437,13 @@ uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
 					     poid_par_priv)
 {
 	uint status = RNDIS_STATUS_SUCCESS;
-	struct _adapter *Adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len ==
 	   (sizeof(unsigned long) * 3)) {
-		if (!r8712_setrfreg_cmd(Adapter,
+		if (!r8712_setrfreg_cmd(adapter,
 			*(unsigned char *)poid_par_priv->information_buf,
 			(unsigned long)(*((unsigned long *)
 					poid_par_priv->information_buf + 2))))
@@ -457,22 +457,22 @@ uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
 uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 {
 	uint status = RNDIS_STATUS_SUCCESS;
-	struct _adapter *Adapter = poid_par_priv->adapter_context;
+	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
 	if (poid_par_priv->information_buf_len == (sizeof(unsigned long) *
 						   3)) {
-		if (Adapter->mppriv.act_in_progress) {
+		if (adapter->mppriv.act_in_progress) {
 			status = RNDIS_STATUS_NOT_ACCEPTED;
 		} else {
 			/* init workparam */
-			Adapter->mppriv.act_in_progress = true;
-			Adapter->mppriv.workparam.bcompleted = false;
-			Adapter->mppriv.workparam.act_type = MPT_READ_RF;
-			Adapter->mppriv.workparam.io_offset = *(unsigned long *)
+			adapter->mppriv.act_in_progress = true;
+			adapter->mppriv.workparam.bcompleted = false;
+			adapter->mppriv.workparam.act_type = MPT_READ_RF;
+			adapter->mppriv.workparam.io_offset = *(unsigned long *)
 						poid_par_priv->information_buf;
-			Adapter->mppriv.workparam.io_value = 0xcccccccc;
+			adapter->mppriv.workparam.io_value = 0xcccccccc;
 
 		/* RegOffsetValue	- The offset of RF register to read.
 		 * RegDataWidth	- The data width of RF register to read.
@@ -481,9 +481,9 @@ uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 		 * RegDataWidth = *((unsigned long *)InformationBuffer+1);
 		 * RegDataValue =  *((unsigned long *)InformationBuffer+2);
 		 */
-			if (!r8712_getrfreg_cmd(Adapter,
+			if (!r8712_getrfreg_cmd(adapter,
 			    *(unsigned char *)poid_par_priv->information_buf,
-			    (unsigned char *)&Adapter->mppriv.workparam.
+			    (unsigned char *)&adapter->mppriv.workparam.
 			    io_value))
 				status = RNDIS_STATUS_NOT_ACCEPTED;
 		}
@@ -502,8 +502,8 @@ enum _CONNECT_STATE_ {
 
 uint oid_rt_get_connect_state_hdl(struct oid_par_priv *poid_par_priv)
 {
-	struct _adapter *padapter = poid_par_priv->adapter_context;
-	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
+	struct _adapter *adapter = poid_par_priv->adapter_context;
+	struct mlme_priv *pmlmepriv = &(adapter->mlmepriv);
 	u32 ulInfo;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
-- 
2.6.3
