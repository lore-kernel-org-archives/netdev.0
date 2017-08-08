From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 06/35] net: irda: ks959: constify usb_device_id
Date: Tue,  8 Aug 2017 21:26:42 +0530
Message-ID: <1502207805-11490-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502207805-11490-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502207805-11490-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/irda/ks959-sir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 3affded..8025741 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -133,7 +133,7 @@
 #define KS959_PRODUCT_ID 0x4959
 
 /* These are the currently known USB ids */
-static struct usb_device_id dongles[] = {
+static const struct usb_device_id dongles[] = {
 	/* KingSun Co,Ltd  IrDA/USB Bridge */
 	{USB_DEVICE(KS959_VENDOR_ID, KS959_PRODUCT_ID)},
 	{}
-- 
2.7.4
