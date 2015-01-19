From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v1 2/4] ARM: dts: Add regulator voltage settings for vcc_phy
 in rk3288-evb.dtsi
Date: Mon, 19 Jan 2015 18:08:07 +0000
Message-ID: <1421690889-11901-3-git-send-email-romain.perier@gmail.com>
References: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, heiko@sntech.de, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
 roger.chen@rock-chips.com, linux-arm-kernel@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
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

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3288-evb.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288-evb.dtsi b/arch/arm/boot/dts/rk3288-evb.dtsi
index 489643c..1c08eb0 100644
--- a/arch/arm/boot/dts/rk3288-evb.dtsi
+++ b/arch/arm/boot/dts/rk3288-evb.dtsi
@@ -98,6 +98,8 @@
 		pinctrl-names = "default";
 		pinctrl-0 = <&eth_phy_pwr>;
 		regulator-name = "vcc_phy";
+		regulator-min-microvolt = <3300000>;
+		regulator-max-microvolt = <3300000>;
 		regulator-always-on;
 		regulator-boot-on;
 	};
-- 
1.9.1
