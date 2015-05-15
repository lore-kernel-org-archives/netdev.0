From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 4/5] rtlwifi: rtl8723be: Update driver for regulatory changes
Date: Fri, 15 May 2015 16:33:02 -0500
Message-ID: <1431725583-7324-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431725583-7324-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

The driver is converted to use the channel plan in the EEPROM.

Signed-off-by: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index b681af3..e0f679b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -2139,8 +2139,8 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
 
-	/* set channel plan to world wide 13 */
-	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
+	/* set channel plan from efuse */
+	rtlefuse->channel_plan = rtlefuse->eeprom_channelplan;
 
 	if (rtlhal->oem_id == RT_CID_DEFAULT) {
 		/* Does this one have a Toshiba SMID from group 1? */
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
