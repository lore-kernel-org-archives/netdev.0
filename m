From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 3/3] IB/hns: Add binding document for HiSilicon RoCE driver
Date: Sat, 19 Mar 2016 18:50:58 +0800
Message-ID: <1458384658-16759-4-git-send-email-oulijun@huawei.com>
References: <1458384658-16759-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458384658-16759-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds related DTS binding document for HiSilicon RoCE driver.

Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../bindings/infiniband/hisilicon-hns-roce.txt     | 107 +++++++++++++++++++++
 1 file changed, 107 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt

diff --git a/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt b/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
new file mode 100644
index 0000000..5180fef
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
+  - roce_ce0_irq ~ roce_ce31_irq: 32 complete event irq
+  - roce_ae_irq: 1 async event irq
+  - roce_common_irq: named common exception warning irq
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
+			interrupt-names = "roce_ce0_irq",
+					"roce_ce1_irq",
+					"roce_ce2_irq",
+					"roce_ce3_irq",
+					"roce_ce4_irq",
+					"roce_ce5_irq",
+					"roce_ce6_irq",
+					"roce_ce7_irq",
+					"roce_ce8_irq",
+					"roce_ce9_irq",
+					"roce_ce10_irq",
+					"roce_ce11_irq",
+					"roce_ce12_irq",
+					"roce_ce13_irq",
+					"roce_ce14_irq",
+					"roce_ce15_irq",
+					"roce_ce16_irq",
+					"roce_ce17_irq",
+					"roce_ce18_irq",
+					"roce_ce19_irq",
+					"roce_ce20_irq",
+					"roce_ce21_irq",
+					"roce_ce22_irq",
+					"roce_ce23_irq",
+					"roce_ce24_irq",
+					"roce_ce25_irq",
+					"roce_ce26_irq",
+					"roce_ce27_irq",
+					"roce_ce28_irq",
+					"roce_ce29_irq",
+					"roce_ce30_irq",
+					"roce_ce31_irq",
+					"roce_ae_irq",
+					"roce_common_irq";
+		};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
