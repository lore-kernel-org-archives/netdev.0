From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH v2 1/3] net: macb: Document zynq gem dt binding
Date: Fri, 22 May 2015 09:22:09 -0500
Message-ID: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:56994 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757164AbbEVOWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 10:22:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 Documentation/devicetree/bindings/net/cdns-emac.txt |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cdns-emac.txt b/Documentation/devicetree/bindings/net/cdns-emac.txt
index abd67c1..4451ee9 100644
--- a/Documentation/devicetree/bindings/net/cdns-emac.txt
+++ b/Documentation/devicetree/bindings/net/cdns-emac.txt
@@ -3,7 +3,8 @@
 Required properties:
 - compatible: Should be "cdns,[<chip>-]{emac}"
   Use "cdns,at91rm9200-emac" Atmel at91rm9200 SoC.
-  or the generic form: "cdns,emac".
+  Use "cdns,zynq-gem" Xilinx Zynq-7xxx SoC.
+  Or the generic form: "cdns,emac".
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
 - phy-mode: see ethernet.txt file in the same directory.
-- 
1.7.10.4
