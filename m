From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: [PATCH 0/2] Add CAN support to r8a7795 SoC
Date: Mon, 29 Feb 2016 09:20:59 +0000
Message-ID: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, chris.paterson2@renesas.com,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
To: mkl@pengutronix.de, wg@grandegger.com, horms@verge.net.au,
	magnus.damm@gmail.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds CAN support to r8a7795 SoC.

This is based on linux-next (tag: next-20160225).

Pinctrl & Clock related to the controller are already submitted as below:

https://lkml.org/lkml/2016/2/25/546
https://lkml.org/lkml/2016/2/26/452
http://www.spinics.net/lists/arm-kernel/msg487238.html

The compatibility string used follows the same format as in this patch:
http://www.spinics.net/lists/netdev/msg365756.html

Ramesh Shanmugasundaram (2):
  can: rcar_can: Add r8a7795 support
  arm64: dts: r8a7795: Add CAN support

 .../devicetree/bindings/net/can/rcar_can.txt       | 12 +++++++++
 arch/arm64/boot/dts/renesas/r8a7795.dtsi           | 30 ++++++++++++++++++++++
 drivers/net/can/Kconfig                            |  2 +-
 drivers/net/can/rcar_can.c                         |  7 ++++-
 4 files changed, 49 insertions(+), 2 deletions(-)

-- 
1.9.1
