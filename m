From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH V2 3/4] arm64: boot: dts: Add DTS entries for APM X-Gene SoC Queue Manager/Traffic Manager
Date: Fri, 20 Dec 2013 18:57:30 -0800
Message-ID: <1387594651-25771-4-git-send-email-rapatel@apm.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds APM X-Gene SoC Queue Manager/Traffic Manager DTS entries.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm-storm.dtsi |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index d37d736..f64f946 100644
--- a/arch/arm64/boot/dts/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm-storm.dtsi
@@ -152,6 +152,11 @@
 				reg = <0x0 0x1703C000 0x0 0x1000>;
 				reg-names = "csr-reg";
 				clock-output-names = "qmlclk";
+				status = "ok";
+				csr-offset = <0x0>;
+				csr-mask = <0x3>;
+				enable-offset = <0x8>;
+				enable-mask = <0x3>;
 			};
 
 			ethclk: ethclk {
@@ -187,5 +192,17 @@
 			interrupt-parent = <&gic>;
 			interrupts = <0x0 0x4c 0x4>;
 		};
+
+		qmlite: qmtm@17030000 {
+			compatible = "apm,xgene-qmtm-lite";
+			reg = <0x0 0x17030000 0x0 0x10000>,
+			      <0x0 0x10000000 0x0 0x400000>;
+			slave-name = "CPU_QMTM3";
+			interrupts = <0x0 0x40 0x4>,
+				     <0x0 0x3c 0x4>;
+			status = "ok";
+			#clock-cells = <1>;
+			clocks = <&qmlclk 0>;
+		};
 	};
 };
-- 
1.7.9.5
