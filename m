From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 0/6] USB support for Broadcom NSP SoC
Date: Wed,  9 Nov 2016 04:33:08 -0500
Message-ID: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set contains the usb support for Broadcom NSP SoC.
The usb phy is connected through mdio interface. The mdio interface
can be used to access either internal phys or external phys using a
multiplexer.

The first patch provides the documentation details for mdio-mux and
second patch provides the documentation details for usb3 phy. The third
patch contains the mdio-mux support and fourth patch contains the
changes to the mdio bus driver.

The fifth patch provides the phy driver and sixth patch provides the
enable method for usb.

This patch series has been tested on NSP bcm958625HR board.
This patch series is based on v4.9.0-rc1 and is available from github-
repo: https://github.com/Broadcom/cygnus-linux.git
branch:nsp-usb-v1


Yendapally Reddy Dhananjaya Reddy (6):
  dt-bindings: mdio-mux: Add documentation for mdio mux for NSP SoC
  dt-bindings: phy: Add documentation for NSP USB3 PHY
  net: mdio-mux: Add MDIO mux driver for NSP SoC
  net: phy: Initialize mdio clock at probe function
  phy: Add USB3 PHY support for Broadcom NSP SoC
  arm: dts: nsp: Add USB nodes to device tree

 .../devicetree/bindings/net/brcm,mdio-mux-nsp.txt  |  57 +++++++
 .../devicetree/bindings/phy/brcm,nsp-usb3-phy.txt  |  39 +++++
 arch/arm/boot/dts/bcm-nsp.dtsi                     |  57 +++++++
 arch/arm/boot/dts/bcm958625k.dts                   |  16 ++
 drivers/net/phy/Kconfig                            |   9 ++
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-bcm-iproc.c                   |   6 +-
 drivers/net/phy/mdio-mux-bcm-nsp.c                 | 121 ++++++++++++++
 drivers/phy/Kconfig                                |   9 ++
 drivers/phy/Makefile                               |   1 +
 drivers/phy/phy-bcm-nsp-usb3.c                     | 176 +++++++++++++++++++++
 11 files changed, 488 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
 create mode 100644 drivers/net/phy/mdio-mux-bcm-nsp.c
 create mode 100644 drivers/phy/phy-bcm-nsp-usb3.c

-- 
2.1.0
