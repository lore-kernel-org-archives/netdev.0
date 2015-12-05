From: yankejian <yankejian@huawei.com>
Subject: [PATCH RESEND net-next 3/3] arm64: hip05-d02: Document devicetree
 bindings for Hisilicon D02 Board
Date: Sat, 5 Dec 2015 15:56:58 +0800
Message-ID: <1449302218-54374-4-git-send-email-yankejian@huawei.com>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linuxarm@huawei.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <xuwei5@hisilicon.com>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>,
 <wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
 <liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
 <sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
 <wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
 <long.wanglong@huawei.com>, <leo.yan@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
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

This patch adds documentation for the devicetree bindings used by the
DT files of Hisilicon Hip05-D02 development board.

Signed-off-by: yankejian <yankejian@huawei.com>
---
 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
index 6ac7c00..5318d78 100644
--- a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
+++ b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
@@ -187,6 +187,22 @@ Example:
 		reg = <0xb0000000 0x10000>;
 	};
 
+Hisilicon HiP05 PERISUB system controller
+
+Required properties:
+- compatible : "hisilicon,peri-c-subctrl", "syscon";
+- reg : Register address and size
+
+The HiP05 PERISUB system controller is shared by peripheral controllers in
+HiP05 Soc to implement some basic configurations. the peripheral
+ controllers include mdio, ddr, iic, uart, timer and so on.
+
+Example:
+	/* for HiP05 PCIe-SAS system */
+	pcie_sas: system_controller@0xb0000000 {
+		compatible = "hisilicon,pcie-sas-subctrl", "syscon";
+		reg = <0xb0000000 0x10000>;
+	};
 -----------------------------------------------------------------------
 Hisilicon CPU controller
 
-- 
1.9.1
