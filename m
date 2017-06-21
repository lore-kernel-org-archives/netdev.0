From: Tom Rini <trini-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Subject: [PATCH] dt-bindings: gpmc: Correct location of generic gpmc binding
Date: Wed, 21 Jun 2017 08:14:54 -0400
Message-ID: <1498047294-31075-1-git-send-email-trini@konsulko.com>
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>,
        Cyrille Pitchen <cyrille.pitchen-yU5RGvR974pGWvitb5QawA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The binding bus/ti-gpmc.txt has been moved to
memory-controllers/omap-gpmc.txt.  Update all references to this in
order to make reading and understanding a given binding easier.

Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc:Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: Cyrille Pitchen <cyrille.pitchen-yU5RGvR974pGWvitb5QawA@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Signed-off-by: Tom Rini <trini-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
---
 Documentation/devicetree/bindings/mtd/gpmc-nand.txt    | 2 +-
 Documentation/devicetree/bindings/mtd/gpmc-nor.txt     | 4 ++--
 Documentation/devicetree/bindings/mtd/gpmc-onenand.txt | 2 +-
 Documentation/devicetree/bindings/net/gpmc-eth.txt     | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/mtd/gpmc-nand.txt b/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
index 174f68c26c1b..dd559045593d 100644
--- a/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
+++ b/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
@@ -5,7 +5,7 @@ the GPMC controller with a name of "nand".
 
 All timing relevant properties as well as generic gpmc child properties are
 explained in a separate documents - please refer to
-Documentation/devicetree/bindings/bus/ti-gpmc.txt
+Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 For NAND specific properties such as ECC modes or bus width, please refer to
 Documentation/devicetree/bindings/mtd/nand.txt
diff --git a/Documentation/devicetree/bindings/mtd/gpmc-nor.txt b/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
index 4828c17bb784..131d3a74d0bd 100644
--- a/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
+++ b/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
@@ -5,7 +5,7 @@ child nodes of the GPMC controller with a name of "nor".
 
 All timing relevant properties as well as generic GPMC child properties are
 explained in a separate documents. Please refer to
-Documentation/devicetree/bindings/bus/ti-gpmc.txt
+Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 Required properties:
 - bank-width: 		Width of NOR flash in bytes. GPMC supports 8-bit and
@@ -28,7 +28,7 @@ Required properties:
 
 Optional properties:
 - gpmc,XXX		Additional GPMC timings and settings parameters. See
-			Documentation/devicetree/bindings/bus/ti-gpmc.txt
+			Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 Optional properties for partition table parsing:
 - #address-cells: should be set to 1
diff --git a/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt b/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
index 5d8fa527c496..b6e8bfd024f4 100644
--- a/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
+++ b/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
@@ -5,7 +5,7 @@ the GPMC controller with a name of "onenand".
 
 All timing relevant properties as well as generic gpmc child properties are
 explained in a separate documents - please refer to
-Documentation/devicetree/bindings/bus/ti-gpmc.txt
+Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 Required properties:
 
diff --git a/Documentation/devicetree/bindings/net/gpmc-eth.txt b/Documentation/devicetree/bindings/net/gpmc-eth.txt
index ace4a64b3695..f7da3d73ca1b 100644
--- a/Documentation/devicetree/bindings/net/gpmc-eth.txt
+++ b/Documentation/devicetree/bindings/net/gpmc-eth.txt
@@ -9,7 +9,7 @@ the GPMC controller with an "ethernet" name.
 
 All timing relevant properties as well as generic GPMC child properties are
 explained in a separate documents. Please refer to
-Documentation/devicetree/bindings/bus/ti-gpmc.txt
+Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 For the properties relevant to the ethernet controller connected to the GPMC
 refer to the binding documentation of the device. For example, the documentation
@@ -43,7 +43,7 @@ Required properties:
 
 Optional properties:
 - gpmc,XXX		Additional GPMC timings and settings parameters. See
-			Documentation/devicetree/bindings/bus/ti-gpmc.txt
+			Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
 
 Example:
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
