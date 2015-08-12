From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/3] Add AM335x PG1.0 CPSW errata workaround
Date: Wed, 12 Aug 2015 15:22:52 +0530
Message-ID: <1439373175-8650-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <alex.aring@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:48810 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbbHLJxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 05:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 870915feabdc ("drivers: net: cpsw: remove
disable_irq/enable_irq as irq can be masked from cpsw itself"),
CPSW on AM335x beagle bone white is broken as there is a errata
for AM335x PG1.0. This patch series implements the workaround by
disabling the interrupts from ARM IRQ controller for AM335x SoC
in addition to the masking of interrupts in CPSW.

Mugunthan V N (3):
  drivers: net: cpsw: add am335x errata workarround for interrutps
  ARM: dts: dra7: update cpsw compatible
  ARM: dts: am33xx: update cpsw compatible

 arch/arm/boot/dts/am33xx.dtsi  |  2 +-
 arch/arm/boot/dts/dra7.dtsi    |  2 +-
 drivers/net/ethernet/ti/cpsw.c | 83 +++++++++++++++++++++++++++++++++++++++---
 3 files changed, 79 insertions(+), 8 deletions(-)

-- 
2.5.0.234.gefc8a62
