From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 12/20] mt7601u: constify usb_device_id
Date: Wed,  9 Aug 2017 21:58:24 +0530
Message-ID: <1502296104-21360-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org
To: kvalo@codeaurora.org, kubakici@wp.pl, matthias.bgg@gmail.com
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

 drivers/net/wireless/mediatek/mt7601u/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mediatek/mt7601u/usb.c b/drivers/net/wireless/mediatek/mt7601u/usb.c
index 416c604..b9e4f67 100644
--- a/drivers/net/wireless/mediatek/mt7601u/usb.c
+++ b/drivers/net/wireless/mediatek/mt7601u/usb.c
@@ -19,7 +19,7 @@
 #include "usb.h"
 #include "trace.h"
 
-static struct usb_device_id mt7601u_device_table[] = {
+static const struct usb_device_id mt7601u_device_table[] = {
 	{ USB_DEVICE(0x0b05, 0x17d3) },
 	{ USB_DEVICE(0x0e8d, 0x760a) },
 	{ USB_DEVICE(0x0e8d, 0x760b) },
-- 
2.7.4
