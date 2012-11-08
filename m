From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] cdc_ether: use USB_DEVICE_AND_INTERFACE_INFO for Novatel
 551L/E362
Date: Thu, 08 Nov 2012 12:09:12 -0600
Message-ID: <1352398152.22225.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@gnu.org>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756542Ab2KHSJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 13:09:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small cleanup.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Cc: stable@vger.kernel.org
---
 drivers/net/usb/cdc_ether.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index d012982..d095b39 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -594,27 +594,15 @@ static const struct usb_device_id	products [] = {
 
 /* Novatel USB551L and MC551 - handled by qmi_wwan */
 {
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = NOVATEL_VENDOR_ID,
-	.idProduct		= 0xB001,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(NOVATEL_VENDOR_ID, 0xB001, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
 	.driver_info = 0,
 },
 
 /* Novatel E362 - handled by qmi_wwan */
 {
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = NOVATEL_VENDOR_ID,
-	.idProduct		= 0x9010,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(NOVATEL_VENDOR_ID, 0x9010, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
 	.driver_info = 0,
 },
 
