From: David Brownell <david-b@pacbell.net>
Subject: Re: [00/04] HSO driver bugfixes and updates
Date: Fri, 8 Aug 2008 13:53:29 -0700
Message-ID: <200808081353.30130.david-b@pacbell.net>
References: <20080808190023.GA2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, Jari Tenhunen <jari.tenhunen@iki.fi>,
	Olivier Blin <blino@mandriva.com>,
	Andrew Bird <ajb@spheresystems.co.uk>,
	Paul Rolland <rol@witbe.net>,
	Arjan van de Ven <arjan@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Greg KH <greg@kroah.com>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:40806 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754661AbYHHUxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 16:53:32 -0400
In-Reply-To: <20080808190023.GA2953@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 August 2008, Greg KH wrote:
> Jeff,
> 
> Here are 4 patches against 2.6.27-rc2 for the drivers/net/usb/hso.c
> driver.

And here's a fifth (resent) ... just fixing brokenKconfig.

==== CUT HERE
From: David Brownell <dbrownell@users.sourceforge.net>

Move the Kconfig for the new "Option" driver so it's not in the
middle of the usbnet-based drivers, so the dependency displays
in the Kconfig user interfaces don't get trashed.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/Kconfig |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

--- a/drivers/net/usb/Kconfig	2008-07-26 17:11:01.000000000 -0700
+++ b/drivers/net/usb/Kconfig	2008-07-26 17:40:33.000000000 -0700
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
@@ -337,5 +326,15 @@ config USB_NET_ZAURUS
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
