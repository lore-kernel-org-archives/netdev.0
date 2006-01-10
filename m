From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/irda/Kconfig: DONGLE_OLD: remove dependency on non-existing symbol
Date: Tue, 10 Jan 2006 18:09:03 +0100
Message-ID: <20060110170903.GQ3911@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Jean-Luc Leger <reiga@dspnet.fr.eu.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932266AbWAJRJH@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean-Luc Leger <reiga@dspnet.fr.eu.org> reported this alternative 
dependency on a non-existing symbol.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.15-mm2-full/drivers/net/irda/Kconfig.old	2006-01-10 17:48:41.000000000 +0100
+++ linux-2.6.15-mm2-full/drivers/net/irda/Kconfig	2006-01-10 17:48:59.000000000 +0100
@@ -1,4 +1,3 @@
-
 menu "Infrared-port device drivers"
 	depends on IRDA!=n
 
@@ -156,7 +155,7 @@
 
 config DONGLE_OLD
 	bool "Old Serial dongle support"
-	depends on (IRTTY_OLD || IRPORT_SIR) && BROKEN_ON_SMP
+	depends on IRPORT_SIR && BROKEN_ON_SMP
 	help
 	  Say Y here if you have an infrared device that connects to your
 	  computer's serial port. These devices are called dongles. Then say Y
