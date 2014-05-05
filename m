From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 1/3] rtlwifi: make MSI support a module parameter
Date: Mon,  5 May 2014 16:33:36 +0800
Message-ID: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This makes MSI support a module parameter, for debugging and workaround
convenience.

Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/wifi.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 6965afd..eef93d1 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2030,6 +2030,10 @@ struct rtl_mod_params {
 
 	/* default: 1 = using linked fw power save */
 	bool fwctrl_lps;
+
+	/* default: 0 = not using MSI interrupts mode */
+	/* submodules should set their own defalut value */
+	bool msi_support;
 };
 
 struct rtl_hal_usbint_cfg {
-- 
2.0.0.rc0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
