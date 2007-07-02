From: maximilian attems <max@stro.at>
Subject: [patch] dgrs romove Kconfig option
Date: Mon, 2 Jul 2007 15:52:01 +0200
Message-ID: <20070702135201.GA4779@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, Andres Salomon <dilinger@debian.org>,
	Alan <alan@lxorguk.ukuu.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:2039 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbXGBNwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 09:52:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nobody objected to adrian's rfc dropping dgrs on netdev back in dec. 2006.
-> http://marc.info/?l=linux-netdev&m=116507999803538&w=2
as bonus points this will get rid of a prorpietary licensed firmware.

so now be a bit more serious and remove the Kconfig entries
and see if anyone shouts. if no voice is to be heard as
expected by zero bug entries on kernel.org or debian.org,
the full removal is scheduled for 2.6.24.

Signed-off-by: maximilian attems <max@stro.at>
Acked-by: Alan <alan@lxorguk.ukuu.org.uk>


diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 7d3f205..306276e 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -348,3 +348,10 @@ Who:  Tejun Heo <htejun@gmail.com>
 
 ---------------------------
 
+What: drivers/net/dgrs.c
+When: option 2.6.23, code 2.6.24
+Why: no users, product never reached market
+Who: maximilian attems <max@stro.at>
+
+---------------------------
+
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7d57f4a..78a6a78 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1447,21 +1447,6 @@ config TC35815
 	depends on NET_PCI && PCI && MIPS
 	select MII
 
-config DGRS
-	tristate "Digi Intl. RightSwitch SE-X support"
-	depends on NET_PCI && (PCI || EISA)
-	---help---
-	  This is support for the Digi International RightSwitch series of
-	  PCI/EISA Ethernet switch cards. These include the SE-4 and the SE-6
-	  models.  If you have a network card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  More specific
-	  information is contained in <file:Documentation/networking/dgrs.txt>.
-
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
-	  will be called dgrs.
-
 config EEPRO100
 	tristate "EtherExpressPro/100 support (eepro100, original Becker driver)"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a77affa..209a079 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -38,7 +38,6 @@ obj-$(CONFIG_CASSINI) += cassini.o
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
-obj-$(CONFIG_DGRS) += dgrs.o
 obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
