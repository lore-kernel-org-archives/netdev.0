From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
Date: Wed, 23 Nov 2016 14:44:46 +0100
Message-ID: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        Chris Paterson <chris.paterson2@renesas.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to both DTS (example and actual files), and Linux driver code,
the first interrupt specifier should be the Channel interrupt, while the
second interrupt specifier should be the Global interrupt.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
index 22a6f10bab057f46..58c27cd839e3a2ac 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
@@ -11,7 +11,7 @@ Required properties:
   family-specific and/or generic versions.
 
 - reg: physical base address and size of the R-Car CAN FD register map.
-- interrupts: interrupt specifier for the Global & Channel interrupts
+- interrupts: interrupt specifiers for the Channel & Global interrupts
 - clocks: phandles and clock specifiers for 3 clock inputs.
 - clock-names: 3 clock input name strings: "fck", "canfd", "can_clk".
 - pinctrl-0: pin control group to be used for this controller.
-- 
1.9.1

