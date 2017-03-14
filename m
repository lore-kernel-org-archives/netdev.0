From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 11/12] dt-bindings: net: update bcmgenet binding for GENETv5
Date: Mon, 13 Mar 2017 17:41:41 -0700
Message-ID: <20170314004142.4746-12-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34399 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbdCNAm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 20:42:28 -0400
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device tree documentation must be updated to reflect the new compatible
strings "brcm,genet-v5" and "brcm,genet-mdio-v5" used by the GENETv5 driver.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 Documentation/devicetree/bindings/net/brcm,bcmgenet.txt    | 10 +++++-----
 Documentation/devicetree/bindings/net/brcm,unimac-mdio.txt |  5 +++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
index 01a70463cbc5..26c77d985faf 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
@@ -2,7 +2,7 @@
 
 Required properties:
 - compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
-  "brcm,genet-v3", "brcm,genet-v4".
+  "brcm,genet-v3", "brcm,genet-v4", "brcm,genet-v5".
 - reg: address and length of the register set for the device
 - interrupts and/or interrupts-extended: must be two cells, the first cell
   is the general purpose interrupt line, while the second cell is the
@@ -32,15 +32,15 @@ Optional properties:
 
 Required child nodes:
 
-- mdio bus node: this node should always be present regarless of the PHY
+- mdio bus node: this node should always be present regardless of the PHY
   configuration of the GENET instance
 
 MDIO bus node required properties:
 
 - compatible: should contain one of "brcm,genet-mdio-v1", "brcm,genet-mdio-v2"
-  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", the version has to match the
-  parent node compatible property (e.g: brcm,genet-v4 pairs with
-  brcm,genet-mdio-v4)
+  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", "brcm,genet-mdio-v5", the version
+  has to match the parent node compatible property (e.g: brcm,genet-v4 pairs
+  with brcm,genet-mdio-v4)
 - reg: address and length relative to the parent node base register address
 - #address-cells: address cell for MDIO bus addressing, should be 1
 - #size-cells: size of the cells for MDIO bus addressing, should be 0
diff --git a/Documentation/devicetree/bindings/net/brcm,unimac-mdio.txt b/Documentation/devicetree/bindings/net/brcm,unimac-mdio.txt
index ab0bb4247d14..4648948f7c3b 100644
--- a/Documentation/devicetree/bindings/net/brcm,unimac-mdio.txt
+++ b/Documentation/devicetree/bindings/net/brcm,unimac-mdio.txt
@@ -2,8 +2,9 @@
 
 Required properties:
 - compatible: should one from "brcm,genet-mdio-v1", "brcm,genet-mdio-v2",
-  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4" or "brcm,unimac-mdio"
-- reg: address and length of the regsiter set for the device, first one is the
+  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", "brcm,genet-mdio-v5" or
+  "brcm,unimac-mdio"
+- reg: address and length of the register set for the device, first one is the
   base register, and the second one is optional and for indirect accesses to
   larger than 16-bits MDIO transactions
 - reg-names: name(s) of the register must be "mdio" and optional "mdio_indir_rw"
-- 
2.11.1
