From: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Subject: [PATCH v3] net: dsa: b53: Add compatible strings for the Cygnus-family BCM11360.
Date: Wed, 17 May 2017 17:32:12 -0700
Message-ID: <20170518003212.4028-1-eric@anholt.net>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cygnus is a small family of SoCs, of which we currently have
devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
same as 58xx, just requiring a tiny bit of setup that was previously
missing.

Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---

v2: Reorder the entry in the docs (suggestion by Scott Branden), add
    missing '"'
v3: Resend now that 4.12-rc1 is out.

 Documentation/devicetree/bindings/net/dsa/b53.txt | 3 +++
 drivers/net/dsa/b53/b53_srab.c                    | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
index d6c6e41648d4..eb679e92d525 100644
--- a/Documentation/devicetree/bindings/net/dsa/b53.txt
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -13,6 +13,9 @@ Required properties:
       "brcm,bcm5397"
       "brcm,bcm5398"
 
+  For the BCM11360 SoC, must be:
+      "brcm,bcm11360-srab" and the mandatory "brcm,cygnus-srab" string
+
   For the BCM5310x SoCs with an integrated switch, must be one of:
       "brcm,bcm53010-srab"
       "brcm,bcm53011-srab"
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 8a62b6a69703..c37ffd1b6833 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -364,6 +364,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm53018-srab" },
 	{ .compatible = "brcm,bcm53019-srab" },
 	{ .compatible = "brcm,bcm5301x-srab" },
+	{ .compatible = "brcm,bcm11360-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58522-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58525-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58535-srab", .data = (void *)BCM58XX_DEVICE_ID },
@@ -371,6 +372,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm58623-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58625-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm88312-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,cygnus-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,nsp-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ /* sentinel */ },
 };
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
