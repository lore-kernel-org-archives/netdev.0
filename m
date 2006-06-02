From: akpm@osdl.org
Subject: [patch 02/17] remove dead entry in net wan Kconfig
Date: Thu, 01 Jun 2006 20:32:21 -0700
Message-ID: <200606020328.k523S3vg028808@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, paulkf@microgate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57780 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751197AbWFBD2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:10 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Paul Fulghum <paulkf@microgate.com>

Remove dead entry from net wan Kconfig.  This entry is left over from 2.4
where synclink used syncppp driver directly.  synclink drivers now use
generic HDLC

Signed-off-by: Paul Fulghum <paulkf@microgate.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wan/Kconfig |   12 ------------
 1 file changed, 12 deletions(-)

diff -puN drivers/net/wan/Kconfig~remove-dead-entry-in-net-wan-kconfig drivers/net/wan/Kconfig
--- devel/drivers/net/wan/Kconfig~remove-dead-entry-in-net-wan-kconfig	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/drivers/net/wan/Kconfig	2006-06-01 20:31:49.000000000 -0700
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
_
