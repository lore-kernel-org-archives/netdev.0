From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 1/4] dt: bindings: Typo s/clocks-names/clock-names/g
Date: Tue, 22 Apr 2014 20:40:22 +0200
Message-ID: <1398192025-31523-1-git-send-email-geert+renesas@glider.be>
Cc: linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Dinh Nguyen <dinguyen@altera.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Dinh Nguyen <dinguyen@altera.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: netdev@vger.kernel.org
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |    2 +-
 Documentation/devicetree/bindings/net/stmmac.txt   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index 636f0ac4e223..2a60cd3e8d5d 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -23,5 +23,5 @@ gmac0: ethernet@ff700000 {
 	interrupt-names = "macirq";
 	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 	clocks = <&emac_0_clk>;
-	clocks-names = "stmmaceth";
+	clock-names = "stmmaceth";
 };
diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 80c1fb8bfbb8..a2acd2b26baf 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -33,7 +33,7 @@ Optional properties:
 - max-frame-size: See ethernet.txt file in the same directory
 - clocks: If present, the first clock should be the GMAC main clock,
   further clocks may be specified in derived bindings.
-- clocks-names: One name for each entry in the clocks property, the
+- clock-names: One name for each entry in the clocks property, the
   first one should be "stmmaceth".
 
 Examples:
-- 
1.7.9.5
