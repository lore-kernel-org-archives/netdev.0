From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] dsa: fix device tree binding documentation typo on #address-cells
Date: Mon, 25 Mar 2013 16:03:38 +0100
Message-ID: <1364223820-26051-2-git-send-email-florian@openwrt.org>
References: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43613 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756682Ab3CYPDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 11:03:52 -0400
In-Reply-To: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device tree binding documentation for dsa explicitely states that a
DSA node should have its #address-cells property set to 2, yet the
example still used 1, fix that typo.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index db92f55..49f4f7a 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -43,7 +43,7 @@ Example:
 
 	dsa@0 {
 		compatible = "marvell,dsa";
-		#address-cells = <1>;
+		#address-cells = <2>;
 		#size-cells = <0>;
 
 		interrupts = <10>;
-- 
1.7.10.4
