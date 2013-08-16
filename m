From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH] net: cdc_ncm: remove non-standard NCM device IDs
Date: Fri, 16 Aug 2013 15:47:09 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1308161544220.24009@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
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
