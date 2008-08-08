From: Greg KH <greg@kroah.com>
Subject: [03/04] USB: HSO: make tty_operations const
Date: Fri, 8 Aug 2008 12:02:14 -0700
Message-ID: <20080808190214.GD2953@kroah.com>
References: <20080808190023.GA2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Jari Tenhunen <jari.tenhunen@iki.fi>,
	Olivier Blin <blino@mandriva.com>,
	Andrew Bird <ajb@spheresystems.co.uk>,
	Paul Rolland <rol@witbe.net>,
	Arjan van de Ven <arjan@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36341 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759512AbYHHTFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 15:05:23 -0400
Content-Disposition: inline
In-Reply-To: <20080808190023.GA2953@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>

As recommended by Arjan.

Cc: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Bird <ajb@spheresystems.co.uk>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/usb/hso.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2725,7 +2725,7 @@ static int hso_mux_submit_intr_urb(struc
 }
 
 /* operations setup of the serial interface */
-static struct tty_operations hso_serial_ops = {
+static const struct tty_operations hso_serial_ops = {
 	.open = hso_serial_open,
 	.close = hso_serial_close,
 	.write = hso_serial_write,
