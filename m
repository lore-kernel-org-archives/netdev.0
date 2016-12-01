From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 7/7] Documentation: DT: net: cpsw: remove no_bd_ram property
Date: Thu, 1 Dec 2016 17:34:32 -0600
Message-ID: <20161201233432.6182-8-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even if no_bd_ram property is described in TI CPSW bindings the
support for it has never been introduced in CPSW driver, so there are
no real users of it. Hence, remove no_bd_ram property.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 3 ---
 arch/arm/boot/dts/am33xx.dtsi                  | 1 -
 arch/arm/boot/dts/am4372.dtsi                  | 1 -
 arch/arm/boot/dts/dm814x.dtsi                  | 1 -
 arch/arm/boot/dts/dra7.dtsi                    | 1 -
 5 files changed, 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index b99d196..4e8b673 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -25,7 +25,6 @@ Required properties:
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
-- no_bd_ram		: Must be 0 or 1
 - dual_emac		: Specifies Switch to act as Dual EMAC
 - syscon		: Phandle to the system control device node, which is
 			  the control module device of the am33x
@@ -73,7 +72,6 @@ Examples:
 		cpdma_channels = <8>;
 		ale_entries = <1024>;
 		bd_ram_size = <0x2000>;
-		no_bd_ram = <0>;
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
@@ -102,7 +100,6 @@ Examples:
 		cpdma_channels = <8>;
 		ale_entries = <1024>;
 		bd_ram_size = <0x2000>;
-		no_bd_ram = <0>;
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 194d884..7af5520 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -777,7 +777,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index a275fa9..4f651be 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -668,7 +668,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dm814x.dtsi b/arch/arm/boot/dts/dm814x.dtsi
index ff90a6c..614a4ba 100644
--- a/arch/arm/boot/dts/dm814x.dtsi
+++ b/arch/arm/boot/dts/dm814x.dtsi
@@ -508,7 +508,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index d4fcd68..cf7325d 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -1706,7 +1706,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
-- 
2.10.1
