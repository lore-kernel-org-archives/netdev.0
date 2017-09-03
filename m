From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] dt-binding: phy: don't confuse with Ethernet phy properties
Date: Sun,  3 Sep 2017 17:32:16 +0300
Message-ID: <0a90f4b3cc903af6f82002e502deba67f374c602.1504449136.git.baruch@tkos.co.il>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Baruch Siach <baruch@tkos.co.il>
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The generic PHY 'phys' property sometime appears in the same node with
the Ethernet PHY 'phy' or 'phy-handle' properties. Add a warning in
phy-bindings.txt to reduce confusion.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 Documentation/devicetree/bindings/phy/phy-bindings.txt | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/phy/phy-bindings.txt b/Documentation/devicetree/bindings/phy/phy-bindings.txt
index 1293c321754c..a403b81d0679 100644
--- a/Documentation/devicetree/bindings/phy/phy-bindings.txt
+++ b/Documentation/devicetree/bindings/phy/phy-bindings.txt
@@ -34,7 +34,9 @@ PHY user node
 =============
 
 Required Properties:
-phys : the phandle for the PHY device (used by the PHY subsystem)
+phys : the phandle for the PHY device (used by the PHY subsystem; not to be
+       confused with the Ethernet specific 'phy' and 'phy-handle' properties,
+       see Documentation/devicetree/bindings/net/ethernet.txt for these)
 phy-names : the names of the PHY corresponding to the PHYs present in the
 	    *phys* phandle
 
-- 
2.14.1
