From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next V2 3/3] net: cdc_ncm: remove non-standard NCM device IDs
Date: Thu, 22 Aug 2013 04:30:41 +0200
Message-ID: <1377138641-2765-4-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
 <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove device IDs of NCM-like (but not NCM-conformant) devices, that are
handled by the huawwei_cdc_ncm driver now.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 62686be..31f43f7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1236,17 +1236,6 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
-	/* Huawei NCM devices disguised as vendor specific */
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-
 	/* Infineon(now Intel) HSPA Modem platform */
 	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
 		USB_CLASS_COMM,
-- 
1.7.10.4
