From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH 3/3] hso modem port detection fix patch
Date: Mon, 08 Dec 2008 11:44:57 +0100
Message-ID: <493CFAA9.6080401@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020003070701060401090704"
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:22643 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbYLHKpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 05:45:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020003070701060401090704
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch will clash with the previously posted.
[PATCH 1/3] hso modem signals patch fix & should only
be applied if the hso modem signals patch fix patch
is not applied.

Fixed incorrect check for the modem port,
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: netdev-2.6/drivers/net/usb/hso.c
===================================================================
--- netdev-2.6.orig/drivers/net/usb/hso.c	2008-12-08 11:29:03.000000000 +0100
+++ netdev-2.6/drivers/net/usb/hso.c	2008-12-08 11:30:00.000000000 +0100
@@ -2343,7 +2343,7 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM)
+	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM)
 		num_urbs = 2;
 	else
 		num_urbs = 1;



-- 
best regards,
D.J. Barrow

--------------020003070701060401090704
Content-Type: text/x-diff;
 name="hso_modem_port_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_modem_port_fix.patch"

Fixed incorrect check for the modem port,
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: netdev-2.6/drivers/net/usb/hso.c
===================================================================
--- netdev-2.6.orig/drivers/net/usb/hso.c	2008-12-08 11:29:03.000000000 +0100
+++ netdev-2.6/drivers/net/usb/hso.c	2008-12-08 11:30:00.000000000 +0100
@@ -2343,7 +2343,7 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM)
+	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM)
 		num_urbs = 2;
 	else
 		num_urbs = 1;

--------------020003070701060401090704--
