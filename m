From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/8] add phy driver for Atheros AR8031 and CPSW phy-mode DT enhancement
Date: Tue, 4 Jun 2013 11:40:03 +0530
Message-ID: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds the following feature
* Atheros phy driver code cleanup
* Add AT8031 phy driver to at803x driver
* Add RGMII tx delay support via phy_if
* Add phy_if DT enhancement to CPSW Driver and DT

Mugunthan V N (8):
  drivers: net: phy: at803x code cleanup on register and unregister
    driver
  drivers: net: phy: at803x: seperate wol specific code to wol standard
    apis
  drivers: net: phy: at803x: add interface mode support
  drivers: net: phy: at803x: add support for AT8031
  ARM: OMAP2+: omap2plus_defconfig: Enable Atheros support
  ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
  drivers: net: ethernet: cpsw: add phy-mode support to cpsw driver
  ARM: dts: AM33XX: Add phy-mode to CPSW node

 Documentation/devicetree/bindings/net/cpsw.txt |    6 ++
 arch/arm/boot/dts/am335x-bone.dts              |    2 +
 arch/arm/boot/dts/am335x-evm.dts               |    2 +
 arch/arm/boot/dts/am335x-evmsk.dts             |   10 ++
 arch/arm/configs/omap2plus_defconfig           |    1 +
 drivers/net/ethernet/ti/cpsw.c                 |    2 +
 drivers/net/phy/at803x.c                       |  128 ++++++++++++++++--------
 7 files changed, 111 insertions(+), 40 deletions(-)

-- 
1.7.9.5

