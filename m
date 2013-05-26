From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v3 0/6] Adding pinctrl PM support for CPSW and MDIO
Date: Sun, 26 May 2013 23:53:30 +0530
Message-ID: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds the following features
* Adding pinctrl PM support for CPSW and MDIO for Power Optimization
* Adding phy address to the CPSW node for EVMsk board

Changes from initial version
* Fixed the multiline function call indentation as per David Miller
  recommendation.

Changes from v2
* Fixed the multi comment style as per net coding style
* Fixed checkpatch error (more than 80 characters)


Hebbar Gururaja (1):
  net: cpsw: enhance pinctrl support

Mugunthan V N (5):
  net: davinci_mdio: enhance pinctrl support
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to beaglebone
  ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to EVMsk
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to am335x EVM

 arch/arm/boot/dts/am335x-bone.dts      |   38 +++++++++++++++++++++
 arch/arm/boot/dts/am335x-evm.dts       |   36 ++++++++++++++++++++
 arch/arm/boot/dts/am335x-evmsk.dts     |   58 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c         |   48 ++++++++++++++++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c |   45 +++++++++++++++++++++++++
 5 files changed, 225 insertions(+)

-- 
1.7.9.5

