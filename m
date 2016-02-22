From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH can-next 2/2] CAN: rcar: add device tree support for r8a779[234]
Date: Mon, 22 Feb 2016 11:15:50 +0900
Message-ID: <1456107350-12100-3-git-send-email-horms+renesas@verge.net.au>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply document new compatibility string.
As a previous patch adds a generic R-Car Gen2 compatibility string
there appears to be no need for a driver updates.

By documenting this compat sting it may be used in DTSs shipped, for
example as part of ROMs. It must be used in conjunction with the Gen2
fallback compat string. At this time there are no known differences between
the r8a779[234] IP blocks and that implemented by the driver for the Gen2
fallback compat string. Thus there is no need to update the driver as the
use of the Gen2 fallback compat string will activate the correct code in
the current driver while leaving the option for r8a779[234]-specific driver
code to be activated in an updated driver should the need arise.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 Documentation/devicetree/bindings/net/can/rcar_can.txt | 3 +++
 drivers/net/can/rcar_can.c                             | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
index 036786e1f70d..c6fb74d7c809 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -6,6 +6,9 @@ Required properties:
 	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
 	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
 	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
+	      "renesas,can-r8a7792" if CAN controller is a part of R8A7792 SoC.
+	      "renesas,can-r8a7793" if CAN controller is a part of R8A7793 SoC.
+	      "renesas,can-r8a7794" if CAN controller is a part of R8A7794 SoC.
 	      "renesas,can-gen1" for a generic R-Car Gen1 compatible device.
 	      "renesas,can-gen2" for a generic R-Car Gen2 compatible device.
 - reg: physical base address and size of the R-Car CAN register map.
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index c70a1f795933..73761a4dd1bf 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -904,6 +904,9 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
 	{ .compatible = "renesas,can-r8a7779" },
 	{ .compatible = "renesas,can-r8a7790" },
 	{ .compatible = "renesas,can-r8a7791" },
+	{ .compatible = "renesas,can-r8a7792" },
+	{ .compatible = "renesas,can-r8a7793" },
+	{ .compatible = "renesas,can-r8a7794" },
 	{ .compatible = "renesas,can-gen1" },
 	{ .compatible = "renesas,can-gen2" },
 	{ }
-- 
2.1.4

