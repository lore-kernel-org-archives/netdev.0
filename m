From: akpm@osdl.org
Subject: [patch 1/5] remove dead entry in net wan Kconfig
Date: Fri, 30 Jun 2006 02:27:19 -0700
Message-ID: <200606300927.k5U9RJRj001455@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, paulkf@microgate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35472 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751699AbWF3J1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:27:38 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Fulghum <paulkf@microgate.com>

Remove dead entry from net wan Kconfig and net wan Makefile..  This entry is
left over from 2.4 where synclink used syncppp driver directly.  synclink
drivers now use generic HDLC

Signed-off-by: Paul Fulghum <paulkf@microgate.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wan/Kconfig  |   12 ------------
 drivers/net/wan/Makefile |    1 -
 2 files changed, 13 deletions(-)

diff -puN drivers/net/wan/Kconfig~remove-dead-entry-in-net-wan-kconfig drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig~remove-dead-entry-in-net-wan-kconfig
+++ a/drivers/net/wan/Kconfig
@@ -134,18 +134,6 @@ config SEALEVEL_4021
 	  The driver will be compiled as a module: the
 	  module will be called sealevel.
 
-config SYNCLINK_SYNCPPP
-	tristate "SyncLink HDLC/SYNCPPP support"
-	depends on WAN
-	help
-	  Enables HDLC/SYNCPPP support for the SyncLink WAN driver.
-
-	  Normally the SyncLink WAN driver works with the main PPP driver
-	  <file:drivers/net/ppp_generic.c> and pppd program.
-	  HDLC/SYNCPPP support allows use of the Cisco HDLC/PPP driver
-	  <file:drivers/net/wan/syncppp.c>. The SyncLink WAN driver (in
-	  character devices) must also be enabled.
-
 # Generic HDLC
 config HDLC
 	tristate "Generic HDLC layer"
diff -puN drivers/net/wan/Makefile~remove-dead-entry-in-net-wan-kconfig drivers/net/wan/Makefile
--- a/drivers/net/wan/Makefile~remove-dead-entry-in-net-wan-kconfig
+++ a/drivers/net/wan/Makefile
@@ -28,7 +28,6 @@ obj-$(CONFIG_COSA)		+=		syncppp.o	cosa.o
 obj-$(CONFIG_FARSYNC)		+=		syncppp.o	farsync.o
 obj-$(CONFIG_DSCC4)             +=				dscc4.o
 obj-$(CONFIG_LANMEDIA)		+=		syncppp.o
-obj-$(CONFIG_SYNCLINK_SYNCPPP)	+=		syncppp.o
 obj-$(CONFIG_X25_ASY)		+= x25_asy.o
 
 obj-$(CONFIG_LANMEDIA)		+= lmc/
_
