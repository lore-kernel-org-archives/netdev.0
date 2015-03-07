From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v4 1/4] ARM: at91/dt: fix macb compatible strings
Date: Sat,  7 Mar 2015 07:23:29 +0100
Message-ID: <1425709412-4935-2-git-send-email-boris.brezillon@free-electrons.com>
References: <1425709412-4935-1-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Boris Brezillon <boris.brezillon@free-electrons.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, linux-kernel@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Kumar Gala <galak@codeaurora.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1425709412-4935-1-git-send-email-boris.brezillon@free-electrons.com>
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

Some at91 SoCs embed a 10/100 Mbit Ethernet IP, that is based on the
at91sam9260 SoC.
Fix at91 DTs accordingly.

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Reviewed-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 arch/arm/boot/dts/at91sam9260.dtsi      | 2 +-
 arch/arm/boot/dts/at91sam9263.dtsi      | 2 +-
 arch/arm/boot/dts/at91sam9g45.dtsi      | 2 +-
 arch/arm/boot/dts/at91sam9x5_macb0.dtsi | 2 +-
 arch/arm/boot/dts/at91sam9x5_macb1.dtsi | 2 +-
 arch/arm/boot/dts/sama5d3_emac.dtsi     | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm/boot/dts/at91sam9260.dtsi b/arch/arm/boot/dts/at91sam9260.dtsi
index fff0ee6..9f7c737 100644
--- a/arch/arm/boot/dts/at91sam9260.dtsi
+++ b/arch/arm/boot/dts/at91sam9260.dtsi
@@ -842,7 +842,7 @@
 			};
 
 			macb0: ethernet@fffc4000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xfffc4000 0x100>;
 				interrupts = <21 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
diff --git a/arch/arm/boot/dts/at91sam9263.dtsi b/arch/arm/boot/dts/at91sam9263.dtsi
index 1f67bb4..340179e 100644
--- a/arch/arm/boot/dts/at91sam9263.dtsi
+++ b/arch/arm/boot/dts/at91sam9263.dtsi
@@ -845,7 +845,7 @@
 			};
 
 			macb0: ethernet@fffbc000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xfffbc000 0x100>;
 				interrupts = <21 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
diff --git a/arch/arm/boot/dts/at91sam9g45.dtsi b/arch/arm/boot/dts/at91sam9g45.dtsi
index ee80aa9..586eab7 100644
--- a/arch/arm/boot/dts/at91sam9g45.dtsi
+++ b/arch/arm/boot/dts/at91sam9g45.dtsi
@@ -956,7 +956,7 @@
 			};
 
 			macb0: ethernet@fffbc000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xfffbc000 0x100>;
 				interrupts = <25 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
diff --git a/arch/arm/boot/dts/at91sam9x5_macb0.dtsi b/arch/arm/boot/dts/at91sam9x5_macb0.dtsi
index 57e89d1..73d7e30 100644
--- a/arch/arm/boot/dts/at91sam9x5_macb0.dtsi
+++ b/arch/arm/boot/dts/at91sam9x5_macb0.dtsi
@@ -53,7 +53,7 @@
 			};
 
 			macb0: ethernet@f802c000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xf802c000 0x100>;
 				interrupts = <24 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
diff --git a/arch/arm/boot/dts/at91sam9x5_macb1.dtsi b/arch/arm/boot/dts/at91sam9x5_macb1.dtsi
index 663676c..d81980c 100644
--- a/arch/arm/boot/dts/at91sam9x5_macb1.dtsi
+++ b/arch/arm/boot/dts/at91sam9x5_macb1.dtsi
@@ -41,7 +41,7 @@
 			};
 
 			macb1: ethernet@f8030000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xf8030000 0x100>;
 				interrupts = <27 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
diff --git a/arch/arm/boot/dts/sama5d3_emac.dtsi b/arch/arm/boot/dts/sama5d3_emac.dtsi
index fe2af92..b4544cf 100644
--- a/arch/arm/boot/dts/sama5d3_emac.dtsi
+++ b/arch/arm/boot/dts/sama5d3_emac.dtsi
@@ -41,7 +41,7 @@
 			};
 
 			macb1: ethernet@f802c000 {
-				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				compatible = "cdns,at91sam9260-macb", "cdns,macb";
 				reg = <0xf802c000 0x100>;
 				interrupts = <35 IRQ_TYPE_LEVEL_HIGH 3>;
 				pinctrl-names = "default";
-- 
1.9.1
