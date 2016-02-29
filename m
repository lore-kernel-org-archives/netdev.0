From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH 3/3] ARM: dts: stm32f429: Enable Ethernet on Eval board
Date: Mon, 29 Feb 2016 17:29:36 +0100
Message-ID: <1456763376-21457-4-git-send-email-alexandre.torgue@gmail.com>
References: <1456763376-21457-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Daniel Thompson <daniel.thompson@linaro.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Kamil Lulko <rev13@wp.pl>, afaerber@suse.de
To: Arnd Bergmann <arnd@arndb.de>, olof@lixom.net, khilman@kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456763376-21457-1-git-send-email-alexandre.torgue@gmail.com>
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

MAC is connected to a PHY in MII mode.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/arch/arm/boot/dts/stm32429i-eval.dts b/arch/arm/boot/dts/stm32429i-eval.dts
index 1ae57fa..e345459 100644
--- a/arch/arm/boot/dts/stm32429i-eval.dts
+++ b/arch/arm/boot/dts/stm32429i-eval.dts
@@ -87,6 +87,21 @@
 	clock-frequency = <25000000>;
 };
 
+&ethernet0 {
+	status = "okay";
+	pinctrl-0	= <&ethernet0_mii>;
+	pinctrl-names	= "default";
+	phy-mode	= "mii-id";
+	mdio0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "snps,dwmac-mdio";
+			phy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
+};
+
 &usart1 {
 	pinctrl-0 = <&usart1_pins_a>;
 	pinctrl-names = "default";
-- 
1.9.1
