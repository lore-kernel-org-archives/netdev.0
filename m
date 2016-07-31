From: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Subject: [PATCH 1/1] rtlwifi: remove superfluous condition
Date: Sun, 31 Jul 2016 12:30:15 +0200
Message-ID: <1469961015-1888-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If sta == NULL, the changed line will not be reached.
So no need to check if stat == NULL here.

Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
---
 drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 41f77f8..7aee5ebb1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1135,7 +1135,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 					mac->mode = WIRELESS_MODE_AC_24G;
 			}
 
-			if (vif->type == NL80211_IFTYPE_STATION && sta)
+			if (vif->type == NL80211_IFTYPE_STATION)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 			rcu_read_unlock();
 
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
