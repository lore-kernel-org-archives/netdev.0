From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 31/35] wireless: realtek: rtl8187: constify usb_device_id
Date: Tue,  8 Aug 2017 21:34:45 +0530
Message-ID: <1502208285-12342-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, herton@canonical.com,
        htl10@users.sourceforge.net, Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c b/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
index 55198ac2..121b94f 100644
--- a/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
@@ -43,7 +43,7 @@ MODULE_AUTHOR("Larry Finger <Larry.Finger@lwfinger.net>");
 MODULE_DESCRIPTION("RTL8187/RTL8187B USB wireless driver");
 MODULE_LICENSE("GPL");
 
-static struct usb_device_id rtl8187_table[] = {
+static const struct usb_device_id rtl8187_table[] = {
 	/* Asus */
 	{USB_DEVICE(0x0b05, 0x171d), .driver_info = DEVICE_RTL8187},
 	/* Belkin */
-- 
2.7.4
