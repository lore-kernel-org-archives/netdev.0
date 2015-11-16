From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH v2 net-next] net: hisilicon: fix binding document of mdio
Date: Mon, 16 Nov 2015 17:38:24 +0800
Message-ID: <1447666704-200773-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch explains the occasion of "hisilcon,mdio" and
"hisilicon,hns-mdio" according to Arnd's comments.
and reformat it according to comments from Rob<robh@kernel.org>.

chang log:

v2:
  1) reformat the style.
  2) make it more clearity.

v1:
  initial version.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
---
 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
index 9c23fdf..4942d20 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
@@ -1,7 +1,12 @@
 Hisilicon MDIO bus controller
 
 Properties:
-- compatible: "hisilicon,mdio","hisilicon,hns-mdio".
+- compatible: can be one of:
+	"hisilicon,hns-mdio"
+	"hisilicon,mdio"
+  "hisilicon,hns-mdio" is recommendly to be used for hip05 and later SOCs,
+  while "hisilicon,mdio" is optional for backwards compatibility, only
+  support for hip04 Soc.
 - reg: The base address of the MDIO bus controller register bank.
 - #address-cells: Must be <1>.
 - #size-cells: Must be <0>.  MDIO addresses have no size component.
-- 
1.9.1
