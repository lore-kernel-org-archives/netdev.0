From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/8 V2] rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
Date: Mon, 16 Sep 2013 13:55:16 -0500
Message-ID: <1379357722-17687-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379357722-17687-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192de/hw.c
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.

Dead code is commented out. It has not been deleted in case I find a need for
it later.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 7dd8f6d..c9b0894 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1194,6 +1194,7 @@ void rtl92d_linked_set_reg(struct ieee80211_hw *hw)
  * mac80211 will send pkt when scan */
 void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
 {
+/*
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	rtl92d_dm_init_edca_turbo(hw);
 	return;
@@ -1213,6 +1214,7 @@ void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
 		RT_ASSERT(false, "invalid aci: %d !\n", aci);
 		break;
 	}
+ */
 }
 
 void rtl92de_enable_interrupt(struct ieee80211_hw *hw)
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
