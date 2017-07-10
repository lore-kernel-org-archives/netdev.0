From: Biju Das <biju.das@bp.renesas.com>
Subject: [PATCH v2] dt-bindings: net: ravb : Add support for r8a7743 SoC
Date: Mon, 10 Jul 2017 16:32:56 +0100
Message-ID: <1499700776-54504-1-git-send-email-biju.das@bp.renesas.com>
References: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Cc: "David S. Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        Biju Das <biju.das@bp.renesas.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new compatible string for the RZ/G1M (R8A7743) SoC.

Signed-off-by: Biju Das <biju.das@bp.renesas.com>
---
v1->v2
* Changed the subject
* re-formatted the required properties

 .../devicetree/bindings/net/renesas,ravb.txt       | 29 +++++++++++++---------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index b519503..4717bc2 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -4,19 +4,24 @@ This file provides information on what the device node for the Ethernet AVB
 interface contains.
 
 Required properties:
-- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
-	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
-	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
-	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
-	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
-	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
-	      "renesas,etheravb-r8a7796" if the device is a part of R8A7796 SoC.
-	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible interface.
-	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible interface.
+- compatible: Must contain one or more of the following:
+      - "renesas,etheravb-r8a7743" for the R8A7743 SoC.
+      - "renesas,etheravb-r8a7790" for the R8A7790 SoC.
+      - "renesas,etheravb-r8a7791" for the R8A7791 SoC.
+      - "renesas,etheravb-r8a7792" for the R8A7792 SoC.
+      - "renesas,etheravb-r8a7793" for the R8A7793 SoC.
+      - "renesas,etheravb-r8a7794" for the R8A7794 SoC.
+      - "renesas,etheravb-rcar-gen2" as a fallback for the above
+		R-Car Gen2 and RZ/G1 devices.
 
-	      When compatible with the generic version, nodes must list the
-	      SoC-specific version corresponding to the platform first
-	      followed by the generic version.
+      - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
+      - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
+      - "renesas,etheravb-rcar-gen3" as a fallback for the above
+		R-Car Gen3 devices.
+
+	When compatible with the generic version, nodes must list the
+	SoC-specific version corresponding to the platform first followed by
+	the generic version.
 
 - reg: offset and length of (1) the register block and (2) the stream buffer.
 - interrupts: A list of interrupt-specifiers, one for each entry in
-- 
1.9.1
