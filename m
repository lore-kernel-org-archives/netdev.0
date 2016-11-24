From: Chris Paterson <chris.paterson2@renesas.com>
Subject: [PATCH v2 2/2] can: rcar_canfd: Add r8a7796 support
Date: Thu, 24 Nov 2016 16:11:57 +0000
Message-ID: <1480003917-3953-3-git-send-email-chris.paterson2@renesas.com>
References: <1479903243-1860-1-git-send-email-chris.paterson2@renesas.com>
 <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Simon Horman <horms@verge.net.au>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Chris Paterson <chris.paterson2@renesas.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Paterson <chris.paterson2@renesas.com>
Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
index 22a6f10..788f273 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
@@ -5,6 +5,7 @@ Required properties:
 - compatible: Must contain one or more of the following:
   - "renesas,rcar-gen3-canfd" for R-Car Gen3 compatible controller.
   - "renesas,r8a7795-canfd" for R8A7795 (R-Car H3) compatible controller.
+  - "renesas,r8a7796-canfd" for R8A7796 (R-Car M3) compatible controller.
 
   When compatible with the generic version, nodes must list the
   SoC-specific version corresponding to the platform first, followed by the
@@ -23,11 +24,12 @@ The name of the child nodes are "channel0" and "channel1" respectively. Each
 child node supports the "status" property only, which is used to
 enable/disable the respective channel.
 
-Required properties for "renesas,r8a7795-canfd" compatible:
-In R8A7795 SoC, canfd clock is a div6 clock and can be used by both CAN
-and CAN FD controller at the same time. It needs to be scaled to maximum
-frequency if any of these controllers use it. This is done using the
-below properties.
+Required properties for "renesas,r8a7795-canfd" and "renesas,r8a7796-canfd"
+compatible:
+In R8A7795 and R8A7796 SoCs, canfd clock is a div6 clock and can be used by both
+CAN and CAN FD controller at the same time. It needs to be scaled to maximum
+frequency if any of these controllers use it. This is done using the below
+properties:
 
 - assigned-clocks: phandle of canfd clock.
 - assigned-clock-rates: maximum frequency of this clock.
-- 
1.9.1
