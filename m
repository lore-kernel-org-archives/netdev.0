From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 2/2] Documentation: DT: cpsw: remove rx_descs property
Date: Fri, 17 Jun 2016 13:25:40 +0300
Message-ID: <1466159140-3329-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason to hold s/w dependent parameter in device tree.
Even more, there is no reason in this parameter because davinici_cpdma
driver splits pool of descriptors equally between tx and rx channels
anyway.

Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 1 -
 arch/arm/boot/dts/am33xx.dtsi                  | 1 -
 arch/arm/boot/dts/am4372.dtsi                  | 1 -
 arch/arm/boot/dts/dm814x.dtsi                  | 1 -
 arch/arm/boot/dts/dra7.dtsi                    | 1 -
 5 files changed, 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 0ae0649..5ad439f 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -15,7 +15,6 @@ Required properties:
 - cpdma_channels 	: Specifies number of channels in CPDMA
 - ale_entries		: Specifies No of entries ALE can hold
 - bd_ram_size		: Specifies internal descriptor RAM size
-- rx_descs		: Specifies number of Rx descriptors
 - mac_control		: Specifies Default MAC control register content
 			  for the specific platform
 - slaves		: Specifies number for slaves
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 52be48b..702126f 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -766,7 +766,6 @@
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;
-			rx_descs = <64>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index 12fcde4..a10fa7f 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -626,7 +626,6 @@
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;
-			rx_descs = <64>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dm814x.dtsi b/arch/arm/boot/dts/dm814x.dtsi
index d4537dc..f23cae0c 100644
--- a/arch/arm/boot/dts/dm814x.dtsi
+++ b/arch/arm/boot/dts/dm814x.dtsi
@@ -509,7 +509,6 @@
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;
-			rx_descs = <64>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index e007401..b7ddc64 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -1626,7 +1626,6 @@
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;
-			rx_descs = <64>;
 			mac_control = <0x20>;
 			slaves = <2>;
 			active_slave = <0>;
-- 
1.9.1
