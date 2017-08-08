From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 10/35] net: usb: catc: constify usb_device_id and fix space before '[' error
Date: Tue,  8 Aug 2017 21:28:01 +0530
Message-ID: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Fix checkpatch.pl error:
ERROR: space prohibited before open square bracket '['.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/catc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index fce92f0..01cd17e 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -961,7 +961,7 @@ static void catc_disconnect(struct usb_interface *intf)
  * Module functions and tables.
  */
 
-static struct usb_device_id catc_id_table [] = {
+static const struct usb_device_id catc_id_table[] = {
 	{ USB_DEVICE(0x0423, 0xa) },	/* CATC Netmate, Belkin F5U011 */
 	{ USB_DEVICE(0x0423, 0xc) },	/* CATC Netmate II, Belkin F5U111 */
 	{ USB_DEVICE(0x08d1, 0x1) },	/* smartBridges smartNIC */
-- 
2.7.4
