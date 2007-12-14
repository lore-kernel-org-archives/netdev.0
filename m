From: akpm@linux-foundation.org
Subject: [patch 09/10] bnx2x depends on ZLIB_INFLATE
Date: Thu, 13 Dec 2007 16:02:59 -0800
Message-ID: <200712140003.lBE0306f025535@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Lee.Schermerhorn@hp.com, eliezert@broadcom.com,
	lee.schermerhorn@hp.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44733 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934278AbXLNAJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:09:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

The bnx2x module depends on the zlib_inflate functions.  The build will
fail if ZLIB_INFLATE has not been selected manually or by building another
module that automatically selects it.

Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
and others.  This seems to fix it.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Eliezer Tamir <eliezert@broadcom.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/Kconfig~bnx2x-depends-on-zlib_inflate drivers/net/Kconfig
--- a/drivers/net/Kconfig~bnx2x-depends-on-zlib_inflate
+++ a/drivers/net/Kconfig
@@ -2607,6 +2607,7 @@ config TEHUTI
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
+	select ZLIB_INFLATE
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
_
