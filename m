From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] arch/arc: angel4.dts - add description for "arc_emac"
Date: Wed, 26 Jun 2013 13:37:49 +0400
Message-ID: <1372239469-28537-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Joe Perches" <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this patch we introduce DT "arc_emac" description for ARCangel4.
Description is based on info/example in
"Documentation/devicetree/bindings/net/arc_emac.txt".

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Joe Perches <joe@perches.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Florian Fainelli <florian@openwrt.org>
---
 arch/arc/boot/dts/angel4.dts |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/arc/boot/dts/angel4.dts b/arch/arc/boot/dts/angel4.dts
index bae4f93..4fb2d6f 100644
--- a/arch/arc/boot/dts/angel4.dts
+++ b/arch/arc/boot/dts/angel4.dts
@@ -51,5 +51,21 @@
 			current-speed = <115200>;
 			status = "okay";
 		};
+
+		ethernet@c0fc2000 {
+			compatible = "snps,arc-emac";
+			reg = <0xc0fc2000 0x3c>;
+			interrupts = <6>;
+			mac-address = [ 00 11 22 33 44 55 ];
+			clock-frequency = <80000000>;
+			max-speed = <100>;
+			phy = <&phy0>;
+
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy0: ethernet-phy@0 {
+				reg = <1>;
+			};
+		};
 	};
 };
-- 
1.7.10.4
