From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH v5 0/2] ARM: davinci: da850: add ethernet driver DT support
Date: Fri, 16 Aug 2013 19:41:00 +0530
Message-ID: <1376662262-21795-1-git-send-email-prabhakar.csengg@gmail.com>
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
rootfs. 

Patches 1-2 of v4 are queued for v3-12, just resending patch
4-5 by fixing review comments pointed by Sergei

Lad, Prabhakar (2):
  ARM: davinci: da850: add DT node for ethernet
  ARM: davinci: da850: add OF_DEV_AUXDATA entry for davinci_emac

 arch/arm/boot/dts/da850-evm.dts  |    5 +++++
 arch/arm/boot/dts/da850.dtsi     |   30 ++++++++++++++++++++++++++++++
 arch/arm/mach-davinci/da8xx-dt.c |    2 ++
 3 files changed, 37 insertions(+)

-- 
1.7.9.5
