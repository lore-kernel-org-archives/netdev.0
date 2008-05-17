From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] PHYLIB: Kconfig: Complete the list of Broadcom PHYs supported
Date: Sat, 17 May 2008 06:46:19 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805170641230.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:62773 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750946AbYEQFqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 01:46:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Add Broadcom PHYs supported missing from the description.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
patch-2.6.26-rc1-20080505-broadcom-phy-kconfig-0
diff -up --recursive --new-file linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig
--- linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig	2008-05-05 02:55:39.000000000 +0000
+++ linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig	2008-05-16 23:11:10.000000000 +0000
@@ -53,7 +53,8 @@ config SMSC_PHY
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
 	---help---
-	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
+	  Currently supports the BCM5411, BCM5421, BCM5461, BCM5464, BCM5481
+	  and BCM5482 PHYs.
 
 config ICPLUS_PHY
 	tristate "Drivers for ICPlus PHYs"
