From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 3/3] FIXED_PHY must depend on PHYLIB=y
Date: Tue, 04 Mar 2008 14:58:43 -0800
Message-ID: <200803042258.m24MwhPF001403@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	adrian.bunk@movial.fi, olaf@aepfle.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50493 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762690AbYCDW7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:59:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <adrian.bunk@movial.fi>

Fix the following build error introduced by commit
a79d8e93d300adb84cccc38ac396cfb118c238ad and reported by Olaf Hering:

arch/powerpc/sysdev/built-in.o: In function `of_add_fixed_phys':
fsl_soc.c:(.init.text+0xd34): undefined reference to `fixed_phy_add'

Signed-off-by: Adrian Bunk <adrian.bunk@movial.fi>
Tested-by: Olaf Hering <olaf@aepfle.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/phy/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/phy/Kconfig~fixed_phy-must-depend-on-phylib=y drivers/net/phy/Kconfig
--- a/drivers/net/phy/Kconfig~fixed_phy-must-depend-on-phylib=y
+++ a/drivers/net/phy/Kconfig
@@ -67,6 +67,7 @@ config REALTEK_PHY
 
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
+	depends on PHYLIB=y
 	---help---
 	  Adds the platform "fixed" MDIO Bus to cover the boards that use
 	  PHYs that are not connected to the real MDIO bus.
_
