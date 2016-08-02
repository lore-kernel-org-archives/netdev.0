From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0783/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:56 +0800
Message-ID: <20160802114556.1945-1-baolex.ni@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, a@unstable.cc, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
	Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org, m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/intersil/p54/p54spi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intersil/p54/p54spi.c b/drivers/net/wireless/intersil/p54/p54spi.c
index 7ab2f43..07c77f8 100644
--- a/drivers/net/wireless/intersil/p54/p54spi.c
+++ b/drivers/net/wireless/intersil/p54/p54spi.c
@@ -48,11 +48,11 @@ MODULE_FIRMWARE("3826.arm");
  */
 
 static int p54spi_gpio_power = 97;
-module_param(p54spi_gpio_power, int, 0444);
+module_param(p54spi_gpio_power, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(p54spi_gpio_power, "gpio number for power line");
 
 static int p54spi_gpio_irq = 87;
-module_param(p54spi_gpio_irq, int, 0444);
+module_param(p54spi_gpio_irq, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(p54spi_gpio_irq, "gpio number for irq line");
 
 static void p54spi_spi_read(struct p54s_priv *priv, u8 address,
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
