From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 1/4] net/macb: bindings doc: fix compatibility string
Date: Thu, 18 Jun 2015 16:27:20 +0200
Message-ID: <d34d38d251e57ed176ad526452681f4b9bdf4778.1434637286.git.nicolas.ferre@atmel.com>
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

In the driver and the DT bindings we use the "atmel" prefix. Fix it in the
binding documentation.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 Documentation/devicetree/bindings/net/macb.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 8ec5fdf444e9..0ae6974383d7 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -7,8 +7,8 @@ Required properties:
   Use "cdns,at32ap7000-macb" for other 10/100 usage or use the generic form: "cdns,macb".
   Use "cdns,pc302-gem" for Picochip picoXcell pc302 and later devices based on
   the Cadence GEM, or the generic form: "cdns,gem".
-  Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
-  Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
+  Use "atmel,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
+  Use "atmel,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
   Use "cdns,zynqmp-gem" for Zynq Ultrascale+ MPSoC.
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
-- 
2.1.3
