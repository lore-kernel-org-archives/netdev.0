From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] net/usb: mark LG VL600 LTE modem ethernet interface as WWAN
Date: Mon, 09 May 2011 12:43:20 -0500
Message-ID: <1304963011.5005.5.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrzej Zaborowski <andrew.zaborowski@intel.com>,
	Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab1EIRlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 13:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like other mobile broadband device ethernet interfaces, mark the LG
VL600 with the 'wwan' devtype so userspace knows it needs additional
configuration via the AT port before the interface can be used.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index a301479..c924ea2 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -567,7 +567,7 @@ static const struct usb_device_id	products [] = {
 {
 	USB_DEVICE_AND_INTERFACE_INFO(0x1004, 0x61aa, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-	.driver_info		= 0,
+	.driver_info = (unsigned long)&wwan_info,
 },
 
 /*


