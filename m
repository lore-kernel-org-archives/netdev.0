From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 10:58:05 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41241 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155AbYFBP6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 11:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core portions of the phylib aren't capable of being used as
a module.  This isn't really any different than something like i2c
in that the bus driver and core need to be built into the kernel.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Jeff, please consider this for 2.6.26 as w/o it we get build issues
if phylib is config'd as a module on ppc.

 drivers/net/phy/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6eb2d31..ab04cc7 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -3,7 +3,7 @@
 #

 menuconfig PHYLIB
-	tristate "PHY Device support and infrastructure"
+	bool "PHY Device support and infrastructure"
 	depends on !S390
 	depends on NET_ETHERNET
 	help
-- 
1.5.4.5

