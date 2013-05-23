From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 0/6] Adding pinctrl PM support for CPSW and MDIO
Date: Thu, 23 May 2013 18:00:22 +0530
Message-ID: <1369312228-3308-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47429 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758440Ab3EWM3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 08:29:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the following features
* Adding pinctrl PM support for CPSW and MDIO for Power Optimization
* Adding phy address to the CPSW node for EVMsk board

Changes from initial version
* Fixed the multiline function call indentation as per David Miller
  recommendation.

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
