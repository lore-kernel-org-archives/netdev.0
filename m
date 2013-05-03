From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/6] Adding pinctrl PM support for CPSW and Davinci MDIO drivers
Date: Fri, 3 May 2013 13:08:50 +0530
Message-ID: <1367566736-26644-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41587 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758995Ab3ECHjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 03:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the following features
* Adding pinctrl PM support for CPSW and MDIO for Power Optimization
* Adding phy address to the CPSW node for EVMsk board

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
 drivers/net/ethernet/ti/cpsw.c         |   49 +++++++++++++++++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c |   46 +++++++++++++++++++++++++
 5 files changed, 227 insertions(+)

-- 
1.7.9.5
