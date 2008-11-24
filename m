From: Denis Joseph Barrow <D.Barow@option.com>
Subject: respin of hso patches for linux-2.6.28-rc6 hso_new_ids.patch [patch
 1/6]
Date: Mon, 24 Nov 2008 15:39:50 +0100
Message-ID: <492ABCB6.9010406@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000901090501080006010101"
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:61360 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbYKXOjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:39:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000901090501080006010101
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

These patches have been also tested against
Dave Millers net tree net-next tree
& Jeff Garziks netdev_next tree

The patches are posted in order of simplicity & importance
the last patches in the list are the least vital.

The series file is as follows

hso_new_ids.patch
hso_close_fix.patch
hso_einval.patch
hso_mutex.patch
hso_modem_signals.patch
hso_reset_resume.patch	

Add new usb device id's supported by the hso driver.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 14:01:02.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 14:01:45.000000000 +0100
@@ -417,6 +417,11 @@
 	{USB_DEVICE(0x0af0, 0x7401)},		/* GI 0401 */
 	{USB_DEVICE(0x0af0, 0x7501)},		/* GTM 382 */
 	{USB_DEVICE(0x0af0, 0x7601)},		/* GE40x */
+	{USB_DEVICE(0x0af0, 0x7701)},
+	{USB_DEVICE(0x0af0, 0x7801)},
+	{USB_DEVICE(0x0af0, 0x7901)},
+	{USB_DEVICE(0x0af0, 0x7361)},
+	{icon321_port_device(0x0af0, 0xd051)},
 	{}
 };
 MODULE_DEVICE_TABLE(usb, hso_ids);



-- 
best regards,
D.J. Barrow

--------------000901090501080006010101
Content-Type: text/x-diff;
 name="hso_new_ids.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_new_ids.patch"

Add new usb device id's supported by the hso driver.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 14:01:02.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 14:01:45.000000000 +0100
@@ -417,6 +417,11 @@
 	{USB_DEVICE(0x0af0, 0x7401)},		/* GI 0401 */
 	{USB_DEVICE(0x0af0, 0x7501)},		/* GTM 382 */
 	{USB_DEVICE(0x0af0, 0x7601)},		/* GE40x */
+	{USB_DEVICE(0x0af0, 0x7701)},
+	{USB_DEVICE(0x0af0, 0x7801)},
+	{USB_DEVICE(0x0af0, 0x7901)},
+	{USB_DEVICE(0x0af0, 0x7361)},
+	{icon321_port_device(0x0af0, 0xd051)},
 	{}
 };
 MODULE_DEVICE_TABLE(usb, hso_ids);

--------------000901090501080006010101--
