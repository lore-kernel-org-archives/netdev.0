From: Laura Abbott <labbott@redhat.com>
Subject: Duplicate MDIO_XGENE Kconfig entries
Date: Thu, 6 Oct 2016 09:01:27 -0700
Message-ID: <5fed0550-56d1-d019-86bf-2a882c0bf457@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

While working on the Fedora tree today, I noticed that there
seem to be two entries for CONFIG_MDIO_XGENE. It looks like
this might have been fall out from d75b4a22b255 ("net: phy:
Sort Makefile and Kconfig"). I can submit the following if
this isn't fixed up elsewhere already

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5078a0d..fe064ba 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -141,6 +141,7 @@ config MDIO_THUNDER
           device.
  
  config MDIO_XGENE
+       depends on ARCH_XGENE || COMPILE_TEST
         tristate "APM X-Gene SoC MDIO bus controller"
         help
           This module provides a driver for the MDIO busses found in the
@@ -320,13 +321,6 @@ config XILINX_GMII2RGMII
           the Reduced Gigabit Media Independent Interface(RGMII) between
           Ethernet physical media devices and the Gigabit Ethernet controller.
  
-config MDIO_XGENE
-       tristate "APM X-Gene SoC MDIO bus controller"
-       depends on ARCH_XGENE || COMPILE_TEST
-       help
-         This module provides a driver for the MDIO busses found in the
-         APM X-Gene SoC's.
-
  endif # PHYLIB
  
  config MICREL_KS8995MA
