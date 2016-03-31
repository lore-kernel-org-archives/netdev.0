From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] net: usb: cdc_ncm: adding Telit LE910 V2 mobile broadband card
Date: Thu, 31 Mar 2016 15:16:47 +0200
Message-ID: <1459430207-11757-2-git-send-email-dnlplm@gmail.com>
References: <1459430207-11757-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459430207-11757-1-git-send-email-dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Telit LE910 V2 is a mobile broadband card with no ARP capabilities:
the patch makes this device to use wwan_noarp_info struct

Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 86ba30b..2fb31ed 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1626,6 +1626,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long) &wwan_info,
 	},
 
+	/* Telit LE910 V2 */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1bc7, 0x0036,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* DW5812 LTE Verizon Mobile Broadband Card
 	 * Unlike DW5550 this device requires FLAG_NOARP
 	 */
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
