From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 09/11] DM9000: Re-unit menuconfig entries for DM9000 driver
Date: Sun, 22 Jun 2008 21:16:54 +0100
Message-ID: <20080622201906.285402632@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56683 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754914AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-menuconfig.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ENC28J60 driver ended up adding itself inbetween the
two DM9000 Kconfig entries, so re-unite the two together.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc7-next20080620/drivers/net/Kconfig
===================================================================
--- linux-2.6.26-rc7-next20080620.orig/drivers/net/Kconfig	2008-06-22 21:12:24.000000000 +0100
+++ linux-2.6.26-rc7-next20080620/drivers/net/Kconfig	2008-06-22 21:12:34.000000000 +0100
@@ -938,6 +938,14 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
 
+config DM9000_DEBUGLEVEL
+	int "DM9000 maximum debug level"
+	depends on DM9000
+	default 4
+	help
+	  The maximum level of debugging code compiled into the DM9000
+	  driver.
+
 config DM9000_FORCE_SIMPLE_PHY_POLL
 	bool "Force simple NSR based PHY polling"
 	depends on DM9000
@@ -964,14 +972,6 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
-config DM9000_DEBUGLEVEL
-	int "DM9000 maximum debug level"
-	depends on DM9000
-	default 4
-	help
-	  The maximum level of debugging code compiled into the DM9000
-	  driver.
-
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
