From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: add support for LAN9512 and LAN9514
Date: Fri,  1 May 2009 17:07:22 +0100
Message-ID: <1241194042-6800-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>, vlad.lyalikov@smsc.com,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:35905 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752499AbZEAQH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 12:07:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN9512 and LAN9514 are USB hubs with an integrated 10/100 ethernet
controller.  Logically this looks like an ethernet controller (similar
to LAN9500) permanently attached to one of the hub's downstream ports.

This patch adds the usb device id of the new ethernet controller to the
smsc95xx driver.  This id is the same in both new devices.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index dc16653..14440fa 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1231,6 +1231,11 @@ static const struct usb_device_id products[] = {
 		USB_DEVICE(0x0424, 0x9500),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
+	{
+		/* SMSC9512/9514 USB Hub & Ethernet Device */
+		USB_DEVICE(0x0424, 0xec00),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
 	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
-- 
1.6.0.6

