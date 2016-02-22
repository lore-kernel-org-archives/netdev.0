From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH can-next 0/2] CAN: rcar: add fallback and r8a779[234] bindings
Date: Mon, 22 Feb 2016 11:15:48 +0900
Message-ID: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this series adds fallback bindings for R-Car Gen 1 and Gen 2 SoCs,
and SoC-specific bindings for the r8a779[234] SoCs which are
of the R-Car Gen 2 SoCs.

The aim is to provide consistent bindings for R-Car Gen 1 and Gen 2
SoCs in a maner consistent with that progressively being used
for drivers for other IP blocks used by Renesas SoCs.

Simon Horman (2):
  CAN: rcar: add gen[12] fallback compatibility strings
  CAN: rcar: add device tree support for r8a779[234]

 Documentation/devicetree/bindings/net/can/rcar_can.txt | 7 ++++++-
 drivers/net/can/rcar_can.c                             | 5 +++++
 2 files changed, 11 insertions(+), 1 deletion(-)

-- 
2.1.4
