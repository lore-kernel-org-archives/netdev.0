From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH v4 0/5] ARM: davinci: da850: add ethernet driver DT support
Date: Thu, 15 Aug 2013 11:31:32 +0530
Message-ID: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>
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

Changes for v4:
1: Fixed review comments pointed out by Sekhar.
2: Dropped patch v3 6/6 (https://patchwork.kernel.org/patch/2768361/)
   Which depends on adding GPIO DT node, will address it once GPIO support is added.
3: Rebased the patches on [1]

[1] https://git.kernel.org/cgit/linux/kernel/git/nsekhar/linux-davinci.git/log/?h=v3.12/soc

Lad, Prabhakar (5):
  ARM: davinci: fix clock lookup for mdio device
  ARM: davinci: da850: add DT node for mdio device
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for mdio.
  ARM: davinci: da850: add DT node for eth0.
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.

 arch/arm/boot/dts/da850-evm.dts       |   11 +++++++++
 arch/arm/boot/dts/da850.dtsi          |   43 +++++++++++++++++++++++++++++++++
 arch/arm/mach-davinci/da830.c         |    1 +
 arch/arm/mach-davinci/da850.c         |    1 +
 arch/arm/mach-davinci/da8xx-dt.c      |    4 +++
 arch/arm/mach-davinci/devices-da8xx.c |    8 ++----
 arch/arm/mach-davinci/dm365.c         |    3 +--
 arch/arm/mach-davinci/dm644x.c        |    3 +--
 arch/arm/mach-davinci/dm646x.c        |    3 +--
 9 files changed, 65 insertions(+), 12 deletions(-)

-- 
1.7.9.5
