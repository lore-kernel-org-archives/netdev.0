From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 1a/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 23:08:41 +0200
Message-ID: <m3ejlsfijq.fsf_-_@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3y7k1biov.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705070343330.2733@scrub.home>
	<m3tzupc6wz.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071318150.1479@scrub.home>
	<m3r6psc0ee.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071509290.1479@scrub.home>
	<463F27CE.2040008@garzik.org>
	<Pine.LNX.4.64.0705071538060.1479@scrub.home>
	<m3lkg0a88y.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071901020.1479@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roman Zippel <zippel@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55910 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966969AbXEGVIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:08:44 -0400
In-Reply-To: <Pine.LNX.4.64.0705071901020.1479@scrub.home> (Roman Zippel's message of "Mon, 7 May 2007 19:07:43 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow enabling WAN drivers without selecting generic HDLC first,
HDLC will be selected automatically.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- linux/drivers/net/wan/Kconfig	2007-05-07 22:46:06.000000000 +0200
+++ linux/drivers/net/wan/Kconfig	2007-05-07 22:45:13.000000000 +0200
@@ -169,7 +169,8 @@
 
 config PCI200SYN
 	tristate "Goramo PCI200SYN support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Driver for PCI200SYN cards by Goramo sp. j.
 
@@ -183,7 +184,8 @@
 
 config WANXL
 	tristate "SBE Inc. wanXL support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Driver for wanXL PCI cards by SBE Inc.
 
@@ -206,7 +208,8 @@
 
 config PC300
 	tristate "Cyclades-PC300 support (RS-232/V.35, X.21, T1/E1 boards)"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	---help---
 	  Driver for the Cyclades-PC300 synchronous communication boards.
 
@@ -228,14 +231,15 @@
 	  Multilink PPP over the PC300 synchronous communication boards.
 
 comment "Cyclades-PC300 MLPPP support is disabled."
-	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 comment "Refer to the file README.mlppp, provided by PC300 package."
-	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 config PC300TOO
 	tristate "Cyclades PC300 RSV/X21 alternative support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Alternative driver for PC300 RSV/X21 PCI cards made by
 	  Cyclades, Inc. If you have such a card, say Y here and see
@@ -248,7 +252,8 @@
 
 config N2
 	tristate "SDL RISCom/N2 support"
-	depends on HDLC && ISA
+	depends on ISA
+	select HDLC
 	help
 	  Driver for RISCom/N2 single or dual channel ISA cards by
 	  SDL Communications Inc.
@@ -265,7 +270,8 @@
 
 config C101
 	tristate "Moxa C101 support"
-	depends on HDLC && ISA
+	depends on ISA
+	select HDLC
 	help
 	  Driver for C101 SuperSync ISA cards by Moxa Technologies Co., Ltd.
 
@@ -279,7 +285,8 @@
 
 config FARSYNC
 	tristate "FarSync T-Series support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	---help---
 	  Support for the FarSync T-Series X.21 (and V.35/V.24) cards by
 	  FarSite Communications Ltd.
@@ -298,7 +305,8 @@
 
 config DSCC4
 	tristate "Etinc PCISYNC serial board support"
-	depends on HDLC && PCI && m
+	depends on PCI && m
+	select HDLC
 	help
 	  Driver for Etinc PCISYNC boards based on the Infineon (ex. Siemens)
 	  DSCC4 chipset.
