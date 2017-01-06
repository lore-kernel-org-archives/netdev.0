From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 7/7] Documentation: DT: net: cpsw: remove no_bd_ram property
Date: Fri, 6 Jan 2017 14:07:35 -0600
Message-ID: <20170106200735.4210-8-grygorii.strashko@ti.com>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "'Rob Herring '" <robh+dt@kernel.org>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even if no_bd_ram property is described in TI CPSW bindings the support for
it has never been introduced in CPSW driver, so there are no real users of
it. Hence, remove no_bd_ram property from documentation and DT files.

Cc: 'Rob Herring <robh+dt@kernel.org>'
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 3 ---
 arch/arm/boot/dts/am33xx.dtsi                  | 1 -
 arch/arm/boot/dts/am4372.dtsi                  | 1 -
 arch/arm/boot/dts/dm814x.dtsi                  | 1 -
 arch/arm/boot/dts/dra7.dtsi                    | 1 -
 5 files changed, 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index ebda7c9..7cc15c9 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -23,7 +23,6 @@ Required properties:
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
-- no_bd_ram		: Must be 0 or 1
 - dual_emac		: Specifies Switch to act as Dual EMAC
 - syscon		: Phandle to the system control device node, which is
 			  the control module device of the am33x
@@ -70,7 +69,6 @@ Examples:
 		cpdma_channels = <8>;
 		ale_entries = <1024>;
 		bd_ram_size = <0x2000>;
-		no_bd_ram = <0>;
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
@@ -99,7 +97,6 @@ Examples:
 		cpdma_channels = <8>;
 		ale_entries = <1024>;
 		bd_ram_size = <0x2000>;
-		no_bd_ram = <0>;
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 64c8aa9..d458ceb 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -781,7 +781,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index ac55f93..837aff1 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -669,7 +669,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dm814x.dtsi b/arch/arm/boot/dts/dm814x.dtsi
index 1facc5f..4cbeb5c 100644
--- a/arch/arm/boot/dts/dm814x.dtsi
+++ b/arch/arm/boot/dts/dm814x.dtsi
@@ -509,7 +509,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index addb753..b69df91 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -1707,7 +1707,6 @@
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-			no_bd_ram = <0>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
-- 
2.10.1.dirty
