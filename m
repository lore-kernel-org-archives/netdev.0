From: David Hollis <dhollis@davehollis.com>
Subject: [PATCH] asix.c - Add Belkin F5D5055 ids
Date: Wed, 23 May 2007 07:33:17 -0400
Message-ID: <1179919997.6962.15.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0gyypkK/CnrgJtGO3pyw"
To: Jeff Garzik <jgarzik@pobox.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:44495 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758879AbXEWLi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 07:38:56 -0400
Received: from smtp.davehollis.com ([72.64.146.98])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JIH00KNNSCPTCV6@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 23 May 2007 06:38:49 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0gyypkK/CnrgJtGO3pyw
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

(Originally sent to linux-usb-devel)

The attached patch adds the device IDs for the Belkin F5D5055 device.
 
Reported by Andy Juniper <ajuniper@freeuk.com>
 
Signed-off-by: David Hollis <dhollis@davehollis.com>

-- 
David Hollis <dhollis@davehollis.com>

--=-0gyypkK/CnrgJtGO3pyw
Content-Description: 
Content-Disposition: inline; filename=asix.c-add-belkin-f5d5055.patch
Content-Type: text/x-patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/drivers/net/usb/asix.c	2007-05-11 08:18:35.000000000 -0400
+++ b/drivers/net/usb/asix.c	2007-05-23 03:27:29.000000000 -0400
@@ -1458,6 +1458,10 @@
 	// IO-DATA ETG-US2
 	USB_DEVICE (0x04bb, 0x0930),
 	.driver_info = (unsigned long) &ax88178_info,
+}, {
+	// Belkin F5D5055
+	USB_DEVICE(0x050d, 0x5055),
+	.driver_info = (unsigned long) &ax88178_info,
 },
 	{ },		// END
 };

--=-0gyypkK/CnrgJtGO3pyw--

