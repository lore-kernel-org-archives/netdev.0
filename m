From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: [PATCH v3 0/2] ARM: at91: remove phy fixup for sama5d3xek boards
Date: Thu, 10 Jul 2014 21:59:52 +0200
Message-ID: <1405022394-8311-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch removes a board specific hook for sama5d3xek boards from the
sama5d3 generic DT board file.

This hook (which register a phy fixup configuring board specific delays
in the ksz9021 ethernet phy) is now replaced by the appropriate DT
properties definitions in the sama5d3xcm.dtsi file.

Best Regards,

Boris

Changes since v2:
 - define 2 phy nodes to handle Ronetix and Embest HW designs

Changes since v1:
 - fix txc-skew-ps and rxc-skew-ps delays
 - remove phy address info to handle Ronetix and Embest HW designs

Boris BREZILLON (2):
  ARM: at91/dt: describe rgmii ethernet phy connected to sama5d3xek
    boards
  ARM: at91: remove phy fixup for sama5d3xek boards

 arch/arm/boot/dts/sama5d3xcm.dtsi   | 30 ++++++++++++++++++++++++++++++
 arch/arm/mach-at91/board-dt-sama5.c | 22 ----------------------
 2 files changed, 30 insertions(+), 22 deletions(-)

-- 
1.8.3.2
