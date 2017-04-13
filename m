From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH 2/4] net: macb: Add tsu_clk to device tree
Date: Thu, 13 Apr 2017 14:38:06 +0100
Message-ID: <1492090686-14778-1-git-send-email-rafalo@cadence.com>
References: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>,
 <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <devicetree@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
 <harinikatakamlinux@gmail.com>, <harini.katakam@xilinx.com>,
 <richardcochran@gmail.com>, <Andrei.Pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 Documentation/devicetree/bindings/net/macb.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 1506e94..27966ae 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -22,6 +22,7 @@ Required properties:
 	Required elements: 'pclk', 'hclk'
 	Optional elements: 'tx_clk'
 	Optional elements: 'rx_clk' applies to cdns,zynqmp-gem
+	Optional elements: 'tsu_clk'
 - clocks: Phandles to input clocks.
 
 Optional properties for PHY child node:
-- 
2.4.5
