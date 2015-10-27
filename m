From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH RESEND v2 net-next] net: hisilicon: updates HNS config and
 documents
Date: Tue, 27 Oct 2015 19:16:34 +0800
Message-ID: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, salil.mehta@huawei.com,
 kenneth-lee-2012@foxmail.com, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, catalin.marinas@arm.com, lipeng321@huawei.com,
 will.deacon@arm.com, linux-kernel@vger.kernel.org, xuwei5@hisilicon.com,
 linuxarm@huawei.com, Yisen.Zhuang@huawei.com, huangdaode@hisilicon.com,
 galak@codeaurora.org, lisheng011@huawei.com, liguozhu@hisilicon.com,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <robh+dt@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

From: yankejian <yankejian@huawei.com>

updates the bindings documents and dtsi file according to the review
comments[https://lkml.org/lkml/2015/9/21/670] from Rob Herring <robh@kernel.org>

Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: huangdaode <huangdaode@hisilicon.com>
---
 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt | 2 +-
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi                 | 8 +++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
index 9940aa0..9c23fdf 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
@@ -12,7 +12,7 @@ Example:
          mdio@803c0000 {
                    #address-cells = <1>;
                    #size-cells = <0>;
-                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
+                   compatible = "hisilicon,hns-mdio","hisilicon,mdio";
                    reg = <0x0 0x803c0000 0x0 0x10000>;
 
                    ethernet-phy@0 {
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 3500586..606dd5a 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -13,14 +13,12 @@ soc0: soc@000000000 {
 		reg = <0x0 0x803c0000 0x0 0x10000
 		       0x0 0x80000000 0x0 0x10000>;
 
-		soc0_phy4: ethernet-phy@4 {
+		soc0_phy0: ethernet-phy@0 {
 			reg = <0x0>;
-			device_type = "ethernet-phy";
 			compatible = "ethernet-phy-ieee802.3-c22";
 		};
-		soc0_phy5: ethernet-phy@5 {
+		soc0_phy1: ethernet-phy@1 {
 			reg = <0x1>;
-			device_type = "ethernet-phy";
 			compatible = "ethernet-phy-ieee802.3-c22";
 		};
 	};
@@ -37,7 +35,7 @@ soc0: soc@000000000 {
 		       0x0 0xc7000000 0x0 0x60000
 		       >;
 
-		phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
+		phy-handle = <0 0 0 0 &soc0_phy0 &soc0_phy1 0 0>;
 		interrupts = <
 			/* [14] ge fifo err 8 / xge 6**/
 			149 0x4 150 0x4 151 0x4 152 0x4
-- 
1.9.1
