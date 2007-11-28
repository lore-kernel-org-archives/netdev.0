From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Subject: PATCH 2.6.24-rc3-mm2 - build breakage - bnx2x depends on
	ZLIB_INFLATE
Date: Wed, 28 Nov 2007 15:25:24 -0500
Message-ID: <1196281524.5318.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760103AbXK1UZ0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Couldn't find one of these on the lists...

PATCH 2.6.24-rc3-mm1:  bnx2x depends on ZLIB_INFLATE

The bnx2x module depends on the zlib_inflate functions.  The
build will fail if ZLIB_INFLATE has not been selected manually
or by building another module that automatically selects it.

Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
and others.  This seems to fix it.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: Linux/drivers/net/Kconfig
===================================================================
--- Linux.orig/drivers/net/Kconfig	2007-11-28 10:41:23.000000000 -0500
+++ Linux/drivers/net/Kconfig	2007-11-28 12:40:16.000000000 -0500
@@ -2606,6 +2606,7 @@ config TEHUTI
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
+	select ZLIB_INFLATE
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
