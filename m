From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 04/35] net: irda: irda-usb: constify usb_device_id
Date: Tue,  8 Aug 2017 21:26:40 +0530
Message-ID: <1502207805-11490-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/irda/irda-usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 6f3c805..723e49b 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -72,7 +72,7 @@
 static int qos_mtt_bits = 0;
 
 /* These are the currently known IrDA USB dongles. Add new dongles here */
-static struct usb_device_id dongles[] = {
+static const struct usb_device_id dongles[] = {
 	/* ACTiSYS Corp.,  ACT-IR2000U FIR-USB Adapter */
 	{ USB_DEVICE(0x9c4, 0x011), .driver_info = IUC_SPEED_BUG | IUC_NO_WINDOW },
 	/* Look like ACTiSYS, Report : IBM Corp., IBM UltraPort IrDA */
-- 
2.7.4
