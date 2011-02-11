From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] phy: Remove unneeded depends on PHYLIB
Date: Fri, 11 Feb 2011 15:14:06 -0700
Message-ID: <201102111514.06971.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unneeded depends on PHYLIB.  The config selection is already in
an if PHYLIB / endif block.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 35fda5a..392a6c4 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -77,7 +77,6 @@ config NATIONAL_PHY
 	  Currently supports the DP83865 PHY.
 
 config STE10XP
-	depends on PHYLIB
 	tristate "Driver for STMicroelectronics STe10Xp PHYs"
 	---help---
 	  This is the driver for the STe100p and STe101p PHYs.
