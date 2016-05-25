From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v8 02/22] devicetree: bindings: IB: Add binding document for HiSilicon RoCE
Date: Wed, 25 May 2016 23:05:05 +0800
Message-ID: <1464188725-42805-3-git-send-email-oulijun@huawei.com>
References: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added DTS binding document for HiSilicon RoCE driver.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 .../bindings/infiniband/hisilicon-hns-roce.txt     | 107 +++++++++++++++++++++
 1 file changed, 107 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt

diff --git a/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt b/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
new file mode 100644
index 0000000..2c59ed9
--- /dev/null
+++ b/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
@@ -0,0 +1,107 @@
+HiSilicon RoCE DT description
+
+HiSilicon RoCE engine is a part of network subsystem.
+It works depending on other part of network wubsytem, such as, gmac and
+dsa fabric.
+
+Additional properties are described here:
+
+Required properties:
+- compatible: Should contain "hisilicon,hns-roce-v1".
+- reg: Physical base address of the roce driver and
+length of memory mapped region.
+- eth-handle: phandle, specifies a reference to a node
+representing a ethernet device.
+- dsaf-handle: phandle, specifies a reference to a node
+representing a dsaf device.
+- #address-cells: must be 2
+- #size-cells: must be 2
+Optional properties:
+- dma-coherent: Present if DMA operations are coherent.
+- interrupt-parent: the interrupt parent of this device.
+- interrupts: should contain 32 completion event irq,1 async event irq
+and 1 event overflow irq.
+- interrupt-names:should be one of 34 irqs for roce device
+  - hns-roce-comp-0 ~ hns-roce-comp-31: 32 complete event irq
+  - hns-roce-async: 1 async event irq
+  - hns-roce-common: named common exception warning irq
+Example:
+	infiniband@c4000000 {
+			compatible = "hisilicon,hns-roce-v1";
+			reg = <0x0 0xc4000000 0x0 0x100000>;
+			dma-coherent;
+			eth-handle = <&eth2 &eth3 &eth4 &eth5 &eth6 &eth7>;
+			dsaf-handle = <&soc0_dsa>;
+			#address-cells = <2>;
+			#size-cells = <2>;
+			interrupt-parent = <&mbigen_dsa>;
+			interrupts = <722 1>,
+					<723 1>,
+					<724 1>,
+					<725 1>,
+					<726 1>,
+					<727 1>,
+					<728 1>,
+					<729 1>,
+					<730 1>,
+					<731 1>,
+					<732 1>,
+					<733 1>,
+					<734 1>,
+					<735 1>,
+					<736 1>,
+					<737 1>,
+					<738 1>,
+					<739 1>,
+					<740 1>,
+					<741 1>,
+					<742 1>,
+					<743 1>,
+					<744 1>,
+					<745 1>,
+					<746 1>,
+					<747 1>,
+					<748 1>,
+					<749 1>,
+					<750 1>,
+					<751 1>,
+					<752 1>,
+					<753 1>,
+					<785 1>,
+					<754 4>;
+
+			interrupt-names = "hns-roce-comp-0",
+					"hns-roce-comp-1",
+					"hns-roce-comp-2",
+					"hns-roce-comp-3",
+					"hns-roce-comp-4",
+					"hns-roce-comp-5",
+					"hns-roce-comp-6",
+					"hns-roce-comp-7",
+					"hns-roce-comp-8",
+					"hns-roce-comp-9",
+					"hns-roce-comp-10",
+					"hns-roce-comp-11",
+					"hns-roce-comp-12",
+					"hns-roce-comp-13",
+					"hns-roce-comp-14",
+					"hns-roce-comp-15",
+					"hns-roce-comp-16",
+					"hns-roce-comp-17",
+					"hns-roce-comp-18",
+					"hns-roce-comp-19",
+					"hns-roce-comp-20",
+					"hns-roce-comp-21",
+					"hns-roce-comp-22",
+					"hns-roce-comp-23",
+					"hns-roce-comp-24",
+					"hns-roce-comp-25",
+					"hns-roce-comp-26",
+					"hns-roce-comp-27",
+					"hns-roce-comp-28",
+					"hns-roce-comp-29",
+					"hns-roce-comp-30",
+					"hns-roce-comp-31",
+					"hns-roce-async",
+					"hns-roce-common";
+		};
-- 
1.9.1
