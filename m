From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] rtlwifi: rtl8188ee: enable MSI interrupts support
Date: Mon, 24 Mar 2014 14:00:41 +0800
Message-ID: <1395640841-14477-1-git-send-email-adam.lee@canonical.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some HP notebooks using this rtl8188ee hardware module can't get
AP scan results with pin-based interrupts, enabling MSI interrupts could
fix it.

Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 347af1e..1b4101b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -93,6 +93,7 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	u8 tid;
 
 	rtl8188ee_bt_reg_init(hw);
+	rtlpci->msi_support = true;
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
 	rtlpriv->dm.dm_flag = 0;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
