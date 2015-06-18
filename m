From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 2/4] net/macb: bindings doc/trivial: fix sama5d4 comment
Date: Thu, 18 Jun 2015 16:27:21 +0200
Message-ID: <dcce40eef71cfbedfca905fb1918e41930a4067c.1434637286.git.nicolas.ferre@atmel.com>
References: <cover.1434637286.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1434637286.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On sama5d4, we only have a GEM IP that is configured to do 10/100 Mbits. So the
use of "Gigabit" can be confusing.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 Documentation/devicetree/bindings/net/macb.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 0ae6974383d7..97349e3f3ff2 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -8,7 +8,7 @@ Required properties:
   Use "cdns,pc302-gem" for Picochip picoXcell pc302 and later devices based on
   the Cadence GEM, or the generic form: "cdns,gem".
   Use "atmel,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
-  Use "atmel,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
+  Use "atmel,sama5d4-gem" for the GEM IP (10/100) available on Atmel sama5d4 SoCs.
   Use "cdns,zynqmp-gem" for Zynq Ultrascale+ MPSoC.
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
-- 
2.1.3
