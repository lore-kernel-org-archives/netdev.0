From: akpm@linux-foundation.org
Subject: [patch 01/21] usb net: asix does not really need 10/100mbit
Date: Fri, 28 Mar 2008 14:41:15 -0700
Message-ID: <200803282141.m2SLfFEh011801@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	vapier@gentoo.org, david-b@pacbell.net, greg@kroah.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33892 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756083AbYC1Vl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

The asix usb driver currently depends on NET_ETHERNET which means you
cannot enable this driver if you only have 1000mbit enabled in your kernel.
Since there is no real dependency between the NET_ETHERNET portion and the
asix driver, simply drop it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Cc: Greg KH <greg@kroah.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: David Brownell <david-b@pacbell.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/usb/Kconfig~usb-net-asix-does-not-really-need-10-100mbit drivers/net/usb/Kconfig
--- a/drivers/net/usb/Kconfig~usb-net-asix-does-not-really-need-10-100mbit
+++ a/drivers/net/usb/Kconfig
@@ -129,7 +129,7 @@ config USB_USBNET
 
 config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
-	depends on USB_USBNET && NET_ETHERNET
+	depends on USB_USBNET
 	select CRC32
 	default y
 	help
_
