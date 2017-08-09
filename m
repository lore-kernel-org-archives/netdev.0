From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 15/20] rt73usb: constify usb_device_id
Date: Wed,  9 Aug 2017 21:59:48 +0530
Message-ID: <1502296188-21563-1-git-send-email-arvind.yadav.cs@gmail.com>
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
changes in v2:
              Re-submitting wireless separately.

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
