From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v4 0/5] Adding pinctrl PM support for CPSW and MDIO
Date: Wed, 5 Jun 2013 22:38:14 +0530
Message-ID: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36184 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553Ab3FERHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 13:07:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the following features
* Adding pinctrl PM support for CPSW and MDIO for Power Optimization
* Adding phy address to the CPSW node for EVMsk board

Changes from initial version
* Fixed the multiline function call indentation as per David Miller
  recommendation.

Changes from v2
* Fixed the multi comment style as per net coding style
* Fixed checkpatch error (more than 80 characters)

Changes from v3
* Removed below patch as it has already merged to net-next
	ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
* Rebased to net-next as there was a merge conflict in DT files

Hebbar Gururaja (1):
  net: cpsw: enhance pinctrl support

Mugunthan V N (4):
  net: davinci_mdio: enhance pinctrl support
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to beaglebone
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to EVMsk
  ARM: dts: AM33XX: Add pinmux configuration for CPSW to am335x EVM

 arch/arm/boot/dts/am335x-bone.dts      |   38 ++++++++++++++++++++++++
 arch/arm/boot/dts/am335x-evm.dts       |   36 +++++++++++++++++++++++
 arch/arm/boot/dts/am335x-evmsk.dts     |   50 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c         |   48 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c |   45 ++++++++++++++++++++++++++++
 5 files changed, 217 insertions(+)

-- 
1.7.9.5
