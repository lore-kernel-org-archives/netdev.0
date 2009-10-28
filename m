From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: [PATCH kernel 2.6.32-rc5] [RESEND] netdev: usb: dm9601.c can drive a device not supported yet, add support for it
Date: Wed, 28 Oct 2009 16:34:21 +0100
Message-ID: <200910281634.23635.jkrzyszt@tis.icnet.pl>
References: <200910222025.50405.jkrzyszt@tis.icnet.pl> <87my3jnts0.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:37740 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346AbZJ1Pem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 11:34:42 -0400
In-Reply-To: <87my3jnts0.fsf@macbook.be.48ers.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found that the current version of drivers/net/usb/dm9601.c can be used to
successfully drive a low-power, low-cost network adapter with USB ID
0a46:9000, based on a DM9000E chipset. As no device with this ID is yet
present in the kernel, I have created a patch that adds support for the device
to the dm9601 driver.

Created and tested against linux-2.6.32-rc5.

Signed-off-by: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

---
Thursday 22 October 2009 20:54:55 Peter Korsgaard wrote:

> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

I'm not sure if there was sometning wrong with my initial submition, but since
the patch, unlike others, has not been applied since acked last week, neither
to net-2.6 nor net-next-2.6, I decided to resend it, with a slightly modified
subject, and CC: David this time.

Thanks,
Janusz

--- linux-2.6.32-rc5/drivers/net/usb/dm9601.c.orig	2009-10-22 20:14:00.000000000 +0200
+++ linux-2.6.32-rc5/drivers/net/usb/dm9601.c	2009-10-22 20:14:04.000000000 +0200
@@ -649,6 +649,10 @@ static const struct usb_device_id produc
 	USB_DEVICE(0x0fe6, 0x8101),	/* DM9601 USB to Fast Ethernet Adapter */
 	.driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 

