From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] isdn: hisax: hfc_usb: constify usb_device_id
Date: Tue,  8 Aug 2017 22:19:27 +0530
Message-ID: <fb99bdbed78f5948e9ebb99365d002d41c8437ec.1502210664.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hisax/hfc_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index ef47480..e821218 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -65,7 +65,7 @@ typedef struct {
 } hfcsusb_vdata;
 
 /* VID/PID device list */
-static struct usb_device_id hfcusb_idtab[] = {
+static const struct usb_device_id hfcusb_idtab[] = {
 	{
 		USB_DEVICE(0x0959, 0x2bd0),
 		.driver_info = (unsigned long) &((hfcsusb_vdata)
-- 
2.7.4
