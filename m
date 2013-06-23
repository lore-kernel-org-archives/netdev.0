From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v3 0/6] ARM: davinci: da850: add ethernet driver DT support
Date: Sun, 23 Jun 2013 20:30:01 +0530
Message-ID: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	devicetree-discuss@lists.ozlabs.org, Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

This patch set enables Ethernet support through device tree model.
This patch set enables mii interface only and is being tested to boot via
rootfs. The rmii phy is present on the i2c gpio expander chip (UI board)
for which yet support needs to be added, once the DT support for the chip
is enabled, enabling rmii will be subsequnet patch.

Changes for v2:
1: Enabled mdio device.
2: Fixed clock lookup.

Changes for v3:
1: Fixed review comments pointed out by Sekhar.

Lad, Prabhakar (6):
  ARM: davinci: da8xx: fix clock lookup for mdio device
  ARM: davinci: da850: add DT node for mdio device
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for mdio.
  ARM: davinci: da850: add DT node for eth0.
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.
  ARM: davinci: da850: configure system configuration chip(CFGCHIP3)
    for emac

 arch/arm/boot/dts/da850-evm.dts            |   11 +++++++
 arch/arm/boot/dts/da850.dtsi               |   43 ++++++++++++++++++++++++++
 arch/arm/mach-davinci/board-da850-evm.c    |   36 ++--------------------
 arch/arm/mach-davinci/da830.c              |    1 +
 arch/arm/mach-davinci/da850.c              |   46 ++++++++++++++++++++++++++++
 arch/arm/mach-davinci/da8xx-dt.c           |   20 ++++++++++++
 arch/arm/mach-davinci/devices-da8xx.c      |    8 ++---
 arch/arm/mach-davinci/include/mach/da8xx.h |    1 +
 8 files changed, 126 insertions(+), 40 deletions(-)

-- 
1.7.9.5
