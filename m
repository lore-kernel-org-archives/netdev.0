From: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Subject: [PATCH net-next repost v2] dt-bindings: net: ravb : Add support for r8a7743 SoC
Date: Mon, 17 Jul 2017 09:33:52 +0100
Message-ID: <1500280432-43162-1-git-send-email-biju.das@bp.renesas.com>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new compatible string for the RZ/G1M (R8A7743) SoC.

Signed-off-by: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Reviewed-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Reviewed-by: Simon Horman <horms+renesas-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
