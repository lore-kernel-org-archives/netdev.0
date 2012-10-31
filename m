From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 0/4] Support the MX6 FEC as a PTP hardware clock
Date: Wed, 31 Oct 2012 12:24:40 +0800
Message-ID: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznua@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:27075
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750884Ab2JaFH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 01:07:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables hardware time stamping and a PTP hardware clock
for mx6 ENET controller.

Frank Li (4):
  net: fec: move fec_enet_private to header file
  ARM: dts: imx6q: Add ENET PTP clock pin and clock source
  ARM: imx6q: Set enet tx reference clk from anatop to support 1588
  FEC: Add time stamping code and a PTP hardware clock

 arch/arm/boot/dts/imx6q.dtsi             |    5 +-
 arch/arm/mach-imx/mach-imx6q.c           |   12 +
 drivers/net/ethernet/freescale/Kconfig   |    9 +
 drivers/net/ethernet/freescale/Makefile  |    1 +
 drivers/net/ethernet/freescale/fec.c     |  161 +++++++------
 drivers/net/ethernet/freescale/fec.h     |  119 +++++++++
 drivers/net/ethernet/freescale/fec_ptp.c |  386 ++++++++++++++++++++++++++++++
 7 files changed, 617 insertions(+), 76 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/fec_ptp.c
