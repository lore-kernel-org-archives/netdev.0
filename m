From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 3/3] devicetree: macb: Add optional property tsu-clk
Date: Fri, 11 Sep 2015 13:27:38 +0530
Message-ID: <1441958258-35441-4-git-send-email-harinik@xilinx.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add TSU clock frequency to be used for 1588 support in macb driver.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 Documentation/devicetree/bindings/net/macb.txt |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..f7c0ea8 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- tsu-clk: Time stamp unit clock frequency used.
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
-- 
1.7.9.5
