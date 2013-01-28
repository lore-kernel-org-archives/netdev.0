From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 0/6] ARM: davinci: da850: add ethernet driver DT support
Date: Mon, 28 Jan 2013 19:17:53 +0530
Message-ID: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62306 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab3A1NsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 08:48:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lad, Prabhakar <prabhakar.lad@ti.com>

This patch set enables Ethernet support through device tree model.
This patch set enables mii interface only and is being tested to boot via
rootfs. The rmii phy is present on the i2c gpio expander chip (UI board)
for which yet support needs to be added, once the DT support for the chip
is enabled, enabling rmii will be subsequnet patch.

Changes for v2:
1: Enabled mdio device.
2: Fixed clock lookup.

Lad, Prabhakar (6):
  ARM: davinci: da850: fix clock lookup for mdio device
  ARM: davinci: da850: add DT node for mdio device
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for mdio.
  ARM: davinci: da850: add DT node for eth0.
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.
  ARM: davinci: da850: configure system configuration chip(CFGCHIP3)
    for emac

 arch/arm/boot/dts/da850-evm.dts       |    8 ++++++
 arch/arm/boot/dts/da850.dtsi          |   42 +++++++++++++++++++++++++++++++++
 arch/arm/mach-davinci/da850.c         |    1 +
 arch/arm/mach-davinci/da8xx-dt.c      |   38 +++++++++++++++++++++++++++++-
 arch/arm/mach-davinci/devices-da8xx.c |    8 +----
 5 files changed, 90 insertions(+), 7 deletions(-)

-- 
1.7.4.1
