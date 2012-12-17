From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2/2 v2] cdc_ether: cleanup: use
 USB_DEVICE_AND_INTERFACE_INFO for Novatel 551/E362
Date: Mon, 17 Dec 2012 12:19:46 -0600
Message-ID: <1355768386.1424.52.camel@dcbw.foobar.com>
References: <1355768261.1424.50.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@gnu.org>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792Ab2LQSSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 13:18:16 -0500
In-Reply-To: <1355768261.1424.50.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 drivers/net/usb/cdc_ether.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c4c593d..a74f35f 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -595,27 +595,15 @@ static const struct usb_device_id	products [] = {
 
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
 
-- 
1.7.11.7
