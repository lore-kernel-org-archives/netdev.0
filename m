From: Nishanth Menon <nm@ti.com>
Subject: [PATCH 2/2] ARM: dts: omap2430-sdp: add flags for ethernet
 functionality
Date: Wed, 11 Dec 2013 04:21:45 -0600
Message-ID: <1386757305-12545-3-git-send-email-nm@ti.com>
References: <1386757305-12545-1-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nishanth Menon <nm@ti.com>, linux-doc@vger.kernel.org,
 Tony Lindgren <tony@atomide.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson@baylibre.com>,
 linux-arm-kernel@lists.infradead.org
To: <devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
 <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1386757305-12545-1-git-send-email-nm@ti.com>
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

Ethernet transition from board file to dts missed the required pdata
conversion. So fix the same.

Signed-off-by: Nishanth Menon <nm@ti.com>
---
 arch/arm/boot/dts/omap2430-sdp.dts |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/omap2430-sdp.dts b/arch/arm/boot/dts/omap2430-sdp.dts
index 2c90d29..ec9263a 100644
--- a/arch/arm/boot/dts/omap2430-sdp.dts
+++ b/arch/arm/boot/dts/omap2430-sdp.dts
@@ -39,6 +39,11 @@
 	ranges = <5 0 0x08000000 0x01000000>;
 	ethernet@gpmc {
 		compatible = "smsc,lan91c94";
+		reg-io-width = <2>;
+		smsc,nowait;
+		smsc,leda = "100_10";
+		smsc,ledb = "TX_RX";
+
 		interrupt-parent = <&gpio5>;
 		interrupts = <21 IRQ_TYPE_LEVEL_LOW>;	/* gpio149 */
 		reg = <5 0x300 0xf>;
-- 
1.7.9.5
