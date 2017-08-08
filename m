From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 07/35] net: irda: ksdazzle: constify usb_device_id
Date: Tue,  8 Aug 2017 21:26:43 +0530
Message-ID: <1502207805-11490-4-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/irda/ksdazzle-sir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 741452c..d2a0755 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -97,7 +97,7 @@
 #define KSDAZZLE_PRODUCT_ID 0x4100
 
 /* These are the currently known USB ids */
-static struct usb_device_id dongles[] = {
+static const struct usb_device_id dongles[] = {
 	/* KingSun Co,Ltd  IrDA/USB Bridge */
 	{USB_DEVICE(KSDAZZLE_VENDOR_ID, KSDAZZLE_PRODUCT_ID)},
 	{}
-- 
2.7.4
