From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [USBNET] ASIX: Add IO-DATA ETG-US2 Support.
Date: Fri, 26 Jan 2007 22:57:38 +0900 (JST)
Message-ID: <20070126.225738.24355200.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47055 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965653AbXAZN4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 08:56:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/usb/net/asix.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/net/asix.c b/drivers/usb/net/asix.c
index 896449f..4206df2 100644
--- a/drivers/usb/net/asix.c
+++ b/drivers/usb/net/asix.c
@@ -1449,6 +1449,10 @@ static const struct usb_device_id	products [] = {
 	// Linksys USB1000
 	USB_DEVICE (0x1737, 0x0039),
 	.driver_info = (unsigned long) &ax88178_info,
+}, {
+	// IO-DATA ETG-US2
+	USB_DEVICE (0x04bb, 0x0930),
+	.driver_info = (unsigned long) &ax88178_info,
 },
 	{ },		// END
 };
-- 
1.4.4.1.g562ce

