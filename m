From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] PHYLIB: Kconfig: Fix the dependency on S390
Date: Sat, 17 May 2008 07:07:36 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805170647110.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:62944 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751211AbYEQGHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 02:07:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 PHYLIB was first marked as BROKEN on S390, then the enclosing menu marked 
as non-S390, then the two dependencies merged with the conversion to 
menuconfig.  Reduce to non-S390.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
patch-2.6.26-rc1-20080505-phy-s390-1
diff -up --recursive --new-file linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig
--- linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig	2008-05-05 02:55:39.000000000 +0000
+++ linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig	2008-05-17 05:57:43.000000000 +0000
@@ -5,7 +5,7 @@
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on !S390
-	depends on NET_ETHERNET && (BROKEN || !S390)
+	depends on NET_ETHERNET
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
