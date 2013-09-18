From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/8 V3] rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
Date: Wed, 18 Sep 2013 14:57:34 -0500
Message-ID: <1379534260-14841-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1379534260-14841-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379534260-14841-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192de/hw.c
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.

The dead code is deleted.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c |   19 -------------------
 1 file changed, 19 deletions(-)

Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1194,25 +1194,6 @@ void rtl92d_linked_set_reg(struct ieee80
  * mac80211 will send pkt when scan */
 void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	rtl92d_dm_init_edca_turbo(hw);
-	return;
-	switch (aci) {
-	case AC1_BK:
-		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, 0xa44f);
-		break;
-	case AC0_BE:
-		break;
-	case AC2_VI:
-		rtl_write_dword(rtlpriv, REG_EDCA_VI_PARAM, 0x5e4322);
-		break;
-	case AC3_VO:
-		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, 0x2f3222);
-		break;
-	default:
-		RT_ASSERT(false, "invalid aci: %d !\n", aci);
-		break;
-	}
 }
 
 void rtl92de_enable_interrupt(struct ieee80211_hw *hw)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
