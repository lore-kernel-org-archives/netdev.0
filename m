From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net 2/2] bindings: net: macb: add no-usrio optional property
Date: Mon,  7 Dec 2015 11:58:34 +0100
Message-ID: <1449485914-12883-3-git-send-email-narmstrong@baylibre.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the no-usrio optional property to disable usage of the USRIO
register on platforms not implementing it.
---
 Documentation/devicetree/bindings/net/macb.txt | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..a15ee54 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- no-usrio: Indicates the platform integration does not implement the USRIO register.
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
-- 
1.9.1
