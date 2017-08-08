From: Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 30/35] wireless: ralink: rt73usb: constify usb_device_id
Date: Tue,  8 Aug 2017 21:34:19 +0530
Message-ID: <1502208259-12287-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502208259-12287-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1502208259-12287-1-git-send-email-arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ralink/rt2x00/rt73usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt73usb.c b/drivers/net/wireless/ralink/rt2x00/rt73usb.c
index fd91322..9a21282 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt73usb.c
@@ -2408,7 +2408,7 @@ static const struct rt2x00_ops rt73usb_ops = {
 /*
  * rt73usb module information.
  */
-static struct usb_device_id rt73usb_device_table[] = {
+static const struct usb_device_id rt73usb_device_table[] = {
 	/* AboCom */
 	{ USB_DEVICE(0x07b8, 0xb21b) },
 	{ USB_DEVICE(0x07b8, 0xb21c) },
-- 
2.7.4
