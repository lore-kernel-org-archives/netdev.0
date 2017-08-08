From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 28/35] wireless: ralink: rt2500usb: constify usb_device_id
Date: Tue,  8 Aug 2017 21:34:17 +0530
Message-ID: <1502208259-12287-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, sgruszka@redhat.com,
        helmut.schaa@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2500usb.c b/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
index 529e059..f4b48b7 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
@@ -1911,7 +1911,7 @@ static const struct rt2x00_ops rt2500usb_ops = {
 /*
  * rt2500usb module information.
  */
-static struct usb_device_id rt2500usb_device_table[] = {
+static const struct usb_device_id rt2500usb_device_table[] = {
 	/* ASUS */
 	{ USB_DEVICE(0x0b05, 0x1706) },
 	{ USB_DEVICE(0x0b05, 0x1707) },
-- 
2.7.4
