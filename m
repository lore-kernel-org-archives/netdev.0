From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH can-next v2 2/2] CAN: rcar: add device tree support for r8a779[234]
Date: Wed, 24 Feb 2016 10:56:33 +0900
Message-ID: <1456278993-9899-3-git-send-email-horms+renesas@verge.net.au>
References: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply document new compatibility string.
As a previous patch adds a generic R-Car Gen2 compatibility string
there appears to be no need for a driver updates.

By documenting these compat stings they may be used in DTSs shipped, for
example as part of ROMs. They must be used in conjunction with the Gen2
fallback compat string. At this time there are no known differences between
the r8a779[234] IP blocks and that implemented by the driver for the Gen2
fallback compat string. Thus there is no need to update the driver as the
use of the Gen2 fallback compat string will activate the correct code in
the current driver while leaving the option for r8a779[234]-specific driver
code to be activated in an updated driver should the need arise.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
* Do not update driver as per changelog
* Minor edit of changelog
---
 Documentation/devicetree/bindings/net/can/rcar_can.txt | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
index f2172fb42cd8..65edc055722f 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -6,6 +6,9 @@ Required properties:
 	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
 	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
 	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
+	      "renesas,can-r8a7792" if CAN controller is a part of R8A7792 SoC.
+	      "renesas,can-r8a7793" if CAN controller is a part of R8A7793 SoC.
+	      "renesas,can-r8a7794" if CAN controller is a part of R8A7794 SoC.
 	      "renesas,rcar-gen1-can" for a generic R-Car Gen1 compatible device.
 	      "renesas,rcar-gen2-can" for a generic R-Car Gen2 compatible device.
 	      When compatible with the generic version, nodes must list the
-- 
2.1.4
