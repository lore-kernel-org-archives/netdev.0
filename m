From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH] treewide: remove redundant #include <linux/kconfig.h>
Date: Mon, 12 Sep 2016 13:56:04 +0900
Message-ID: <1473656164-11929-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>,
 Marek Lindner <mareklindner@neomailbox.ch>,
 Liam Girdwood <lgirdwood@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Linus Walleij <linus.walleij@linaro.org>,
 Trond Myklebust <trond.myklebust@primarydata.com>,
 Antonio Quartulli <a@unstable.cc>, Jaroslav Kysela <perex@perex.cz>,
 "J. Bruce Fields" <bfields@fieldses.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, linux-mtd@lists.infradead.org,
 Hans Verkuil <hverkuil@xs4all.nl>, Michael Buesch <m@bues.ch>,
 Jeff Layton <jlayton@poochiereds.net>, Olli Salonen <olli.salonen@iki.fi>,
 Alexandre Courbot <gnurou@gmail.com>, Florian Fainelli <f.fainelli@gmail.com>,
 Sergey Kozlov <serjk@netup.ru>, Mathias Nyman <mathias.nyman@intel.com>,
 Patrick Boettcher <patrick.boettcher@posteo.de>,
 Kevin Cernekee <cernekee@gmail.com
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Kernel source files need not include <linux/kconfig.h> explicitly
because the top Makefile forces to include it with:

  -include $(srctree)/include/linux/kconfig.h

This commit removes explicit includes except the following:

  * arch/s390/include/asm/facilities_src.h
  * tools/testing/radix-tree/linux/kernel.h

These two are used for host programs.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

I thought including <asm/facilities_src.h> from a host tool
is weird.  I am planning to fix it later.


 arch/arm/include/asm/trusted_foundations.h       | 1 -
 arch/arm64/include/asm/alternative.h             | 1 -
 arch/mips/include/asm/mach-loongson64/loongson.h | 1 -
 arch/mips/math-emu/cp1emu.c                      | 1 -
 arch/mips/net/bpf_jit.c                          | 1 -
 drivers/char/virtio_console.c                    | 1 -
 drivers/input/rmi4/rmi_bus.c                     | 1 -
 drivers/input/rmi4/rmi_driver.c                  | 1 -
 drivers/input/rmi4/rmi_f01.c                     | 1 -
 drivers/input/rmi4/rmi_f11.c                     | 1 -
 drivers/irqchip/irq-bcm6345-l1.c                 | 1 -
 drivers/irqchip/irq-bcm7038-l1.c                 | 1 -
 drivers/irqchip/irq-bcm7120-l2.c                 | 1 -
 drivers/irqchip/irq-brcmstb-l2.c                 | 1 -
 drivers/media/dvb-frontends/af9013.h             | 1 -
 drivers/media/dvb-frontends/af9033.h             | 2 --
 drivers/media/dvb-frontends/ascot2e.h            | 1 -
 drivers/media/dvb-frontends/atbm8830.h           | 1 -
 drivers/media/dvb-frontends/au8522.h             | 1 -
 drivers/media/dvb-frontends/cx22702.h            | 1 -
 drivers/media/dvb-frontends/cx24113.h            | 2 --
 drivers/media/dvb-frontends/cx24116.h            | 1 -
 drivers/media/dvb-frontends/cx24117.h            | 1 -
 drivers/media/dvb-frontends/cx24120.h            | 1 -
 drivers/media/dvb-frontends/cx24123.h            | 1 -
 drivers/media/dvb-frontends/cxd2820r.h           | 1 -
 drivers/media/dvb-frontends/cxd2841er.h          | 1 -
 drivers/media/dvb-frontends/dib3000mc.h          | 2 --
 drivers/media/dvb-frontends/dib7000m.h           | 2 --
 drivers/media/dvb-frontends/dib7000p.h           | 2 --
 drivers/media/dvb-frontends/drxd.h               | 1 -
 drivers/media/dvb-frontends/drxk.h               | 1 -
 drivers/media/dvb-frontends/ds3000.h             | 1 -
 drivers/media/dvb-frontends/dvb_dummy_fe.h       | 1 -
 drivers/media/dvb-frontends/ec100.h              | 1 -
 drivers/media/dvb-frontends/hd29l2.h             | 1 -
 drivers/media/dvb-frontends/helene.h             | 1 -
 drivers/media/dvb-frontends/horus3a.h            | 1 -
 drivers/media/dvb-frontends/ix2505v.h            | 1 -
 drivers/media/dvb-frontends/lg2160.h             | 1 -
 drivers/media/dvb-frontends/lgdt3305.h           | 1 -
 drivers/media/dvb-frontends/lgs8gl5.h            | 1 -
 drivers/media/dvb-frontends/lgs8gxx.h            | 1 -
 drivers/media/dvb-frontends/lnbh24.h             | 2 --
 drivers/media/dvb-frontends/lnbh25.h             | 1 -
 drivers/media/dvb-frontends/lnbp21.h             | 2 --
 drivers/media/dvb-frontends/lnbp22.h             | 2 --
 drivers/media/dvb-frontends/m88rs2000.h          | 1 -
 drivers/media/dvb-frontends/mb86a20s.h           | 1 -
 drivers/media/dvb-frontends/s5h1409.h            | 1 -
 drivers/media/dvb-frontends/s5h1411.h            | 1 -
 drivers/media/dvb-frontends/s5h1432.h            | 1 -
 drivers/media/dvb-frontends/s921.h               | 1 -
 drivers/media/dvb-frontends/si21xx.h             | 1 -
 drivers/media/dvb-frontends/sp2.h                | 1 -
 drivers/media/dvb-frontends/stb6000.h            | 1 -
 drivers/media/dvb-frontends/stv0288.h            | 1 -
 drivers/media/dvb-frontends/stv0367.h            | 1 -
 drivers/media/dvb-frontends/stv0900.h            | 1 -
 drivers/media/dvb-frontends/stv6110.h            | 1 -
 drivers/media/dvb-frontends/tda10048.h           | 1 -
 drivers/media/dvb-frontends/tda18271c2dd.h       | 2 --
 drivers/media/dvb-frontends/ts2020.h             | 1 -
 drivers/media/dvb-frontends/zl10036.h            | 1 -
 drivers/media/dvb-frontends/zl10039.h            | 2 --
 drivers/media/pci/cx23885/altera-ci.h            | 2 --
 drivers/media/tuners/fc0011.h                    | 1 -
 drivers/media/tuners/fc0012.h                    | 1 -
 drivers/media/tuners/fc0013.h                    | 1 -
 drivers/media/tuners/max2165.h                   | 2 --
 drivers/media/tuners/mc44s803.h                  | 2 --
 drivers/media/tuners/mxl5005s.h                  | 2 --
 drivers/media/tuners/r820t.h                     | 1 -
 drivers/media/tuners/si2157.h                    | 1 -
 drivers/media/tuners/tda18212.h                  | 1 -
 drivers/media/tuners/tda18218.h                  | 1 -
 drivers/media/tuners/xc5000.h                    | 1 -
 drivers/media/usb/dvb-usb-v2/mxl111sf-demod.h    | 1 -
 drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.h    | 1 -
 drivers/media/usb/dvb-usb/dibusb-common.c        | 1 -
 drivers/media/usb/hdpvr/hdpvr-video.c            | 1 -
 drivers/mtd/mtdcore.c                            | 1 -
 drivers/mtd/mtdpart.c                            | 1 -
 drivers/net/dsa/b53/b53_mmap.c                   | 1 -
 drivers/net/ethernet/sun/ldmvsw.c                | 1 -
 drivers/net/ethernet/wiznet/w5100.c              | 1 -
 drivers/net/ethernet/wiznet/w5300.c              | 1 -
 drivers/usb/early/ehci-dbgp.c                    | 1 -
 drivers/usb/gadget/udc/bcm63xx_udc.c             | 1 -
 drivers/usb/host/pci-quirks.c                    | 1 -
 fs/lockd/procfs.h                                | 2 --
 include/linux/export.h                           | 1 -
 include/linux/gpio/driver.h                      | 1 -
 net/batman-adv/debugfs.h                         | 2 --
 sound/soc/intel/common/sst-acpi.h                | 1 -
 tools/testing/nvdimm/config_check.c              | 1 -
 96 files changed, 112 deletions(-)

diff --git a/arch/arm/include/asm/trusted_foundations.h b/arch/arm/include/asm/trusted_foundations.h
index 624e1d4..0074835 100644
--- a/arch/arm/include/asm/trusted_foundations.h
+++ b/arch/arm/include/asm/trusted_foundations.h
@@ -26,7 +26,6 @@
 #ifndef __ASM_ARM_TRUSTED_FOUNDATIONS_H
 #define __ASM_ARM_TRUSTED_FOUNDATIONS_H
 
-#include <linux/kconfig.h>
 #include <linux/printk.h>
 #include <linux/bug.h>
 #include <linux/of.h>
diff --git a/arch/arm64/include/asm/alternative.h b/arch/arm64/include/asm/alternative.h
index 8746ff6..e998a1f 100644
--- a/arch/arm64/include/asm/alternative.h
+++ b/arch/arm64/include/asm/alternative.h
@@ -6,7 +6,6 @@
 #ifndef __ASSEMBLY__
 
 #include <linux/init.h>
-#include <linux/kconfig.h>
 #include <linux/types.h>
 #include <linux/stddef.h>
 #include <linux/stringify.h>
diff --git a/arch/mips/include/asm/mach-loongson64/loongson.h b/arch/mips/include/asm/mach-loongson64/loongson.h
index d1ff774..c68c0cc 100644
--- a/arch/mips/include/asm/mach-loongson64/loongson.h
+++ b/arch/mips/include/asm/mach-loongson64/loongson.h
@@ -14,7 +14,6 @@
 #include <linux/io.h>
 #include <linux/init.h>
 #include <linux/irq.h>
-#include <linux/kconfig.h>
 #include <boot_param.h>
 
 /* loongson internal northbridge initialization */
diff --git a/arch/mips/math-emu/cp1emu.c b/arch/mips/math-emu/cp1emu.c
index 36775d2..f8b7bf8 100644
--- a/arch/mips/math-emu/cp1emu.c
+++ b/arch/mips/math-emu/cp1emu.c
@@ -35,7 +35,6 @@
  */
 #include <linux/sched.h>
 #include <linux/debugfs.h>
-#include <linux/kconfig.h>
 #include <linux/percpu-defs.h>
 #include <linux/perf_event.h>
 
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 39e7b47..49a2e22 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -14,7 +14,6 @@
 #include <linux/errno.h>
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
-#include <linux/kconfig.h>
 #include <linux/moduleloader.h>
 #include <linux/netdevice.h>
 #include <linux/string.h>
diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index 5da47e26..65a6e04 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -38,7 +38,6 @@
 #include <linux/workqueue.h>
 #include <linux/module.h>
 #include <linux/dma-mapping.h>
-#include <linux/kconfig.h>
 #include "../tty/hvc/hvc_console.h"
 
 #define is_rproc_enabled IS_ENABLED(CONFIG_REMOTEPROC)
diff --git a/drivers/input/rmi4/rmi_bus.c b/drivers/input/rmi4/rmi_bus.c
index a735806..e0b5a45 100644
--- a/drivers/input/rmi4/rmi_bus.c
+++ b/drivers/input/rmi4/rmi_bus.c
@@ -9,7 +9,6 @@
 
 #include <linux/kernel.h>
 #include <linux/device.h>
-#include <linux/kconfig.h>
 #include <linux/list.h>
 #include <linux/pm.h>
 #include <linux/rmi.h>
diff --git a/drivers/input/rmi4/rmi_driver.c b/drivers/input/rmi4/rmi_driver.c
index c83bce8..4a88312 100644
--- a/drivers/input/rmi4/rmi_driver.c
+++ b/drivers/input/rmi4/rmi_driver.c
@@ -17,7 +17,6 @@
 #include <linux/bitmap.h>
 #include <linux/delay.h>
 #include <linux/fs.h>
-#include <linux/kconfig.h>
 #include <linux/pm.h>
 #include <linux/slab.h>
 #include <linux/of.h>
diff --git a/drivers/input/rmi4/rmi_f01.c b/drivers/input/rmi4/rmi_f01.c
index fac81fc..b5d2dfc 100644
--- a/drivers/input/rmi4/rmi_f01.c
+++ b/drivers/input/rmi4/rmi_f01.c
@@ -8,7 +8,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/kconfig.h>
 #include <linux/rmi.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
diff --git a/drivers/input/rmi4/rmi_f11.c b/drivers/input/rmi4/rmi_f11.c
index 20c7134..f798f42 100644
--- a/drivers/input/rmi4/rmi_f11.c
+++ b/drivers/input/rmi4/rmi_f11.c
@@ -12,7 +12,6 @@
 #include <linux/device.h>
 #include <linux/input.h>
 #include <linux/input/mt.h>
-#include <linux/kconfig.h>
 #include <linux/rmi.h>
 #include <linux/slab.h>
 #include <linux/of.h>
diff --git a/drivers/irqchip/irq-bcm6345-l1.c b/drivers/irqchip/irq-bcm6345-l1.c
index b844c89..daa4ae8 100644
--- a/drivers/irqchip/irq-bcm6345-l1.c
+++ b/drivers/irqchip/irq-bcm6345-l1.c
@@ -52,7 +52,6 @@
 
 #include <linux/bitops.h>
 #include <linux/cpumask.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
diff --git a/drivers/irqchip/irq-bcm7038-l1.c b/drivers/irqchip/irq-bcm7038-l1.c
index 0fea985..353c549 100644
--- a/drivers/irqchip/irq-bcm7038-l1.c
+++ b/drivers/irqchip/irq-bcm7038-l1.c
@@ -12,7 +12,6 @@
 #define pr_fmt(fmt)	KBUILD_MODNAME	": " fmt
 
 #include <linux/bitops.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
diff --git a/drivers/irqchip/irq-bcm7120-l2.c b/drivers/irqchip/irq-bcm7120-l2.c
index 0ec9263..64c2692 100644
--- a/drivers/irqchip/irq-bcm7120-l2.c
+++ b/drivers/irqchip/irq-bcm7120-l2.c
@@ -13,7 +13,6 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/platform_device.h>
 #include <linux/of.h>
diff --git a/drivers/irqchip/irq-brcmstb-l2.c b/drivers/irqchip/irq-brcmstb-l2.c
index 1d4a5b4..bddf169 100644
--- a/drivers/irqchip/irq-brcmstb-l2.c
+++ b/drivers/irqchip/irq-brcmstb-l2.c
@@ -18,7 +18,6 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
-#include <linux/kconfig.h>
 #include <linux/platform_device.h>
 #include <linux/spinlock.h>
 #include <linux/of.h>
diff --git a/drivers/media/dvb-frontends/af9013.h b/drivers/media/dvb-frontends/af9013.h
index 1dcc936..dcdd163 100644
--- a/drivers/media/dvb-frontends/af9013.h
+++ b/drivers/media/dvb-frontends/af9013.h
@@ -25,7 +25,6 @@
 #ifndef AF9013_H
 #define AF9013_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 /* AF9013/5 GPIOs (mostly guessed)
diff --git a/drivers/media/dvb-frontends/af9033.h b/drivers/media/dvb-frontends/af9033.h
index 6ad22b6..5b83e4f 100644
--- a/drivers/media/dvb-frontends/af9033.h
+++ b/drivers/media/dvb-frontends/af9033.h
@@ -22,8 +22,6 @@
 #ifndef AF9033_H
 #define AF9033_H
 
-#include <linux/kconfig.h>
-
 /*
  * I2C address (TODO: are these in 8-bit format?)
  * 0x38, 0x3a, 0x3c, 0x3e
diff --git a/drivers/media/dvb-frontends/ascot2e.h b/drivers/media/dvb-frontends/ascot2e.h
index 6da4ae6..dc61bf7 100644
--- a/drivers/media/dvb-frontends/ascot2e.h
+++ b/drivers/media/dvb-frontends/ascot2e.h
@@ -22,7 +22,6 @@
 #ifndef __DVB_ASCOT2E_H__
 #define __DVB_ASCOT2E_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/atbm8830.h b/drivers/media/dvb-frontends/atbm8830.h
index 5446d13..bb86238 100644
--- a/drivers/media/dvb-frontends/atbm8830.h
+++ b/drivers/media/dvb-frontends/atbm8830.h
@@ -22,7 +22,6 @@
 #ifndef __ATBM8830_H__
 #define __ATBM8830_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/au8522.h b/drivers/media/dvb-frontends/au8522.h
index 78bf3f7..21c51a4 100644
--- a/drivers/media/dvb-frontends/au8522.h
+++ b/drivers/media/dvb-frontends/au8522.h
@@ -22,7 +22,6 @@
 #ifndef __AU8522_H__
 #define __AU8522_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 enum au8522_if_freq {
diff --git a/drivers/media/dvb-frontends/cx22702.h b/drivers/media/dvb-frontends/cx22702.h
index 68b69a7..a1956a9 100644
--- a/drivers/media/dvb-frontends/cx22702.h
+++ b/drivers/media/dvb-frontends/cx22702.h
@@ -28,7 +28,6 @@
 #ifndef CX22702_H
 #define CX22702_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct cx22702_config {
diff --git a/drivers/media/dvb-frontends/cx24113.h b/drivers/media/dvb-frontends/cx24113.h
index 962919b..194c703 100644
--- a/drivers/media/dvb-frontends/cx24113.h
+++ b/drivers/media/dvb-frontends/cx24113.h
@@ -22,8 +22,6 @@
 #ifndef CX24113_H
 #define CX24113_H
 
-#include <linux/kconfig.h>
-
 struct dvb_frontend;
 
 struct cx24113_config {
diff --git a/drivers/media/dvb-frontends/cx24116.h b/drivers/media/dvb-frontends/cx24116.h
index f6dbabc..9ff8df8d 100644
--- a/drivers/media/dvb-frontends/cx24116.h
+++ b/drivers/media/dvb-frontends/cx24116.h
@@ -21,7 +21,6 @@
 #ifndef CX24116_H
 #define CX24116_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct cx24116_config {
diff --git a/drivers/media/dvb-frontends/cx24117.h b/drivers/media/dvb-frontends/cx24117.h
index 1648ab4..445f13f 100644
--- a/drivers/media/dvb-frontends/cx24117.h
+++ b/drivers/media/dvb-frontends/cx24117.h
@@ -22,7 +22,6 @@
 #ifndef CX24117_H
 #define CX24117_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct cx24117_config {
diff --git a/drivers/media/dvb-frontends/cx24120.h b/drivers/media/dvb-frontends/cx24120.h
index f097042..de4ca9a 100644
--- a/drivers/media/dvb-frontends/cx24120.h
+++ b/drivers/media/dvb-frontends/cx24120.h
@@ -20,7 +20,6 @@
 #ifndef CX24120_H
 #define CX24120_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/firmware.h>
 
diff --git a/drivers/media/dvb-frontends/cx24123.h b/drivers/media/dvb-frontends/cx24123.h
index 975f3c9..aac2344 100644
--- a/drivers/media/dvb-frontends/cx24123.h
+++ b/drivers/media/dvb-frontends/cx24123.h
@@ -21,7 +21,6 @@
 #ifndef CX24123_H
 #define CX24123_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct cx24123_config {
diff --git a/drivers/media/dvb-frontends/cxd2820r.h b/drivers/media/dvb-frontends/cxd2820r.h
index 56d4276..297a71a 100644
--- a/drivers/media/dvb-frontends/cxd2820r.h
+++ b/drivers/media/dvb-frontends/cxd2820r.h
@@ -22,7 +22,6 @@
 #ifndef CXD2820R_H
 #define CXD2820R_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 #define CXD2820R_GPIO_D (0 << 0) /* disable */
diff --git a/drivers/media/dvb-frontends/cxd2841er.h b/drivers/media/dvb-frontends/cxd2841er.h
index 62ad5f0..7f1acfb 100644
--- a/drivers/media/dvb-frontends/cxd2841er.h
+++ b/drivers/media/dvb-frontends/cxd2841er.h
@@ -22,7 +22,6 @@
 #ifndef CXD2841ER_H
 #define CXD2841ER_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 enum cxd2841er_xtal {
diff --git a/drivers/media/dvb-frontends/dib3000mc.h b/drivers/media/dvb-frontends/dib3000mc.h
index b37e69e..67a6d50 100644
--- a/drivers/media/dvb-frontends/dib3000mc.h
+++ b/drivers/media/dvb-frontends/dib3000mc.h
@@ -13,8 +13,6 @@
 #ifndef DIB3000MC_H
 #define DIB3000MC_H
 
-#include <linux/kconfig.h>
-
 #include "dibx000_common.h"
 
 struct dib3000mc_config {
diff --git a/drivers/media/dvb-frontends/dib7000m.h b/drivers/media/dvb-frontends/dib7000m.h
index 6468c27..8f84dfa 100644
--- a/drivers/media/dvb-frontends/dib7000m.h
+++ b/drivers/media/dvb-frontends/dib7000m.h
@@ -1,8 +1,6 @@
 #ifndef DIB7000M_H
 #define DIB7000M_H
 
-#include <linux/kconfig.h>
-
 #include "dibx000_common.h"
 
 struct dib7000m_config {
diff --git a/drivers/media/dvb-frontends/dib7000p.h b/drivers/media/dvb-frontends/dib7000p.h
index baa2789..205fbbf 100644
--- a/drivers/media/dvb-frontends/dib7000p.h
+++ b/drivers/media/dvb-frontends/dib7000p.h
@@ -1,8 +1,6 @@
 #ifndef DIB7000P_H
 #define DIB7000P_H
 
-#include <linux/kconfig.h>
-
 #include "dibx000_common.h"
 
 struct dib7000p_config {
diff --git a/drivers/media/dvb-frontends/drxd.h b/drivers/media/dvb-frontends/drxd.h
index a47c22d..f0507cd 100644
--- a/drivers/media/dvb-frontends/drxd.h
+++ b/drivers/media/dvb-frontends/drxd.h
@@ -24,7 +24,6 @@
 #ifndef _DRXD_H_
 #define _DRXD_H_
 
-#include <linux/kconfig.h>
 #include <linux/types.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/drxk.h b/drivers/media/dvb-frontends/drxk.h
index 8f0b9ee..a629897 100644
--- a/drivers/media/dvb-frontends/drxk.h
+++ b/drivers/media/dvb-frontends/drxk.h
@@ -1,7 +1,6 @@
 #ifndef _DRXK_H_
 #define _DRXK_H_
 
-#include <linux/kconfig.h>
 #include <linux/types.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/ds3000.h b/drivers/media/dvb-frontends/ds3000.h
index 153169d..82e8c25 100644
--- a/drivers/media/dvb-frontends/ds3000.h
+++ b/drivers/media/dvb-frontends/ds3000.h
@@ -22,7 +22,6 @@
 #ifndef DS3000_H
 #define DS3000_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct ds3000_config {
diff --git a/drivers/media/dvb-frontends/dvb_dummy_fe.h b/drivers/media/dvb-frontends/dvb_dummy_fe.h
index 15e4cea..50f1af5 100644
--- a/drivers/media/dvb-frontends/dvb_dummy_fe.h
+++ b/drivers/media/dvb-frontends/dvb_dummy_fe.h
@@ -22,7 +22,6 @@
 #ifndef DVB_DUMMY_FE_H
 #define DVB_DUMMY_FE_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/ec100.h b/drivers/media/dvb-frontends/ec100.h
index 9544bab..e894bdc 100644
--- a/drivers/media/dvb-frontends/ec100.h
+++ b/drivers/media/dvb-frontends/ec100.h
@@ -22,7 +22,6 @@
 #ifndef EC100_H
 #define EC100_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct ec100_config {
diff --git a/drivers/media/dvb-frontends/hd29l2.h b/drivers/media/dvb-frontends/hd29l2.h
index 48e9ab7..a14d6f3 100644
--- a/drivers/media/dvb-frontends/hd29l2.h
+++ b/drivers/media/dvb-frontends/hd29l2.h
@@ -23,7 +23,6 @@
 #ifndef HD29L2_H
 #define HD29L2_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct hd29l2_config {
diff --git a/drivers/media/dvb-frontends/helene.h b/drivers/media/dvb-frontends/helene.h
index e1b9224..3336154 100644
--- a/drivers/media/dvb-frontends/helene.h
+++ b/drivers/media/dvb-frontends/helene.h
@@ -21,7 +21,6 @@
 #ifndef __DVB_HELENE_H__
 #define __DVB_HELENE_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/horus3a.h b/drivers/media/dvb-frontends/horus3a.h
index c1e2d18..672a556 100644
--- a/drivers/media/dvb-frontends/horus3a.h
+++ b/drivers/media/dvb-frontends/horus3a.h
@@ -22,7 +22,6 @@
 #ifndef __DVB_HORUS3A_H__
 #define __DVB_HORUS3A_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/ix2505v.h b/drivers/media/dvb-frontends/ix2505v.h
index af107a2..5eab397 100644
--- a/drivers/media/dvb-frontends/ix2505v.h
+++ b/drivers/media/dvb-frontends/ix2505v.h
@@ -20,7 +20,6 @@
 #ifndef DVB_IX2505V_H
 #define DVB_IX2505V_H
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/lg2160.h b/drivers/media/dvb-frontends/lg2160.h
index d20bd90..8c74ddc 100644
--- a/drivers/media/dvb-frontends/lg2160.h
+++ b/drivers/media/dvb-frontends/lg2160.h
@@ -22,7 +22,6 @@
 #ifndef _LG2160_H_
 #define _LG2160_H_
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/lgdt3305.h b/drivers/media/dvb-frontends/lgdt3305.h
index f91a1b4..e7dceb6 100644
--- a/drivers/media/dvb-frontends/lgdt3305.h
+++ b/drivers/media/dvb-frontends/lgdt3305.h
@@ -22,7 +22,6 @@
 #ifndef _LGDT3305_H_
 #define _LGDT3305_H_
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/lgs8gl5.h b/drivers/media/dvb-frontends/lgs8gl5.h
index a5b3faf..f36a7fd 100644
--- a/drivers/media/dvb-frontends/lgs8gl5.h
+++ b/drivers/media/dvb-frontends/lgs8gl5.h
@@ -23,7 +23,6 @@
 #ifndef LGS8GL5_H
 #define LGS8GL5_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct lgs8gl5_config {
diff --git a/drivers/media/dvb-frontends/lgs8gxx.h b/drivers/media/dvb-frontends/lgs8gxx.h
index 368c992..7519c02 100644
--- a/drivers/media/dvb-frontends/lgs8gxx.h
+++ b/drivers/media/dvb-frontends/lgs8gxx.h
@@ -26,7 +26,6 @@
 #ifndef __LGS8GXX_H__
 #define __LGS8GXX_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/i2c.h>
 
diff --git a/drivers/media/dvb-frontends/lnbh24.h b/drivers/media/dvb-frontends/lnbh24.h
index a088b8e..24431df 100644
--- a/drivers/media/dvb-frontends/lnbh24.h
+++ b/drivers/media/dvb-frontends/lnbh24.h
@@ -23,8 +23,6 @@
 #ifndef _LNBH24_H
 #define _LNBH24_H
 
-#include <linux/kconfig.h>
-
 /* system register bits */
 #define LNBH24_OLF	0x01
 #define LNBH24_OTF	0x02
diff --git a/drivers/media/dvb-frontends/lnbh25.h b/drivers/media/dvb-frontends/lnbh25.h
index 1f329ef..f13fd03 100644
--- a/drivers/media/dvb-frontends/lnbh25.h
+++ b/drivers/media/dvb-frontends/lnbh25.h
@@ -22,7 +22,6 @@
 #define LNBH25_H
 
 #include <linux/i2c.h>
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 /* 22 kHz tone enabled. Tone output controlled by DSQIN pin */
diff --git a/drivers/media/dvb-frontends/lnbp21.h b/drivers/media/dvb-frontends/lnbp21.h
index cd9101f..4bb6439 100644
--- a/drivers/media/dvb-frontends/lnbp21.h
+++ b/drivers/media/dvb-frontends/lnbp21.h
@@ -27,8 +27,6 @@
 #ifndef _LNBP21_H
 #define _LNBP21_H
 
-#include <linux/kconfig.h>
-
 /* system register bits */
 /* [RO] 0=OK; 1=over current limit flag */
 #define LNBP21_OLF	0x01
diff --git a/drivers/media/dvb-frontends/lnbp22.h b/drivers/media/dvb-frontends/lnbp22.h
index 5d01d92..0cb7212 100644
--- a/drivers/media/dvb-frontends/lnbp22.h
+++ b/drivers/media/dvb-frontends/lnbp22.h
@@ -28,8 +28,6 @@
 #ifndef _LNBP22_H
 #define _LNBP22_H
 
-#include <linux/kconfig.h>
-
 /* Enable */
 #define LNBP22_EN	  0x10
 /* Voltage selection */
diff --git a/drivers/media/dvb-frontends/m88rs2000.h b/drivers/media/dvb-frontends/m88rs2000.h
index de74301..1a313b0 100644
--- a/drivers/media/dvb-frontends/m88rs2000.h
+++ b/drivers/media/dvb-frontends/m88rs2000.h
@@ -20,7 +20,6 @@
 #ifndef M88RS2000_H
 #define M88RS2000_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/mb86a20s.h b/drivers/media/dvb-frontends/mb86a20s.h
index a113282..dfb02db 100644
--- a/drivers/media/dvb-frontends/mb86a20s.h
+++ b/drivers/media/dvb-frontends/mb86a20s.h
@@ -16,7 +16,6 @@
 #ifndef MB86A20S_H
 #define MB86A20S_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 /**
diff --git a/drivers/media/dvb-frontends/s5h1409.h b/drivers/media/dvb-frontends/s5h1409.h
index f58b9ca..b38557c 100644
--- a/drivers/media/dvb-frontends/s5h1409.h
+++ b/drivers/media/dvb-frontends/s5h1409.h
@@ -22,7 +22,6 @@
 #ifndef __S5H1409_H__
 #define __S5H1409_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct s5h1409_config {
diff --git a/drivers/media/dvb-frontends/s5h1411.h b/drivers/media/dvb-frontends/s5h1411.h
index f3a87f7..791bab0 100644
--- a/drivers/media/dvb-frontends/s5h1411.h
+++ b/drivers/media/dvb-frontends/s5h1411.h
@@ -22,7 +22,6 @@
 #ifndef __S5H1411_H__
 #define __S5H1411_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 #define S5H1411_I2C_TOP_ADDR (0x32 >> 1)
diff --git a/drivers/media/dvb-frontends/s5h1432.h b/drivers/media/dvb-frontends/s5h1432.h
index f490c5e..b81c9bd 100644
--- a/drivers/media/dvb-frontends/s5h1432.h
+++ b/drivers/media/dvb-frontends/s5h1432.h
@@ -22,7 +22,6 @@
 #ifndef __S5H1432_H__
 #define __S5H1432_H__
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 #define S5H1432_I2C_TOP_ADDR (0x02 >> 1)
diff --git a/drivers/media/dvb-frontends/s921.h b/drivers/media/dvb-frontends/s921.h
index f5b722d..a47ed89 100644
--- a/drivers/media/dvb-frontends/s921.h
+++ b/drivers/media/dvb-frontends/s921.h
@@ -17,7 +17,6 @@
 #ifndef S921_H
 #define S921_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct s921_config {
diff --git a/drivers/media/dvb-frontends/si21xx.h b/drivers/media/dvb-frontends/si21xx.h
index ef5f351..b1be62f 100644
--- a/drivers/media/dvb-frontends/si21xx.h
+++ b/drivers/media/dvb-frontends/si21xx.h
@@ -1,7 +1,6 @@
 #ifndef SI21XX_H
 #define SI21XX_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/sp2.h b/drivers/media/dvb-frontends/sp2.h
index 6cceea0..3901cd7 100644
--- a/drivers/media/dvb-frontends/sp2.h
+++ b/drivers/media/dvb-frontends/sp2.h
@@ -17,7 +17,6 @@
 #ifndef SP2_H
 #define SP2_H
 
-#include <linux/kconfig.h>
 #include "dvb_ca_en50221.h"
 
 /*
diff --git a/drivers/media/dvb-frontends/stb6000.h b/drivers/media/dvb-frontends/stb6000.h
index da581b6..78e75df 100644
--- a/drivers/media/dvb-frontends/stb6000.h
+++ b/drivers/media/dvb-frontends/stb6000.h
@@ -23,7 +23,6 @@
 #ifndef __DVB_STB6000_H__
 #define __DVB_STB6000_H__
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/stv0288.h b/drivers/media/dvb-frontends/stv0288.h
index b58603c..803acb9 100644
--- a/drivers/media/dvb-frontends/stv0288.h
+++ b/drivers/media/dvb-frontends/stv0288.h
@@ -27,7 +27,6 @@
 #ifndef STV0288_H
 #define STV0288_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/stv0367.h b/drivers/media/dvb-frontends/stv0367.h
index 92b3e85..b88166a 100644
--- a/drivers/media/dvb-frontends/stv0367.h
+++ b/drivers/media/dvb-frontends/stv0367.h
@@ -26,7 +26,6 @@
 #ifndef STV0367_H
 #define STV0367_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/stv0900.h b/drivers/media/dvb-frontends/stv0900.h
index c90bf00..9ca2da9 100644
--- a/drivers/media/dvb-frontends/stv0900.h
+++ b/drivers/media/dvb-frontends/stv0900.h
@@ -26,7 +26,6 @@
 #ifndef STV0900_H
 #define STV0900_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/stv6110.h b/drivers/media/dvb-frontends/stv6110.h
index f3c8a5c..4604f79 100644
--- a/drivers/media/dvb-frontends/stv6110.h
+++ b/drivers/media/dvb-frontends/stv6110.h
@@ -25,7 +25,6 @@
 #ifndef __DVB_STV6110_H__
 #define __DVB_STV6110_H__
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/tda10048.h b/drivers/media/dvb-frontends/tda10048.h
index bc77a73..a2cebb0 100644
--- a/drivers/media/dvb-frontends/tda10048.h
+++ b/drivers/media/dvb-frontends/tda10048.h
@@ -22,7 +22,6 @@
 #ifndef TDA10048_H
 #define TDA10048_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 #include <linux/firmware.h>
 
diff --git a/drivers/media/dvb-frontends/tda18271c2dd.h b/drivers/media/dvb-frontends/tda18271c2dd.h
index 7ebd8ea..e6ccf24 100644
--- a/drivers/media/dvb-frontends/tda18271c2dd.h
+++ b/drivers/media/dvb-frontends/tda18271c2dd.h
@@ -1,8 +1,6 @@
 #ifndef _TDA18271C2DD_H_
 #define _TDA18271C2DD_H_
 
-#include <linux/kconfig.h>
-
 #if IS_REACHABLE(CONFIG_DVB_TDA18271C2DD)
 struct dvb_frontend *tda18271c2dd_attach(struct dvb_frontend *fe,
 					 struct i2c_adapter *i2c, u8 adr);
diff --git a/drivers/media/dvb-frontends/ts2020.h b/drivers/media/dvb-frontends/ts2020.h
index 9220e5c..facc54f 100644
--- a/drivers/media/dvb-frontends/ts2020.h
+++ b/drivers/media/dvb-frontends/ts2020.h
@@ -22,7 +22,6 @@
 #ifndef TS2020_H
 #define TS2020_H
 
-#include <linux/kconfig.h>
 #include <linux/dvb/frontend.h>
 
 struct ts2020_config {
diff --git a/drivers/media/dvb-frontends/zl10036.h b/drivers/media/dvb-frontends/zl10036.h
index 670e76a..c568d8d 100644
--- a/drivers/media/dvb-frontends/zl10036.h
+++ b/drivers/media/dvb-frontends/zl10036.h
@@ -21,7 +21,6 @@
 #ifndef DVB_ZL10036_H
 #define DVB_ZL10036_H
 
-#include <linux/kconfig.h>
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/dvb-frontends/zl10039.h b/drivers/media/dvb-frontends/zl10039.h
index 0709294..66e7085 100644
--- a/drivers/media/dvb-frontends/zl10039.h
+++ b/drivers/media/dvb-frontends/zl10039.h
@@ -22,8 +22,6 @@
 #ifndef ZL10039_H
 #define ZL10039_H
 
-#include <linux/kconfig.h>
-
 #if IS_REACHABLE(CONFIG_DVB_ZL10039)
 struct dvb_frontend *zl10039_attach(struct dvb_frontend *fe,
 					u8 i2c_addr,
diff --git a/drivers/media/pci/cx23885/altera-ci.h b/drivers/media/pci/cx23885/altera-ci.h
index 6c51172..57a40c8 100644
--- a/drivers/media/pci/cx23885/altera-ci.h
+++ b/drivers/media/pci/cx23885/altera-ci.h
@@ -20,8 +20,6 @@
 #ifndef __ALTERA_CI_H
 #define __ALTERA_CI_H
 
-#include <linux/kconfig.h>
-
 #define ALT_DATA	0x000000ff
 #define ALT_TDI		0x00008000
 #define ALT_TDO		0x00004000
diff --git a/drivers/media/tuners/fc0011.h b/drivers/media/tuners/fc0011.h
index 81bb568..438cf89 100644
--- a/drivers/media/tuners/fc0011.h
+++ b/drivers/media/tuners/fc0011.h
@@ -1,7 +1,6 @@
 #ifndef LINUX_FC0011_H_
 #define LINUX_FC0011_H_
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 
 
diff --git a/drivers/media/tuners/fc0012.h b/drivers/media/tuners/fc0012.h
index 9ad3285..4a23e41 100644
--- a/drivers/media/tuners/fc0012.h
+++ b/drivers/media/tuners/fc0012.h
@@ -21,7 +21,6 @@
 #ifndef _FC0012_H_
 #define _FC0012_H_
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 #include "fc001x-common.h"
 
diff --git a/drivers/media/tuners/fc0013.h b/drivers/media/tuners/fc0013.h
index e130bd7..8c34105 100644
--- a/drivers/media/tuners/fc0013.h
+++ b/drivers/media/tuners/fc0013.h
@@ -22,7 +22,6 @@
 #ifndef _FC0013_H_
 #define _FC0013_H_
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 #include "fc001x-common.h"
 
diff --git a/drivers/media/tuners/max2165.h b/drivers/media/tuners/max2165.h
index 5054f01..aadd9fe 100644
--- a/drivers/media/tuners/max2165.h
+++ b/drivers/media/tuners/max2165.h
@@ -22,8 +22,6 @@
 #ifndef __MAX2165_H__
 #define __MAX2165_H__
 
-#include <linux/kconfig.h>
-
 struct dvb_frontend;
 struct i2c_adapter;
 
diff --git a/drivers/media/tuners/mc44s803.h b/drivers/media/tuners/mc44s803.h
index b3e614b..6b40df3 100644
--- a/drivers/media/tuners/mc44s803.h
+++ b/drivers/media/tuners/mc44s803.h
@@ -22,8 +22,6 @@
 #ifndef MC44S803_H
 #define MC44S803_H
 
-#include <linux/kconfig.h>
-
 struct dvb_frontend;
 struct i2c_adapter;
 
diff --git a/drivers/media/tuners/mxl5005s.h b/drivers/media/tuners/mxl5005s.h
index 5764b12..d842734 100644
--- a/drivers/media/tuners/mxl5005s.h
+++ b/drivers/media/tuners/mxl5005s.h
@@ -23,8 +23,6 @@
 #ifndef __MXL5005S_H
 #define __MXL5005S_H
 
-#include <linux/kconfig.h>
-
 #include <linux/i2c.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/tuners/r820t.h b/drivers/media/tuners/r820t.h
index b1e5661..fdcab91 100644
--- a/drivers/media/tuners/r820t.h
+++ b/drivers/media/tuners/r820t.h
@@ -21,7 +21,6 @@
 #ifndef R820T_H
 #define R820T_H
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 
 enum r820t_chip {
diff --git a/drivers/media/tuners/si2157.h b/drivers/media/tuners/si2157.h
index 5f1a60b..76807f5 100644
--- a/drivers/media/tuners/si2157.h
+++ b/drivers/media/tuners/si2157.h
@@ -17,7 +17,6 @@
 #ifndef SI2157_H
 #define SI2157_H
 
-#include <linux/kconfig.h>
 #include <media/media-device.h>
 #include "dvb_frontend.h"
 
diff --git a/drivers/media/tuners/tda18212.h b/drivers/media/tuners/tda18212.h
index e58c909..6391daf 100644
--- a/drivers/media/tuners/tda18212.h
+++ b/drivers/media/tuners/tda18212.h
@@ -21,7 +21,6 @@
 #ifndef TDA18212_H
 #define TDA18212_H
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 
 struct tda18212_config {
diff --git a/drivers/media/tuners/tda18218.h b/drivers/media/tuners/tda18218.h
index 1eacb4f..076b5f2 100644
--- a/drivers/media/tuners/tda18218.h
+++ b/drivers/media/tuners/tda18218.h
@@ -21,7 +21,6 @@
 #ifndef TDA18218_H
 #define TDA18218_H
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 
 struct tda18218_config {
diff --git a/drivers/media/tuners/xc5000.h b/drivers/media/tuners/xc5000.h
index 00ba29e..336bd49 100644
--- a/drivers/media/tuners/xc5000.h
+++ b/drivers/media/tuners/xc5000.h
@@ -22,7 +22,6 @@
 #ifndef __XC5000_H__
 #define __XC5000_H__
 
-#include <linux/kconfig.h>
 #include <linux/firmware.h>
 
 struct dvb_frontend;
diff --git a/drivers/media/usb/dvb-usb-v2/mxl111sf-demod.h b/drivers/media/usb/dvb-usb-v2/mxl111sf-demod.h
index 7065aca..e6eae9d 100644
--- a/drivers/media/usb/dvb-usb-v2/mxl111sf-demod.h
+++ b/drivers/media/usb/dvb-usb-v2/mxl111sf-demod.h
@@ -21,7 +21,6 @@
 #ifndef __MXL111SF_DEMOD_H__
 #define __MXL111SF_DEMOD_H__
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 #include "mxl111sf.h"
 
diff --git a/drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.h b/drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.h
index 509b550..e96d9a4 100644
--- a/drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.h
+++ b/drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.h
@@ -21,7 +21,6 @@
 #ifndef __MXL111SF_TUNER_H__
 #define __MXL111SF_TUNER_H__
 
-#include <linux/kconfig.h>
 #include "dvb_frontend.h"
 #include "mxl111sf.h"
 
diff --git a/drivers/media/usb/dvb-usb/dibusb-common.c b/drivers/media/usb/dvb-usb/dibusb-common.c
index 6eea4e6..9e94b17 100644
--- a/drivers/media/usb/dvb-usb/dibusb-common.c
+++ b/drivers/media/usb/dvb-usb/dibusb-common.c
@@ -9,7 +9,6 @@
  * see Documentation/dvb/README.dvb-usb for more information
  */
 
-#include <linux/kconfig.h>
 #include "dibusb.h"
 
 /* Max transfer size done by I2C transfer functions */
diff --git a/drivers/media/usb/hdpvr/hdpvr-video.c b/drivers/media/usb/hdpvr/hdpvr-video.c
index 2a3a8b4..f3325b0 100644
--- a/drivers/media/usb/hdpvr/hdpvr-video.c
+++ b/drivers/media/usb/hdpvr/hdpvr-video.c
@@ -10,7 +10,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/kconfig.h>
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/slab.h>
diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index e3936b8..44da7b8 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -39,7 +39,6 @@
 #include <linux/gfp.h>
 #include <linux/slab.h>
 #include <linux/reboot.h>
-#include <linux/kconfig.h>
 #include <linux/leds.h>
 
 #include <linux/mtd/mtd.h>
diff --git a/drivers/mtd/mtdpart.c b/drivers/mtd/mtdpart.c
index 1f13e32..3f6034c 100644
--- a/drivers/mtd/mtdpart.c
+++ b/drivers/mtd/mtdpart.c
@@ -30,7 +30,6 @@
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
 #include <linux/err.h>
-#include <linux/kconfig.h>
 
 #include "mtdcore.h"
 
diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index 77ffc43..4432681 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/kconfig.h>
 #include <linux/module.h>
 #include <linux/io.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index e15bf84..0ac449a 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -11,7 +11,6 @@
 #include <linux/highmem.h>
 #include <linux/if_vlan.h>
 #include <linux/init.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 37ab46c..d2349a1 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -9,7 +9,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/kconfig.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 0b37ce9..ca31a57 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -10,7 +10,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/kconfig.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
diff --git a/drivers/usb/early/ehci-dbgp.c b/drivers/usb/early/ehci-dbgp.c
index 12731e6..ea73afb 100644
--- a/drivers/usb/early/ehci-dbgp.c
+++ b/drivers/usb/early/ehci-dbgp.c
@@ -20,7 +20,6 @@
 #include <linux/usb/ehci_def.h>
 #include <linux/delay.h>
 #include <linux/serial_core.h>
-#include <linux/kconfig.h>
 #include <linux/kgdb.h>
 #include <linux/kthread.h>
 #include <asm/io.h>
diff --git a/drivers/usb/gadget/udc/bcm63xx_udc.c b/drivers/usb/gadget/udc/bcm63xx_udc.c
index f5fccb3..f785032 100644
--- a/drivers/usb/gadget/udc/bcm63xx_udc.c
+++ b/drivers/usb/gadget/udc/bcm63xx_udc.c
@@ -21,7 +21,6 @@
 #include <linux/errno.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/module.h>
diff --git a/drivers/usb/host/pci-quirks.c b/drivers/usb/host/pci-quirks.c
index 35af362..d793f54 100644
--- a/drivers/usb/host/pci-quirks.c
+++ b/drivers/usb/host/pci-quirks.c
@@ -9,7 +9,6 @@
  */
 
 #include <linux/types.h>
-#include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
diff --git a/fs/lockd/procfs.h b/fs/lockd/procfs.h
index 2257a13..184a15e 100644
--- a/fs/lockd/procfs.h
+++ b/fs/lockd/procfs.h
@@ -6,8 +6,6 @@
 #ifndef _LOCKD_PROCFS_H
 #define _LOCKD_PROCFS_H
 
-#include <linux/kconfig.h>
-
 #if IS_ENABLED(CONFIG_PROC_FS)
 int lockd_create_procfs(void);
 void lockd_remove_procfs(void);
diff --git a/include/linux/export.h b/include/linux/export.h
index c565f87..d7df492 100644
--- a/include/linux/export.h
+++ b/include/linux/export.h
@@ -78,7 +78,6 @@ extern struct module __this_module;
 
 #elif defined(CONFIG_TRIM_UNUSED_KSYMS)
 
-#include <linux/kconfig.h>
 #include <generated/autoksyms.h>
 
 #define __EXPORT_SYMBOL(sym, sec)				\
diff --git a/include/linux/gpio/driver.h b/include/linux/gpio/driver.h
index 50882e0..073d9c5 100644
--- a/include/linux/gpio/driver.h
+++ b/include/linux/gpio/driver.h
@@ -9,7 +9,6 @@
 #include <linux/irqdomain.h>
 #include <linux/lockdep.h>
 #include <linux/pinctrl/pinctrl.h>
-#include <linux/kconfig.h>
 
 struct gpio_desc;
 struct of_phandle_args;
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 1ab4e2e6..992ec26 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -20,8 +20,6 @@
 
 #include "main.h"
 
-#include <linux/kconfig.h>
-
 struct net_device;
 
 #define BATADV_DEBUGFS_SUBDIR "batman_adv"
diff --git a/sound/soc/intel/common/sst-acpi.h b/sound/soc/intel/common/sst-acpi.h
index 5d29493..0127422 100644
--- a/sound/soc/intel/common/sst-acpi.h
+++ b/sound/soc/intel/common/sst-acpi.h
@@ -12,7 +12,6 @@
  *
  */
 
-#include <linux/kconfig.h>
 #include <linux/stddef.h>
 #include <linux/acpi.h>
 
diff --git a/tools/testing/nvdimm/config_check.c b/tools/testing/nvdimm/config_check.c
index 878daf3..7dc5a0a 100644
--- a/tools/testing/nvdimm/config_check.c
+++ b/tools/testing/nvdimm/config_check.c
@@ -1,4 +1,3 @@
-#include <linux/kconfig.h>
 #include <linux/bug.h>
 
 void check(void)
-- 
1.9.1


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
