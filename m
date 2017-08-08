From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 13/35] net: usb: kaweth: constify usb_device_id
Date: Tue,  8 Aug 2017 21:28:04 +0530
Message-ID: <1502207885-11574-4-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/kaweth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 92e4fd2..f160583 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -125,7 +125,7 @@ static int kaweth_resume(struct usb_interface *intf);
 /****************************************************************
  *     usb_device_id
  ****************************************************************/
-static struct usb_device_id usb_klsi_table[] = {
+static const struct usb_device_id usb_klsi_table[] = {
 	{ USB_DEVICE(0x03e8, 0x0008) }, /* AOX Endpoints USB Ethernet */
 	{ USB_DEVICE(0x04bb, 0x0901) }, /* I-O DATA USB-ET/T */
 	{ USB_DEVICE(0x0506, 0x03e8) }, /* 3Com 3C19250 */
-- 
2.7.4
