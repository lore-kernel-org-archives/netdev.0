From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 15/35] net: usb: rtl8150: constify usb_device_id
Date: Tue,  8 Aug 2017 21:28:41 +0530
Message-ID: <1502207921-11637-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/rtl8150.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index daaa88a..5f565bd 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -112,7 +112,7 @@
 #undef	EEPROM_WRITE
 
 /* table of devices that work with this driver */
-static struct usb_device_id rtl8150_table[] = {
+static const struct usb_device_id rtl8150_table[] = {
 	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8150)},
 	{USB_DEVICE(VENDOR_ID_MELCO, PRODUCT_ID_LUAKTX)},
 	{USB_DEVICE(VENDOR_ID_MICRONET, PRODUCT_ID_SP128AR)},
-- 
2.7.4
