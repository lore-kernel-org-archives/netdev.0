From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] ravb: document R8A77970 bindings
Date: Tue, 12 Sep 2017 23:02:08 +0300
Message-ID: <20170912200228.015376134@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=ravb-document-R8A77970-bindings.patch
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

R-Car V3M (R8A77970) SoC also has the R-Car gen3 compatible EtherAVB
device, so document  the SoC specific bindings.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
The patch is against DaveM's 'net-next.git' repo but I wouldn't mind if it's
applied to 'net.git' instead. :-)

 Documentation/devicetree/bindings/net/renesas,ravb.txt |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -17,6 +17,7 @@ Required properties:
 
       - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
       - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
+      - "renesas,etheravb-r8a77970" for the R8A77970 SoC.
       - "renesas,etheravb-rcar-gen3" as a fallback for the above
 		R-Car Gen3 devices.
 
@@ -40,7 +41,7 @@ Optional properties:
 - interrupt-parent: the phandle for the interrupt controller that services
 		    interrupts for this device.
 - interrupt-names: A list of interrupt names.
-		   For the R8A779[56] SoCs this property is mandatory;
+		   For the R-Car Gen 3 SoCs this property is mandatory;
 		   it should include one entry per channel, named "ch%u",
 		   where %u is the channel number ranging from 0 to 24.
 		   For other SoCs this property is optional; if present

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
