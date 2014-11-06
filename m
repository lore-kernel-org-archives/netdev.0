From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: remove the definitions of the PID
Date: Thu, 6 Nov 2014 12:47:40 +0800
Message-ID: <1394712342-15778-87-Taiwan-albertk@realtek.com>
References: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PIDs are only used in the id table, so the definitions are
unnacessary. Remove them wouldn't have confusion.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index cf1b8a7..66b139a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -461,11 +461,7 @@ enum rtl8152_flags {
 
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
-#define PRODUCT_ID_RTL8152		0x8152
-#define PRODUCT_ID_RTL8153		0x8153
-
 #define VENDOR_ID_SAMSUNG		0x04e8
-#define PRODUCT_ID_SAMSUNG		0xa101
 
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
@@ -3898,9 +3894,9 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
-	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
-	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
-	{USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
+	{USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
+	{USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{}
 };
 
-- 
1.9.3
