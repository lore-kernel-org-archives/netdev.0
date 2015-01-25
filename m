From: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] ARM: sunxi: Add register bit definitions
 for SRAM mapping syscon
Date: Sun, 25 Jan 2015 16:49:18 +0100
Message-ID: <1422200959-1717-3-git-send-email-jenskuske@gmail.com>
References: <1422200959-1717-1-git-send-email-jenskuske@gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-sunxi+bncBCC5XIE2SIHBBB5BSSTAKGQEK5CKJYY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1422200959-1717-1-git-send-email-jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Signed-off-by: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/mfd/syscon/sun4i-sc.h | 42 +++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)
 create mode 100644 include/linux/mfd/syscon/sun4i-sc.h

diff --git a/include/linux/mfd/syscon/sun4i-sc.h b/include/linux/mfd/syscon/sun4i-sc.h
new file mode 100644
index 0000000..fb970d9
--- /dev/null
+++ b/include/linux/mfd/syscon/sun4i-sc.h
@@ -0,0 +1,42 @@
+/**
+ * sun4i-sc.h - Allwinner sun4i system control register bit definitions
+ *
+ * Copyright (C) 2014 Chen-Yu Tsai
+ *
+ * Chen-Yu Tsai  <wens-jdAy2FN1RRM@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __LINUX_SUN4I_SC_H
+#define __LINUX_SUN4I_SC_H
+
+#include <linux/bitops.h>
+
+/* Registers */
+#define SUN4I_SC0	0x00
+#define SUN4I_SC1	0x04
+
+/* SRAM control register 0 bits */
+#define SUN4I_SC0_SRAM_C1_MAP_VE	0x7fffffff
+
+/* SRAM control register 1 bits */
+#define SUN4I_SC1_BIST_NDMA_CTRL_SEL	BIT(31)
+#define SUN4I_SC1_SRAM_C3_MAP_ISP	BIT(12)
+#define SUN4I_SC1_SRAM_C2_MAP_MASK	0x0300
+#define SUN4I_SC1_SRAM_C2_MAP_AE	0x0100
+#define SUN4I_SC1_SRAM_C2_MAP_CE	0x0200
+#define SUN4I_SC1_SRAM_C2_MAP_ACE	0x0300
+#define SUN4I_SC1_SRAM_A3_A4_MAP_MASK	0x0030
+#define SUN4I_SC1_SRAM_A3_A4_MAP_EMAC	0x0010
+#define SUN4I_SC1_SRAM_D_MAP_USB0	BIT(0)
+
+#endif /* __LINUX_SUN4I_SC_H */
-- 
2.2.2
