From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 0/5] add NS2 support to bgmac
Date: Wed, 26 Oct 2016 15:35:56 -0400
Message-ID: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the amac found in the Broadcom Northstar2 SoC to the
bgmac driver.  This necessitates adding support to connect to an
externally defined phy (as described in the device tree) in the driver.
These phy changes are in addition to the changes necessary to get NS2
working.

This series (based on the net-next git tree) has been tested on NSP and
NS2 HW.

Jon Mason (4):
  Documentation: devicetree: net: add NS2 bindings to amac
  net: ethernet: bgmac: device tree phy enablement
  net: ethernet: bgmac: add NS2 support
  arm64: dts: NS2: add AMAC ethernet support

Vikas Soni (1):
  net: phy: broadcom: Add BCM54810 phy entry

 .../devicetree/bindings/net/brcm,amac.txt          |   7 +-
 arch/arm64/boot/dts/broadcom/ns2-svk.dts           |   5 +
 arch/arm64/boot/dts/broadcom/ns2.dtsi              |  12 +++
 drivers/net/ethernet/broadcom/bgmac-bcma.c         |  48 +++++++++
 drivers/net/ethernet/broadcom/bgmac-platform.c     | 108 ++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bgmac.c              |  56 +----------
 drivers/net/ethernet/broadcom/bgmac.h              |   9 ++
 drivers/net/phy/Kconfig                            |   2 +-
 drivers/net/phy/broadcom.c                         |  65 +++++++++++++
 include/linux/brcmphy.h                            |   7 ++
 10 files changed, 264 insertions(+), 55 deletions(-)

-- 
2.7.4
