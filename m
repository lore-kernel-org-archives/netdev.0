From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 08/35] net: irda: mcs7780: constify usb_device_id
Date: Tue,  8 Aug 2017 21:26:44 +0530
Message-ID: <1502207805-11490-5-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/irda/mcs7780.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 6f6ed75..32fa4a9 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -66,7 +66,7 @@
 #define MCS_VENDOR_ID 0x9710
 #define MCS_PRODUCT_ID 0x7780
 
-static struct usb_device_id mcs_table[] = {
+static const struct usb_device_id mcs_table[] = {
 	/* MosChip Corp.,  MCS7780 FIR-USB Adapter */
 	{USB_DEVICE(MCS_VENDOR_ID, MCS_PRODUCT_ID)},
 	{},
-- 
2.7.4
