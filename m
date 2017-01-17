From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH v2 0/4] USB support for Broadcom NSP SoC
Date: Tue, 17 Jan 2017 11:14:26 -0500
Message-ID: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org,
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

This patch set contains the usb support for Broadcom NSP SoC. The
usb3 phy is internal to the SoC and is accessed through mdio interface.
The mdio interface can be used to access either internal usb3 phy or
external ethernet phy using a multiplexer.

The first patch provides the documentation details for usb3 phy. The
second patch provides the changes to the mdio bus driver. The third
patch provides the phy driver and fourth patch provides the enable
method for usb.

This patch series has been tested on NSP bcm958625HR board.
This patch series is based on v4.10.0-rc3 and is available from
github-repo: https://github.com/Broadcom/cygnus-linux.git
branch:nsp-usb-v2

Changes in v2:
* Remove separate nsp mux driver as suggested by Andrew Lunn
* Addressed comments from Scott and Rob

Yendapally Reddy Dhananjaya Reddy (4):
  dt-bindings: phy: Add documentation for NSP USB3 PHY
  net: phy: Initialize mdio clock at probe function
  phy: Add USB3 PHY support for Broadcom NSP SoC
  arm: dts: nsp: Add USB nodes to device tree

 .../devicetree/bindings/phy/brcm,nsp-usb3-phy.txt  |  39 +++++
 arch/arm/boot/dts/bcm-nsp.dtsi                     |  56 +++++++
 arch/arm/boot/dts/bcm958625k.dts                   |  16 ++
 drivers/net/phy/mdio-bcm-iproc.c                   |   6 +-
 drivers/phy/Kconfig                                |   8 +
 drivers/phy/Makefile                               |   1 +
 drivers/phy/phy-bcm-nsp-usb3.c                     | 176 +++++++++++++++++++++
 7 files changed, 298 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
 create mode 100644 drivers/phy/phy-bcm-nsp-usb3.c

-- 
2.1.0
