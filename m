From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 11/35] net: usb: cdc-phonet: constify usb_device_id
Date: Tue,  8 Aug 2017 21:28:02 +0530
Message-ID: <1502207885-11574-2-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/usb/cdc-phonet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 2952cb5..288ecd9 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -304,7 +304,7 @@ static void usbpn_setup(struct net_device *dev)
 /*
  * USB driver callbacks
  */
-static struct usb_device_id usbpn_ids[] = {
+static const struct usb_device_id usbpn_ids[] = {
 	{
 		.match_flags = USB_DEVICE_ID_MATCH_VENDOR
 			| USB_DEVICE_ID_MATCH_INT_CLASS
-- 
2.7.4
