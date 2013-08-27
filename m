From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH v3 0/2] net/cadence/macb: add support for dt phy definition
Date: Tue, 27 Aug 2013 09:36:47 +0200
Message-ID: <1377589007-3684-1-git-send-email-b.brezillon@overkiz.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch series adds support for ethernet phy definition using device
tree.

This may help in moving some at91 boards to dt (some of them define an
interrupt pin).

Tested on samad31ek.

Best Regards,
Boris

Changes since v2:
 - fix wrong address of phy0 dt node

Changes since v1:
 - fix wrong macb_mii_init return code when no PHY device is discovered

Boris BREZILLON (2):
  net/cadence/macb: add support for dt phy definition
  ARM: at91/dt: define phy available on sama5d3 mother board

 arch/arm/boot/dts/sama5d3xmb.dtsi   |    8 ++++++
 drivers/net/ethernet/cadence/macb.c |   48 +++++++++++++++++++++++++++--------
 2 files changed, 46 insertions(+), 10 deletions(-)

-- 
1.7.9.5
