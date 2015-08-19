From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 2/6] ARM: imx7d: add imx7d iomux-gpr field define
Date: Wed, 19 Aug 2015 13:34:00 +0800
Message-ID: <1439962444-27486-3-git-send-email-b38611@freescale.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b38611@freescale.com,
 linux-arm-kernel@lists.infradead.org
To: <shawnguo@kernel.org>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
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

Add imx7d iomux-gpr field define.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 include/linux/mfd/syscon/imx7-iomuxc-gpr.h | 49 ++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/include/linux/mfd/syscon/imx7-iomuxc-gpr.h b/include/linux/mfd/syscon/imx7-iomuxc-gpr.h
new file mode 100644
index 0000000..5cc0553
--- /dev/null
+++ b/include/linux/mfd/syscon/imx7-iomuxc-gpr.h
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2015 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __LINUX_IMX7_IOMUXC_GPR_H
+#define __LINUX_IMX7_IOMUXC_GPR_H
+
+#include <linux/bitops.h>
+
+#define IOMUXC_GPR0	0x00
+#define IOMUXC_GPR1	0x04
+#define IOMUXC_GPR2	0x08
+#define IOMUXC_GPR3	0x0c
+#define IOMUXC_GPR4	0x10
+#define IOMUXC_GPR5	0x14
+#define IOMUXC_GPR6	0x18
+#define IOMUXC_GPR7	0x1c
+#define IOMUXC_GPR8	0x20
+#define IOMUXC_GPR9	0x24
+#define IOMUXC_GPR10	0x28
+#define IOMUXC_GPR11	0x2c
+#define IOMUXC_GPR12	0x30
+#define IOMUXC_GPR13	0x34
+#define IOMUXC_GPR14	0x38
+#define IOMUXC_GPR15	0x3c
+#define IOMUXC_GPR16	0x40
+#define IOMUXC_GPR17	0x44
+#define IOMUXC_GPR18	0x48
+#define IOMUXC_GPR19	0x4c
+#define IOMUXC_GPR20	0x50
+#define IOMUXC_GPR21	0x54
+#define IOMUXC_GPR22	0x58
+
+/* For imx7d iomux gpr register field define */
+#define IMX7D_GPR1_IRQ_MASK			(0x1 << 12)
+#define IMX7D_GPR1_ENET1_TX_CLK_SEL_MASK	(0x1 << 13)
+#define IMX7D_GPR1_ENET2_TX_CLK_SEL_MASK	(0x1 << 14)
+#define IMX7D_GPR1_ENET_TX_CLK_SEL_MASK		(0x3 << 13)
+#define IMX7D_GPR1_ENET1_CLK_DIR_MASK		(0x1 << 17)
+#define IMX7D_GPR1_ENET2_CLK_DIR_MASK		(0x1 << 18)
+#define IMX7D_GPR1_ENET_CLK_DIR_MASK		(0x3 << 17)
+
+#define IMX7D_GPR5_CSI_MUX_CONTROL_MIPI		(0x1 << 4)
+
+#endif /* __LINUX_IMX7_IOMUXC_GPR_H */
-- 
1.9.1
