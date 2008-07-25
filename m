From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.26-git] net/usb/Kconfig: fix broken ordering
Date: Fri, 25 Jul 2008 00:36:57 -0700
Message-ID: <200807250036.58156.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp122.sbc.mail.sp1.yahoo.com ([69.147.64.95]:42432 "HELO
	smtp122.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751275AbYGYHhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 03:37:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Move the Kconfig for the new "Option" driver so it's not in the
middle of the usbnet-based drivers, so the dependency displays
in the Kconfig user interfaces don't get trashed.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/Kconfig |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

--- a/drivers/net/usb/Kconfig	2008-07-24 23:16:11.000000000 -0700
+++ b/drivers/net/usb/Kconfig	2008-07-24 23:17:22.000000000 -0700
@@ -154,17 +154,6 @@ config USB_NET_AX8817X
 	  This driver creates an interface named "ethX", where X depends on
 	  what other networking devices you have in use.
 
-config USB_HSO
-	tristate "Option USB High Speed Mobile Devices"
-	depends on USB && RFKILL
-	default n
-	help
-	  Choose this option if you have an Option HSDPA/HSUPA card.
-	  These cards support downlink speeds of 7.2Mbps or greater.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called hso.
-
 config USB_NET_CDCETHER
 	tristate "CDC Ethernet support (smart devices such as cable modems)"
 	depends on USB_USBNET
@@ -344,5 +333,15 @@ config USB_NET_ZAURUS
 	  really need this non-conformant variant of CDC Ethernet (or in
 	  some cases CDC MDLM) protocol, not "g_ether".
 
+config USB_HSO
+	tristate "Option USB High Speed Mobile Devices"
+	depends on USB && RFKILL
+	default n
+	help
+	  Choose this option if you have an Option HSDPA/HSUPA card.
+	  These cards support downlink speeds of 7.2Mbps or greater.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called hso.
 
 endmenu
