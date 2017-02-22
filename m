From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] rtlwifi: fix spelling mistake: "conuntry" -> "country"
Date: Wed, 22 Feb 2017 23:35:52 +0000
Message-ID: <20170222233552.8196-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
        Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

trivial fix to spelling mistake in RT_TRACE message

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/realtek/rtlwifi/regd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/regd.c b/drivers/net/wireless/realtek/rtlwifi/regd.c
index 558c31b..1bf3eb2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/regd.c
+++ b/drivers/net/wireless/realtek/rtlwifi/regd.c
@@ -435,7 +435,7 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 		channel_plan_to_country_code(rtlpriv->efuse.channel_plan);
 
 	RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
-		 "rtl: EEPROM regdomain: 0x%0x conuntry code: %d\n",
+		 "rtl: EEPROM regdomain: 0x%0x country code: %d\n",
 		 rtlpriv->efuse.channel_plan, rtlpriv->regd.country_code);
 
 	if (rtlpriv->regd.country_code >= COUNTRY_CODE_MAX) {
-- 
2.10.2
