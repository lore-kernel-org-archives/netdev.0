From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH v2 3/3] ARM: zynq: DT: Use the zynq binding with macb
Date: Fri, 22 May 2015 09:22:11 -0500
Message-ID: <1432304531-23682-3-git-send-email-nathan.sullivan@ni.com>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new zynq binding for macb ethernet, since it will disable half
duplex gigabit like the Zynq TRM says to do.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 arch/arm/boot/dts/zynq-7000.dtsi |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/zynq-7000.dtsi b/arch/arm/boot/dts/zynq-7000.dtsi
index a5cd2ed..9ea54b3 100644
--- a/arch/arm/boot/dts/zynq-7000.dtsi
+++ b/arch/arm/boot/dts/zynq-7000.dtsi
@@ -193,7 +193,7 @@
 		};
 
 		gem0: ethernet@e000b000 {
-			compatible = "cdns,gem";
+			compatible = "cdns,zynq-gem";
 			reg = <0xe000b000 0x1000>;
 			status = "disabled";
 			interrupts = <0 22 4>;
@@ -204,7 +204,7 @@
 		};
 
 		gem1: ethernet@e000c000 {
-			compatible = "cdns,gem";
+			compatible = "cdns,zynq-gem";
 			reg = <0xe000c000 0x1000>;
 			status = "disabled";
 			interrupts = <0 45 4>;
-- 
1.7.10.4
