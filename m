From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 2/9] net/ieee80211: ieee80211_is_* can be boolean
Date: Thu,  8 Oct 2015 21:28:55 +0800
Message-ID: <1444310942-4428-3-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:52110 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756951AbbJHNji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 09:39:38 -0400
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes ieee80211_is_* return bool to improve
readability due to these particular functions only using either
one or zero as their return value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/ieee80211.h | 76 +++++++++++++++++++++++------------------------
 1 file changed, 38 insertions(+), 38 deletions(-)

diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index cfa906f..0b7048d 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -121,7 +121,7 @@
 #define IEEE80211_MAX_SN		IEEE80211_SN_MASK
 #define IEEE80211_SN_MODULO		(IEEE80211_MAX_SN + 1)
 
-static inline int ieee80211_sn_less(u16 sn1, u16 sn2)
+static inline bool ieee80211_sn_less(u16 sn1, u16 sn2)
 {
 	return ((sn1 - sn2) & IEEE80211_SN_MASK) > (IEEE80211_SN_MODULO >> 1);
 }
@@ -250,7 +250,7 @@ struct ieee80211_qos_hdr {
  * ieee80211_has_tods - check if IEEE80211_FCTL_TODS is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_tods(__le16 fc)
+static inline bool ieee80211_has_tods(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_TODS)) != 0;
 }
@@ -259,7 +259,7 @@ static inline int ieee80211_has_tods(__le16 fc)
  * ieee80211_has_fromds - check if IEEE80211_FCTL_FROMDS is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_fromds(__le16 fc)
+static inline bool ieee80211_has_fromds(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FROMDS)) != 0;
 }
@@ -268,7 +268,7 @@ static inline int ieee80211_has_fromds(__le16 fc)
  * ieee80211_has_a4 - check if IEEE80211_FCTL_TODS and IEEE80211_FCTL_FROMDS are set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_a4(__le16 fc)
+static inline bool ieee80211_has_a4(__le16 fc)
 {
 	__le16 tmp = cpu_to_le16(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
 	return (fc & tmp) == tmp;
@@ -278,7 +278,7 @@ static inline int ieee80211_has_a4(__le16 fc)
  * ieee80211_has_morefrags - check if IEEE80211_FCTL_MOREFRAGS is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_morefrags(__le16 fc)
+static inline bool ieee80211_has_morefrags(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) != 0;
 }
@@ -287,7 +287,7 @@ static inline int ieee80211_has_morefrags(__le16 fc)
  * ieee80211_has_retry - check if IEEE80211_FCTL_RETRY is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_retry(__le16 fc)
+static inline bool ieee80211_has_retry(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_RETRY)) != 0;
 }
@@ -296,7 +296,7 @@ static inline int ieee80211_has_retry(__le16 fc)
  * ieee80211_has_pm - check if IEEE80211_FCTL_PM is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_pm(__le16 fc)
+static inline bool ieee80211_has_pm(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_PM)) != 0;
 }
@@ -305,7 +305,7 @@ static inline int ieee80211_has_pm(__le16 fc)
  * ieee80211_has_moredata - check if IEEE80211_FCTL_MOREDATA is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_moredata(__le16 fc)
+static inline bool ieee80211_has_moredata(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_MOREDATA)) != 0;
 }
@@ -314,7 +314,7 @@ static inline int ieee80211_has_moredata(__le16 fc)
  * ieee80211_has_protected - check if IEEE80211_FCTL_PROTECTED is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_protected(__le16 fc)
+static inline bool ieee80211_has_protected(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_PROTECTED)) != 0;
 }
@@ -323,7 +323,7 @@ static inline int ieee80211_has_protected(__le16 fc)
  * ieee80211_has_order - check if IEEE80211_FCTL_ORDER is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_has_order(__le16 fc)
+static inline bool ieee80211_has_order(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_ORDER)) != 0;
 }
@@ -332,7 +332,7 @@ static inline int ieee80211_has_order(__le16 fc)
  * ieee80211_is_mgmt - check if type is IEEE80211_FTYPE_MGMT
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_mgmt(__le16 fc)
+static inline bool ieee80211_is_mgmt(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT);
@@ -342,7 +342,7 @@ static inline int ieee80211_is_mgmt(__le16 fc)
  * ieee80211_is_ctl - check if type is IEEE80211_FTYPE_CTL
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_ctl(__le16 fc)
+static inline bool ieee80211_is_ctl(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL);
@@ -352,7 +352,7 @@ static inline int ieee80211_is_ctl(__le16 fc)
  * ieee80211_is_data - check if type is IEEE80211_FTYPE_DATA
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_data(__le16 fc)
+static inline bool ieee80211_is_data(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_DATA);
@@ -362,7 +362,7 @@ static inline int ieee80211_is_data(__le16 fc)
  * ieee80211_is_data_qos - check if type is IEEE80211_FTYPE_DATA and IEEE80211_STYPE_QOS_DATA is set
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_data_qos(__le16 fc)
+static inline bool ieee80211_is_data_qos(__le16 fc)
 {
 	/*
 	 * mask with QOS_DATA rather than IEEE80211_FCTL_STYPE as we just need
@@ -376,7 +376,7 @@ static inline int ieee80211_is_data_qos(__le16 fc)
  * ieee80211_is_data_present - check if type is IEEE80211_FTYPE_DATA and has data
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_data_present(__le16 fc)
+static inline bool ieee80211_is_data_present(__le16 fc)
 {
 	/*
 	 * mask with 0x40 and test that that bit is clear to only return true
@@ -390,7 +390,7 @@ static inline int ieee80211_is_data_present(__le16 fc)
  * ieee80211_is_assoc_req - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_ASSOC_REQ
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_assoc_req(__le16 fc)
+static inline bool ieee80211_is_assoc_req(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_ASSOC_REQ);
@@ -400,7 +400,7 @@ static inline int ieee80211_is_assoc_req(__le16 fc)
  * ieee80211_is_assoc_resp - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_ASSOC_RESP
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_assoc_resp(__le16 fc)
+static inline bool ieee80211_is_assoc_resp(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_ASSOC_RESP);
@@ -410,7 +410,7 @@ static inline int ieee80211_is_assoc_resp(__le16 fc)
  * ieee80211_is_reassoc_req - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_REASSOC_REQ
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_reassoc_req(__le16 fc)
+static inline bool ieee80211_is_reassoc_req(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_REASSOC_REQ);
@@ -420,7 +420,7 @@ static inline int ieee80211_is_reassoc_req(__le16 fc)
  * ieee80211_is_reassoc_resp - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_REASSOC_RESP
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_reassoc_resp(__le16 fc)
+static inline bool ieee80211_is_reassoc_resp(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_REASSOC_RESP);
@@ -430,7 +430,7 @@ static inline int ieee80211_is_reassoc_resp(__le16 fc)
  * ieee80211_is_probe_req - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_PROBE_REQ
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_probe_req(__le16 fc)
+static inline bool ieee80211_is_probe_req(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_PROBE_REQ);
@@ -440,7 +440,7 @@ static inline int ieee80211_is_probe_req(__le16 fc)
  * ieee80211_is_probe_resp - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_PROBE_RESP
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_probe_resp(__le16 fc)
+static inline bool ieee80211_is_probe_resp(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_PROBE_RESP);
@@ -450,7 +450,7 @@ static inline int ieee80211_is_probe_resp(__le16 fc)
  * ieee80211_is_beacon - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_BEACON
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_beacon(__le16 fc)
+static inline bool ieee80211_is_beacon(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_BEACON);
@@ -460,7 +460,7 @@ static inline int ieee80211_is_beacon(__le16 fc)
  * ieee80211_is_atim - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_ATIM
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_atim(__le16 fc)
+static inline bool ieee80211_is_atim(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_ATIM);
@@ -470,7 +470,7 @@ static inline int ieee80211_is_atim(__le16 fc)
  * ieee80211_is_disassoc - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_DISASSOC
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_disassoc(__le16 fc)
+static inline bool ieee80211_is_disassoc(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_DISASSOC);
@@ -480,7 +480,7 @@ static inline int ieee80211_is_disassoc(__le16 fc)
  * ieee80211_is_auth - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_AUTH
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_auth(__le16 fc)
+static inline bool ieee80211_is_auth(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_AUTH);
@@ -490,7 +490,7 @@ static inline int ieee80211_is_auth(__le16 fc)
  * ieee80211_is_deauth - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_DEAUTH
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_deauth(__le16 fc)
+static inline bool ieee80211_is_deauth(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_DEAUTH);
@@ -500,7 +500,7 @@ static inline int ieee80211_is_deauth(__le16 fc)
  * ieee80211_is_action - check if IEEE80211_FTYPE_MGMT && IEEE80211_STYPE_ACTION
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_action(__le16 fc)
+static inline bool ieee80211_is_action(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_ACTION);
@@ -510,7 +510,7 @@ static inline int ieee80211_is_action(__le16 fc)
  * ieee80211_is_back_req - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_BACK_REQ
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_back_req(__le16 fc)
+static inline bool ieee80211_is_back_req(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_BACK_REQ);
@@ -520,7 +520,7 @@ static inline int ieee80211_is_back_req(__le16 fc)
  * ieee80211_is_back - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_BACK
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_back(__le16 fc)
+static inline bool ieee80211_is_back(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_BACK);
@@ -530,7 +530,7 @@ static inline int ieee80211_is_back(__le16 fc)
  * ieee80211_is_pspoll - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_PSPOLL
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_pspoll(__le16 fc)
+static inline bool ieee80211_is_pspoll(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_PSPOLL);
@@ -540,7 +540,7 @@ static inline int ieee80211_is_pspoll(__le16 fc)
  * ieee80211_is_rts - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_RTS
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_rts(__le16 fc)
+static inline bool ieee80211_is_rts(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS);
@@ -550,7 +550,7 @@ static inline int ieee80211_is_rts(__le16 fc)
  * ieee80211_is_cts - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_CTS
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_cts(__le16 fc)
+static inline bool ieee80211_is_cts(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CTS);
@@ -560,7 +560,7 @@ static inline int ieee80211_is_cts(__le16 fc)
  * ieee80211_is_ack - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_ACK
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_ack(__le16 fc)
+static inline bool ieee80211_is_ack(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_ACK);
@@ -570,7 +570,7 @@ static inline int ieee80211_is_ack(__le16 fc)
  * ieee80211_is_cfend - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_CFEND
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_cfend(__le16 fc)
+static inline bool ieee80211_is_cfend(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CFEND);
@@ -580,7 +580,7 @@ static inline int ieee80211_is_cfend(__le16 fc)
  * ieee80211_is_cfendack - check if IEEE80211_FTYPE_CTL && IEEE80211_STYPE_CFENDACK
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_cfendack(__le16 fc)
+static inline bool ieee80211_is_cfendack(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CFENDACK);
@@ -590,7 +590,7 @@ static inline int ieee80211_is_cfendack(__le16 fc)
  * ieee80211_is_nullfunc - check if frame is a regular (non-QoS) nullfunc frame
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_nullfunc(__le16 fc)
+static inline bool ieee80211_is_nullfunc(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_NULLFUNC);
@@ -600,7 +600,7 @@ static inline int ieee80211_is_nullfunc(__le16 fc)
  * ieee80211_is_qos_nullfunc - check if frame is a QoS nullfunc frame
  * @fc: frame control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_qos_nullfunc(__le16 fc)
+static inline bool ieee80211_is_qos_nullfunc(__le16 fc)
 {
 	return (fc & cpu_to_le16(IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) ==
 	       cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_QOS_NULLFUNC);
@@ -624,7 +624,7 @@ static inline bool ieee80211_is_bufferable_mmpdu(__le16 fc)
  * ieee80211_is_first_frag - check if IEEE80211_SCTL_FRAG is not set
  * @seq_ctrl: frame sequence control bytes in little-endian byteorder
  */
-static inline int ieee80211_is_first_frag(__le16 seq_ctrl)
+static inline bool ieee80211_is_first_frag(__le16 seq_ctrl)
 {
 	return (seq_ctrl & cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0;
 }
-- 
1.9.1
