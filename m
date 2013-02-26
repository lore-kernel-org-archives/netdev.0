From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 26/27] rtlwifi: rtl8188e: Remove some CamelCase variable names
Date: Mon, 25 Feb 2013 18:13:38 -0600
Message-ID: <1361837619-2985-27-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:51023 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556Ab3BZAOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:53 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c | 18 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h | 20 ++++++++++----------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
index 39dfe31..fa46a42 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
@@ -32,21 +32,21 @@
 
 /* drivers should parse below arrays and do the corresponding actions */
 /*3 Power on  Array*/
-struct wlan_pwr_cfg rtl8188E_power_on_flow[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS
+struct wlan_pwr_cfg rtl8188e_power_on_flow[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	RTL8188E_TRANS_CARDEMU_TO_ACT
 	RTL8188E_TRANS_END
 };
 
 /*3Radio off GPIO Array */
-struct wlan_pwr_cfg rtl8188E_radio_off_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
+struct wlan_pwr_cfg rtl8188e_radio_off_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	RTL8188E_TRANS_ACT_TO_CARDEMU
 	RTL8188E_TRANS_END
 };
 
 /*3Card Disable Array*/
-struct wlan_pwr_cfg rtl8188E_card_disable_flow
+struct wlan_pwr_cfg rtl8188e_card_disable_flow
 	[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
 	RTL8188E_TRANS_END_STEPS] = {
@@ -56,7 +56,7 @@ struct wlan_pwr_cfg rtl8188E_card_disable_flow
 };
 
 /*3 Card Enable Array*/
-struct wlan_pwr_cfg rtl8188E_card_enable_flow
+struct wlan_pwr_cfg rtl8188e_card_enable_flow
 	[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
 	RTL8188E_TRANS_END_STEPS] = {
@@ -66,7 +66,7 @@ struct wlan_pwr_cfg rtl8188E_card_enable_flow
 };
 
 /*3Suspend Array*/
-struct wlan_pwr_cfg rtl8188E_suspend_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
+struct wlan_pwr_cfg rtl8188e_suspend_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 					+ RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	RTL8188E_TRANS_ACT_TO_CARDEMU
@@ -75,7 +75,7 @@ struct wlan_pwr_cfg rtl8188E_suspend_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 };
 
 /*3 Resume Array*/
-struct wlan_pwr_cfg rtl8188E_resume_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
+struct wlan_pwr_cfg rtl8188e_resume_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 					+ RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	RTL8188E_TRANS_SUS_TO_CARDEMU
@@ -84,7 +84,7 @@ struct wlan_pwr_cfg rtl8188E_resume_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 };
 
 /*3HWPDN Array*/
-struct wlan_pwr_cfg rtl8188E_hwpdn_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
+struct wlan_pwr_cfg rtl8188e_hwpdn_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 				+ RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS
 				+ RTL8188E_TRANS_END_STEPS] = {
 	RTL8188E_TRANS_ACT_TO_CARDEMU
@@ -93,7 +93,7 @@ struct wlan_pwr_cfg rtl8188E_hwpdn_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
 };
 
 /*3 Enter LPS */
-struct wlan_pwr_cfg rtl8188E_enter_lps_flow[RTL8188E_TRANS_ACT_TO_LPS_STEPS
+struct wlan_pwr_cfg rtl8188e_enter_lps_flow[RTL8188E_TRANS_ACT_TO_LPS_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	/*FW behavior*/
 	RTL8188E_TRANS_ACT_TO_LPS
@@ -101,7 +101,7 @@ struct wlan_pwr_cfg rtl8188E_enter_lps_flow[RTL8188E_TRANS_ACT_TO_LPS_STEPS
 };
 
 /*3 Leave LPS */
-struct wlan_pwr_cfg rtl8188E_leave_lps_flow[RTL8188E_TRANS_LPS_TO_ACT_STEPS
+struct wlan_pwr_cfg rtl8188e_leave_lps_flow[RTL8188E_TRANS_LPS_TO_ACT_STEPS
 					+ RTL8188E_TRANS_END_STEPS] = {
 	/*FW behavior*/
 	RTL8188E_TRANS_LPS_TO_ACT
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
index 310308e..028ec6d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
@@ -51,7 +51,7 @@
 	TRANS_LPS_TO_ACT
 
 	TRANS_END
-	PWR SEQ Version: rtl8188E_PwrSeq_V09.h
+	PWR SEQ Version: rtl8188e_PwrSeq_V09.h
 */
 
 #define	RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS	10
@@ -280,36 +280,36 @@
 	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
 	0, PWR_CMD_END, 0, 0}
 
-extern struct wlan_pwr_cfg rtl8188E_power_on_flow
+extern struct wlan_pwr_cfg rtl8188e_power_on_flow
 		[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_radio_off_flow
+extern struct wlan_pwr_cfg rtl8188e_radio_off_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_card_disable_flow
+extern struct wlan_pwr_cfg rtl8188e_card_disable_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_card_enable_flow
+extern struct wlan_pwr_cfg rtl8188e_card_enable_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_suspend_flow
+extern struct wlan_pwr_cfg rtl8188e_suspend_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_resume_flow
+extern struct wlan_pwr_cfg rtl8188e_resume_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_hwpdn_flow
+extern struct wlan_pwr_cfg rtl8188e_hwpdn_flow
 		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
 		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_enter_lps_flow
+extern struct wlan_pwr_cfg rtl8188e_enter_lps_flow
 		[RTL8188E_TRANS_ACT_TO_LPS_STEPS +
 		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_leave_lps_flow
+extern struct wlan_pwr_cfg rtl8188e_leave_lps_flow
 		[RTL8188E_TRANS_LPS_TO_ACT_STEPS +
 		RTL8188E_TRANS_END_STEPS];
 
-- 
1.8.1.4
