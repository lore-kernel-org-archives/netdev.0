From: =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
Subject: [PATCH] phy: mdio-thunder: Fix some Kconfig typos
Date: Thu, 17 Mar 2016 00:23:37 +0100
Message-ID: <1458170617-31784-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	=?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop two extra occurrences of "on" in option title and help text.

=46ixes: 379d7ac7ca31 ("phy: mdio-thunder: Add driver for Cavium Thunde=
r SoC MDIO buses.")
Cc: David Daney <david.daney@cavium.com>
Signed-off-by: Andreas F=C3=A4rber <afaerber@suse.de>
---
 drivers/net/phy/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 075a4cc175b1..6dad9a9c356c 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -197,13 +197,13 @@ config MDIO_OCTEON
 	  drivers on some systems.
=20
 config MDIO_THUNDER
-	tristate "Support for MDIO buses on on ThunderX SOCs"
+	tristate "Support for MDIO buses on ThunderX SOCs"
 	depends on 64BIT
 	depends on PCI
 	select MDIO_CAVIUM
 	help
 	  This driver supports the MDIO interfaces found on Cavium
-	  ThunderX SoCs when the MDIO bus device appears on as a PCI
+	  ThunderX SoCs when the MDIO bus device appears as a PCI
 	  device.
=20
=20
--=20
2.6.2
