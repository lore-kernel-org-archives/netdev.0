From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch net-next 00/11] net: fec: imx6sx multiqueue support
Date: Thu, 4 Sep 2014 04:38:06 +0800
Message-ID: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0207.outbound.protection.outlook.com ([207.46.163.207]:56049
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756050AbaICVAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:00:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches enable i.MX6SX multi queue support.
i.MX6SX support 3 queue and AVB feature. 

Frank Li (3):
  net:fec: add enet-avb IP support
  ARM: Documentation: Update fec dts binding doc
  ARM: dts: imx6sx: add multi-queue support enet

Fugang Duan (8):
  net:fec: add enet refrence clock for i.MX 6SX chip
  net:fec: add enet AVB feature macro define for imx6sx
  net:fec: use multiqueue interface to allocate Ethernet device
  net:fec: add multiqueue support
  net:fec: Disable enet-avb MAC instead of reset MAC
  net:fec: Add fsl,imx6sx-fec  compatible strings
  net:fec: change FEC alignment to 64 bytes for ARM platform
  net:fec: remove unnessary memory copy for address alignment in .xmit()

 Documentation/devicetree/bindings/net/fsl-fec.txt |   6 +
 arch/arm/boot/dts/imx6sx.dtsi                     |   2 +
 drivers/net/ethernet/freescale/fec.h              | 151 +++-
 drivers/net/ethernet/freescale/fec_main.c         | 877 +++++++++++++++-------
 4 files changed, 750 insertions(+), 286 deletions(-)

-- 
1.9.1
