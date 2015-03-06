From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v2 0/3] net: macb: rework at91 specific handling
Date: Fri,  6 Mar 2015 11:23:59 +0100
Message-ID: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Boris Brezillon <boris.brezillon@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This removes the #if defined(ARCH_AT91) sections to prevent any problem
when enabling ARM multi-platform support.
The at91 specific logic is now activated when the "at91sam9260-macb"
compatible string is found. 

Best Regards,

Boris

Changes since v1:
- avoid changing existing behavior as Alexandre suggested

Boris Brezillon (3):
  net/macb: Update DT bindings documentation
  ARM: at91/dt: fix macb compatible strings
  net: macb: remove #if defined(CONFIG_ARCH_AT91) sections

 Documentation/devicetree/bindings/net/macb.txt |  5 +++-
 arch/arm/boot/dts/at91sam9260.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9263.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9g45.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9x5_macb0.dtsi        |  2 +-
 arch/arm/boot/dts/at91sam9x5_macb1.dtsi        |  2 +-
 arch/arm/boot/dts/sama5d3_emac.dtsi            |  2 +-
 drivers/net/ethernet/cadence/macb.c            | 32 ++++++++++++++------------
 drivers/net/ethernet/cadence/macb.h            |  2 ++
 9 files changed, 29 insertions(+), 22 deletions(-)

-- 
1.9.1
