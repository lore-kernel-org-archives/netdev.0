From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/2] remove asm/bitops.h includes
Date: Sat, 8 Sep 2007 15:59:10 -0400
Message-ID: <30483262301654323266@pripojeni.net>
Cc: <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from general-networks3.cust.sloane.cz ([88.146.176.14]:60715 "EHLO
	server.generalnetworks.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668AbXIHT7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 15:59:10 -0400
Cc: Adrian Bunk <bunk@kernel.org>
Cc: <netdev@vger.kernel.org>
Cc: <rth@twiddle.net>
Cc: <dhowells@redhat.com>
Cc: <linux-mips@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove asm/bitops.h includes

including asm/bitops directly may cause compile errors. don't include it
and include linux/bitops instead. next patch will deny including asm header
directly.

Cc: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 3c05eef3d0a98065323d7d6d9a78e0985eba4b10
tree cb9691832992f570b0363dd568f6fa3d2c81e3f5
parent 132bb039c741d00f066e7501e3613d2d20bf0595
author Jiri Slaby <jirislaby@gmail.com> Tue, 04 Sep 2007 21:01:35 +0200
committer Jiri Slaby <jirislaby@gmail.com> Tue, 04 Sep 2007 21:01:35 +0200

 arch/alpha/lib/fls.c                        |    2 +-
 arch/frv/kernel/irq-mb93091.c               |    2 +-
 arch/frv/kernel/irq-mb93093.c               |    2 +-
 arch/frv/kernel/irq-mb93493.c               |    2 +-
 arch/frv/kernel/irq.c                       |    2 +-
 arch/mips/au1000/pb1200/irqmap.c            |    2 +-
 arch/mips/basler/excite/excite_irq.c        |    2 +-
 arch/mips/gt64120/wrppmc/irq.c              |    1 -
 arch/mips/tx4938/common/setup.c             |    2 +-
 arch/powerpc/platforms/maple/setup.c        |    2 +-
 drivers/char/esp.c                          |    2 +-
 drivers/char/mxser.c                        |    2 +-
 drivers/char/mxser_new.c                    |    2 +-
 drivers/ide/ide-io.c                        |    2 +-
 drivers/media/dvb/ttpci/av7110_ir.c         |    2 +-
 drivers/net/bnx2.c                          |    2 +-
 drivers/net/cris/eth_v10.c                  |    2 +-
 drivers/net/cxgb3/adapter.h                 |    2 +-
 drivers/net/hamradio/dmascc.c               |    2 +-
 drivers/net/mac89x0.c                       |    2 +-
 drivers/net/spider_net.c                    |    2 +-
 drivers/net/tulip/uli526x.c                 |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c |    2 +-
 drivers/pcmcia/m32r_pcc.c                   |    2 +-
 drivers/pcmcia/m8xx_pcmcia.c                |    2 +-
 drivers/ps3/vuart.c                         |    2 +-
 drivers/rtc/rtc-pl031.c                     |    2 +-
 drivers/rtc/rtc-sa1100.c                    |    2 +-
 drivers/s390/cio/idset.c                    |    2 +-
 drivers/s390/net/claw.c                     |    2 +-
 drivers/scsi/ide-scsi.c                     |    2 +-
 drivers/serial/crisv10.c                    |    2 +-
 drivers/watchdog/at91rm9200_wdt.c           |    2 +-
 drivers/watchdog/ks8695_wdt.c               |    2 +-
 drivers/watchdog/omap_wdt.c                 |    2 +-
 drivers/watchdog/sa1100_wdt.c               |    2 +-
 fs/reiser4/jnode.h                          |    2 +-
 fs/reiser4/plugin/space/bitmap.c            |    2 +-
 include/asm-cris/posix_types.h              |    2 +-
 include/asm-i386/pgtable.h                  |    5 +----
 include/asm-i386/smp.h                      |    2 +-
 include/asm-ia64/cacheflush.h               |    2 +-
 include/asm-ia64/pgtable.h                  |    2 +-
 include/asm-ia64/smp.h                      |    2 +-
 include/asm-ia64/spinlock.h                 |    2 +-
 include/asm-m32r/pgtable.h                  |    2 +-
 include/asm-mips/fpu.h                      |    2 +-
 include/asm-parisc/pgtable.h                |    2 +-
 include/asm-powerpc/iommu.h                 |    2 +-
 include/asm-powerpc/mmu_context.h           |    2 +-
 include/asm-ppc/mmu_context.h               |    3 ++-
 include/asm-sparc64/smp.h                   |    2 +-
 include/asm-x86_64/pgtable.h                |    2 +-
 include/asm-x86_64/topology.h               |    2 +-
 include/linux/of.h                          |    2 +-
 lib/hweight.c                               |    2 +-
 net/core/gen_estimator.c                    |    2 +-
 net/core/pktgen.c                           |    2 +-
 net/ipv4/fib_trie.c                         |    2 +-
 net/netfilter/xt_connbytes.c                |    2 +-
 60 files changed, 60 insertions(+), 63 deletions(-)

diff --git a/arch/alpha/lib/fls.c b/arch/alpha/lib/fls.c
index 7ad84ea..32afaa3 100644
--- a/arch/alpha/lib/fls.c
+++ b/arch/alpha/lib/fls.c
@@ -3,7 +3,7 @@
  */
 
 #include <linux/module.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 /* This is fls(x)-1, except zero is held to zero.  This allows most
    efficent input into extbl, plus it allows easy handling of fls(0)=0.  */
diff --git a/arch/frv/kernel/irq-mb93091.c b/arch/frv/kernel/irq-mb93091.c
index ad753c1..9e38f99 100644
--- a/arch/frv/kernel/irq-mb93091.c
+++ b/arch/frv/kernel/irq-mb93091.c
@@ -17,10 +17,10 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/irq.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/delay.h>
 #include <asm/irq.h>
 #include <asm/irc-regs.h>
diff --git a/arch/frv/kernel/irq-mb93093.c b/arch/frv/kernel/irq-mb93093.c
index e0983f6..3c2752c 100644
--- a/arch/frv/kernel/irq-mb93093.c
+++ b/arch/frv/kernel/irq-mb93093.c
@@ -17,10 +17,10 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/irq.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/delay.h>
 #include <asm/irq.h>
 #include <asm/irc-regs.h>
diff --git a/arch/frv/kernel/irq-mb93493.c b/arch/frv/kernel/irq-mb93493.c
index c157eef..7754c73 100644
--- a/arch/frv/kernel/irq-mb93493.c
+++ b/arch/frv/kernel/irq-mb93493.c
@@ -17,10 +17,10 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/irq.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/delay.h>
 #include <asm/irq.h>
 #include <asm/irc-regs.h>
diff --git a/arch/frv/kernel/irq.c b/arch/frv/kernel/irq.c
index c7e59dc..7ddb690 100644
--- a/arch/frv/kernel/irq.c
+++ b/arch/frv/kernel/irq.c
@@ -24,12 +24,12 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/module.h>
+#include <linux/bitops.h>
 
 #include <asm/atomic.h>
 #include <asm/io.h>
 #include <asm/smp.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <asm/delay.h>
diff --git a/arch/mips/au1000/pb1200/irqmap.c b/arch/mips/au1000/pb1200/irqmap.c
index b73b2d1..e5cd0da 100644
--- a/arch/mips/au1000/pb1200/irqmap.c
+++ b/arch/mips/au1000/pb1200/irqmap.c
@@ -36,8 +36,8 @@
 #include <linux/slab.h>
 #include <linux/random.h>
 #include <linux/delay.h>
+#include <linux/bitops.h>
 
-#include <asm/bitops.h>
 #include <asm/bootinfo.h>
 #include <asm/io.h>
 #include <asm/mipsregs.h>
diff --git a/arch/mips/basler/excite/excite_irq.c b/arch/mips/basler/excite/excite_irq.c
index 94ce5d4..934e0a6 100644
--- a/arch/mips/basler/excite/excite_irq.c
+++ b/arch/mips/basler/excite/excite_irq.c
@@ -29,7 +29,7 @@
 #include <linux/timex.h>
 #include <linux/slab.h>
 #include <linux/random.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/bootinfo.h>
 #include <asm/io.h>
 #include <asm/irq.h>
diff --git a/arch/mips/gt64120/wrppmc/irq.c b/arch/mips/gt64120/wrppmc/irq.c
index 06177bf..6f30572 100644
--- a/arch/mips/gt64120/wrppmc/irq.c
+++ b/arch/mips/gt64120/wrppmc/irq.c
@@ -24,7 +24,6 @@
 #include <linux/bitops.h>
 #include <asm/bootinfo.h>
 #include <asm/io.h>
-#include <asm/bitops.h>
 #include <asm/mipsregs.h>
 #include <asm/system.h>
 #include <asm/irq_cpu.h>
diff --git a/arch/mips/tx4938/common/setup.c b/arch/mips/tx4938/common/setup.c
index 142abf4..f252a7c 100644
--- a/arch/mips/tx4938/common/setup.c
+++ b/arch/mips/tx4938/common/setup.c
@@ -24,7 +24,7 @@
 #include <linux/slab.h>
 #include <linux/random.h>
 #include <linux/irq.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/bootinfo.h>
 #include <asm/io.h>
 #include <asm/irq.h>
diff --git a/arch/powerpc/platforms/maple/setup.c b/arch/powerpc/platforms/maple/setup.c
index 354c058..144177d 100644
--- a/arch/powerpc/platforms/maple/setup.c
+++ b/arch/powerpc/platforms/maple/setup.c
@@ -41,13 +41,13 @@
 #include <linux/root_dev.h>
 #include <linux/serial.h>
 #include <linux/smp.h>
+#include <linux/bitops.h>
 
 #include <asm/processor.h>
 #include <asm/sections.h>
 #include <asm/prom.h>
 #include <asm/system.h>
 #include <asm/pgtable.h>
-#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/kexec.h>
 #include <asm/pci-bridge.h>
diff --git a/drivers/char/esp.c b/drivers/char/esp.c
index 2e7ae42..0f8fb13 100644
--- a/drivers/char/esp.c
+++ b/drivers/char/esp.c
@@ -58,10 +58,10 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/bitops.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
-#include <asm/bitops.h>
 
 #include <asm/dma.h>
 #include <linux/slab.h>
diff --git a/drivers/char/mxser.c b/drivers/char/mxser.c
index a24738e..dfacb66 100644
--- a/drivers/char/mxser.c
+++ b/drivers/char/mxser.c
@@ -56,11 +56,11 @@
 #include <linux/mm.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
+#include <linux/bitops.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 
 #include "mxser.h"
diff --git a/drivers/char/mxser_new.c b/drivers/char/mxser_new.c
index 854dbf5..081c84c 100644
--- a/drivers/char/mxser_new.c
+++ b/drivers/char/mxser_new.c
@@ -39,11 +39,11 @@
 #include <linux/mm.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
+#include <linux/bitops.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 
 #include "mxser_new.h"
diff --git a/drivers/ide/ide-io.c b/drivers/ide/ide-io.c
index c1692d9..14b8ab0 100644
--- a/drivers/ide/ide-io.c
+++ b/drivers/ide/ide-io.c
@@ -47,12 +47,12 @@
 #include <linux/device.h>
 #include <linux/kmod.h>
 #include <linux/scatterlist.h>
+#include <linux/bitops.h>
 
 #include <asm/byteorder.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
-#include <asm/bitops.h>
 
 static int __ide_end_request(ide_drive_t *drive, struct request *rq,
 			     int uptodate, unsigned int nr_bytes)
diff --git a/drivers/media/dvb/ttpci/av7110_ir.c b/drivers/media/dvb/ttpci/av7110_ir.c
index e8f5537..57212f6 100644
--- a/drivers/media/dvb/ttpci/av7110_ir.c
+++ b/drivers/media/dvb/ttpci/av7110_ir.c
@@ -27,7 +27,7 @@
 #include <linux/module.h>
 #include <linux/proc_fs.h>
 #include <linux/kernel.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 #include "av7110.h"
 #include "av7110_hw.h"
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b2139c0..38c12f2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -26,7 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <linux/delay.h>
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 5bdf5ca..427cd1b 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -234,6 +234,7 @@
 #include <linux/spinlock.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/bitops.h>
 
 #include <linux/if.h>
 #include <linux/mii.h>
@@ -247,7 +248,6 @@
 #include <asm/irq.h>
 #include <asm/dma.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/ethernet.h>
 #include <asm/cache.h>
 
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index e723e7b..f7b3a3f 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -41,9 +41,9 @@
 #include <linux/timer.h>
 #include <linux/cache.h>
 #include <linux/mutex.h>
+#include <linux/bitops.h>
 #include "t3cdev.h"
 #include <asm/semaphore.h>
-#include <asm/bitops.h>
 #include <asm/io.h>
 
 typedef irqreturn_t(*intr_handler_t) (int, void *);
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 205f096..db20685 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -21,6 +21,7 @@
 
 
 #include <linux/module.h>
+#include <linux/bitops.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
@@ -35,7 +36,6 @@
 #include <linux/sockios.h>
 #include <linux/workqueue.h>
 #include <asm/atomic.h>
-#include <asm/bitops.h>
 #include <asm/dma.h>
 #include <asm/io.h>
 #include <asm/irq.h>
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 62c1c62..1858d92 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -99,9 +99,9 @@ static char *version =
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
+#include <linux/bitops.h>
 
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/hwtest.h>
 #include <asm/macints.h>
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index a144327..ce08ba2 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -46,7 +46,7 @@
 #include <linux/vmalloc.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/pci-bridge.h>
 #include <net/checksum.h>
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 77a1bfb..6f6a667 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -34,9 +34,9 @@
 #include <linux/delay.h>
 #include <linux/spinlock.h>
 #include <linux/dma-mapping.h>
+#include <linux/bitops.h>
 
 #include <asm/processor.h>
-#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index 8f198be..cb51dc5 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -29,7 +29,7 @@
 #include "bcm43xx_radio.h"
 #include "bcm43xx.h"
 
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 
 static void bcm43xx_led_changestate(struct bcm43xx_led *led)
diff --git a/drivers/pcmcia/m32r_pcc.c b/drivers/pcmcia/m32r_pcc.c
index 67d28ee..c5e0d89 100644
--- a/drivers/pcmcia/m32r_pcc.c
+++ b/drivers/pcmcia/m32r_pcc.c
@@ -22,9 +22,9 @@
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/platform_device.h>
+#include <linux/bitops.h>
 #include <asm/irq.h>
 #include <asm/io.h>
-#include <asm/bitops.h>
 #include <asm/system.h>
 #include <asm/addrspace.h>
 
diff --git a/drivers/pcmcia/m8xx_pcmcia.c b/drivers/pcmcia/m8xx_pcmcia.c
index b019854..d182760 100644
--- a/drivers/pcmcia/m8xx_pcmcia.c
+++ b/drivers/pcmcia/m8xx_pcmcia.c
@@ -48,9 +48,9 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/fsl_devices.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
-#include <asm/bitops.h>
 #include <asm/system.h>
 #include <asm/time.h>
 #include <asm/mpc8xx.h>
diff --git a/drivers/ps3/vuart.c b/drivers/ps3/vuart.c
index bea25a1..9dea585 100644
--- a/drivers/ps3/vuart.c
+++ b/drivers/ps3/vuart.c
@@ -22,11 +22,11 @@
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/workqueue.h>
+#include <linux/bitops.h>
 #include <asm/ps3.h>
 
 #include <asm/firmware.h>
 #include <asm/lv1call.h>
-#include <asm/bitops.h>
 
 #include "vuart.h"
 
diff --git a/drivers/rtc/rtc-pl031.c b/drivers/rtc/rtc-pl031.c
index e4bf68c..2fd49ed 100644
--- a/drivers/rtc/rtc-pl031.c
+++ b/drivers/rtc/rtc-pl031.c
@@ -21,11 +21,11 @@
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pm.h>
+#include <linux/bitops.h>
 
 #include <linux/amba/bus.h>
 
 #include <asm/io.h>
-#include <asm/bitops.h>
 #include <asm/hardware.h>
 #include <asm/irq.h>
 #include <asm/rtc.h>
diff --git a/drivers/rtc/rtc-sa1100.c b/drivers/rtc/rtc-sa1100.c
index 0918b78..6f1e9a9 100644
--- a/drivers/rtc/rtc-sa1100.c
+++ b/drivers/rtc/rtc-sa1100.c
@@ -29,8 +29,8 @@
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pm.h>
+#include <linux/bitops.h>
 
-#include <asm/bitops.h>
 #include <asm/hardware.h>
 #include <asm/irq.h>
 #include <asm/rtc.h>
diff --git a/drivers/s390/cio/idset.c b/drivers/s390/cio/idset.c
index 16ea828..ef7bc0a 100644
--- a/drivers/s390/cio/idset.c
+++ b/drivers/s390/cio/idset.c
@@ -6,7 +6,7 @@
  */
 
 #include <linux/slab.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include "idset.h"
 #include "css.h"
 
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 023455a..cea28a4 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -59,13 +59,13 @@
  *    1.15  Changed for 2.6 Kernel  No longer compiles on 2.4 or lower
  *    1.25  Added Packing support
  */
-#include <asm/bitops.h>
 #include <asm/ccwdev.h>
 #include <asm/ccwgroup.h>
 #include <asm/debug.h>
 #include <asm/idals.h>
 #include <asm/io.h>
 
+#include <linux/bitops.h>
 #include <linux/ctype.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
diff --git a/drivers/scsi/ide-scsi.c b/drivers/scsi/ide-scsi.c
index c05b291..948a7fc 100644
--- a/drivers/scsi/ide-scsi.c
+++ b/drivers/scsi/ide-scsi.c
@@ -47,9 +47,9 @@
 #include <linux/scatterlist.h>
 #include <linux/delay.h>
 #include <linux/mutex.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 
 #include <scsi/scsi.h>
diff --git a/drivers/serial/crisv10.c b/drivers/serial/crisv10.c
index 312bef6..1e9a35a 100644
--- a/drivers/serial/crisv10.c
+++ b/drivers/serial/crisv10.c
@@ -442,11 +442,11 @@ static char *serial_version = "$Revision: 1.25 $";
 #include <asm/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/mutex.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
 #include <linux/delay.h>
 
 #include <asm/arch/svinto.h>
diff --git a/drivers/watchdog/at91rm9200_wdt.c b/drivers/watchdog/at91rm9200_wdt.c
index 38bd373..a684b1e 100644
--- a/drivers/watchdog/at91rm9200_wdt.c
+++ b/drivers/watchdog/at91rm9200_wdt.c
@@ -9,6 +9,7 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/bitops.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/init.h>
@@ -19,7 +20,6 @@
 #include <linux/platform_device.h>
 #include <linux/types.h>
 #include <linux/watchdog.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 #include <asm/arch/at91_st.h>
 
diff --git a/drivers/watchdog/ks8695_wdt.c b/drivers/watchdog/ks8695_wdt.c
index 7150fb9..e3a29c3 100644
--- a/drivers/watchdog/ks8695_wdt.c
+++ b/drivers/watchdog/ks8695_wdt.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/bitops.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/init.h>
@@ -18,7 +19,6 @@
 #include <linux/platform_device.h>
 #include <linux/types.h>
 #include <linux/watchdog.h>
-#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <asm/arch/regs-timer.h>
diff --git a/drivers/watchdog/omap_wdt.c b/drivers/watchdog/omap_wdt.c
index 719b066..635ca45 100644
--- a/drivers/watchdog/omap_wdt.c
+++ b/drivers/watchdog/omap_wdt.c
@@ -39,11 +39,11 @@
 #include <linux/platform_device.h>
 #include <linux/moduleparam.h>
 #include <linux/clk.h>
+#include <linux/bitops.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <asm/hardware.h>
-#include <asm/bitops.h>
 
 #include <asm/arch/prcm.h>
 
diff --git a/drivers/watchdog/sa1100_wdt.c b/drivers/watchdog/sa1100_wdt.c
index 3475f47..34a2b3b 100644
--- a/drivers/watchdog/sa1100_wdt.c
+++ b/drivers/watchdog/sa1100_wdt.c
@@ -25,13 +25,13 @@
 #include <linux/miscdevice.h>
 #include <linux/watchdog.h>
 #include <linux/init.h>
+#include <linux/bitops.h>
 
 #ifdef CONFIG_ARCH_PXA
 #include <asm/arch/pxa-regs.h>
 #endif
 
 #include <asm/hardware.h>
-#include <asm/bitops.h>
 #include <asm/uaccess.h>
 
 #define OSCR_FREQ		CLOCK_TICK_RATE
diff --git a/fs/reiser4/jnode.h b/fs/reiser4/jnode.h
index 59b29de..97a8438 100644
--- a/fs/reiser4/jnode.h
+++ b/fs/reiser4/jnode.h
@@ -21,7 +21,7 @@
 #include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <linux/list.h>
 #include <linux/rcupdate.h>
 
diff --git a/fs/reiser4/plugin/space/bitmap.c b/fs/reiser4/plugin/space/bitmap.c
index a0ff17a..e2ae346 100644
--- a/fs/reiser4/plugin/space/bitmap.c
+++ b/fs/reiser4/plugin/space/bitmap.c
@@ -171,7 +171,7 @@ static int find_next_zero_bit_in_word(ulong_t word, int start_bit)
 	return i;
 }
 
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 #if BITS_PER_LONG == 64
 
diff --git a/include/asm-cris/posix_types.h b/include/asm-cris/posix_types.h
index 7b9ed22..92000d0 100644
--- a/include/asm-cris/posix_types.h
+++ b/include/asm-cris/posix_types.h
@@ -52,7 +52,7 @@ typedef struct {
 } __kernel_fsid_t;
 
 #ifdef __KERNEL__
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 #undef	__FD_SET
 #define __FD_SET(fd,fdsetp) set_bit(fd, (void *)(fdsetp))
diff --git a/include/asm-i386/pgtable.h b/include/asm-i386/pgtable.h
index ae8d9c2..ee53ccd 100644
--- a/include/asm-i386/pgtable.h
+++ b/include/asm-i386/pgtable.h
@@ -17,10 +17,7 @@
 #include <linux/threads.h>
 #include <asm/paravirt.h>
 
-#ifndef _I386_BITOPS_H
-#include <asm/bitops.h>
-#endif
-
+#include <linux/bitops.h>
 #include <linux/slab.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
diff --git a/include/asm-i386/smp.h b/include/asm-i386/smp.h
index 6e1e327..e10b7af 100644
--- a/include/asm-i386/smp.h
+++ b/include/asm-i386/smp.h
@@ -11,7 +11,7 @@
 #endif
 
 #if defined(CONFIG_X86_LOCAL_APIC) && !defined(__ASSEMBLY__)
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/mpspec.h>
 #include <asm/apic.h>
 #ifdef CONFIG_X86_IO_APIC
diff --git a/include/asm-ia64/cacheflush.h b/include/asm-ia64/cacheflush.h
index 4906916..afcfbda 100644
--- a/include/asm-ia64/cacheflush.h
+++ b/include/asm-ia64/cacheflush.h
@@ -7,8 +7,8 @@
  */
 
 #include <linux/page-flags.h>
+#include <linux/bitops.h>
 
-#include <asm/bitops.h>
 #include <asm/page.h>
 
 /*
diff --git a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
index 0971ec9..e6204f1 100644
--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -150,7 +150,7 @@
 # ifndef __ASSEMBLY__
 
 #include <linux/sched.h>	/* for mm_struct */
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
index 6314b29..8f1e858 100644
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -14,8 +14,8 @@
 #include <linux/threads.h>
 #include <linux/kernel.h>
 #include <linux/cpumask.h>
+#include <linux/bitops.h>
 
-#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/param.h>
 #include <asm/processor.h>
diff --git a/include/asm-ia64/spinlock.h b/include/asm-ia64/spinlock.h
index ff857e3..0229fb9 100644
--- a/include/asm-ia64/spinlock.h
+++ b/include/asm-ia64/spinlock.h
@@ -11,9 +11,9 @@
 
 #include <linux/compiler.h>
 #include <linux/kernel.h>
+#include <linux/bitops.h>
 
 #include <asm/atomic.h>
-#include <asm/bitops.h>
 #include <asm/intrinsics.h>
 #include <asm/system.h>
 
diff --git a/include/asm-m32r/pgtable.h b/include/asm-m32r/pgtable.h
index 92d7266..8650538 100644
--- a/include/asm-m32r/pgtable.h
+++ b/include/asm-m32r/pgtable.h
@@ -21,9 +21,9 @@
 #ifndef __ASSEMBLY__
 
 #include <linux/threads.h>
+#include <linux/bitops.h>
 #include <asm/processor.h>
 #include <asm/addrspace.h>
-#include <asm/bitops.h>
 #include <asm/page.h>
 
 struct mm_struct;
diff --git a/include/asm-mips/fpu.h b/include/asm-mips/fpu.h
index 483685b..e59d4c0 100644
--- a/include/asm-mips/fpu.h
+++ b/include/asm-mips/fpu.h
@@ -12,12 +12,12 @@
 
 #include <linux/sched.h>
 #include <linux/thread_info.h>
+#include <linux/bitops.h>
 
 #include <asm/mipsregs.h>
 #include <asm/cpu.h>
 #include <asm/cpu-features.h>
 #include <asm/hazards.h>
-#include <asm/bitops.h>
 #include <asm/processor.h>
 #include <asm/current.h>
 
diff --git a/include/asm-parisc/pgtable.h b/include/asm-parisc/pgtable.h
index 33ed0e7..3267ed0 100644
--- a/include/asm-parisc/pgtable.h
+++ b/include/asm-parisc/pgtable.h
@@ -11,9 +11,9 @@
  */
 
 #include <linux/mm.h>		/* for vm_area_struct */
+#include <linux/bitops.h>
 #include <asm/processor.h>
 #include <asm/cache.h>
-#include <asm/bitops.h>
 
 /*
  * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
diff --git a/include/asm-powerpc/iommu.h b/include/asm-powerpc/iommu.h
index 870967e..4a82fdc 100644
--- a/include/asm-powerpc/iommu.h
+++ b/include/asm-powerpc/iommu.h
@@ -26,9 +26,9 @@
 #include <linux/spinlock.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
+#include <linux/bitops.h>
 #include <asm/machdep.h>
 #include <asm/types.h>
-#include <asm/bitops.h>
 
 #define IOMMU_PAGE_SHIFT      12
 #define IOMMU_PAGE_SIZE       (ASM_CONST(1) << IOMMU_PAGE_SHIFT)
diff --git a/include/asm-powerpc/mmu_context.h b/include/asm-powerpc/mmu_context.h
index f863ac2..9102b8b 100644
--- a/include/asm-powerpc/mmu_context.h
+++ b/include/asm-powerpc/mmu_context.h
@@ -8,7 +8,7 @@
 
 #ifndef CONFIG_PPC64
 #include <asm/atomic.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 /*
  * On 32-bit PowerPC 6xx/7xx/7xxx CPUs, we use a set of 16 VSIDs
diff --git a/include/asm-ppc/mmu_context.h b/include/asm-ppc/mmu_context.h
index a6441a0..b2e25d8 100644
--- a/include/asm-ppc/mmu_context.h
+++ b/include/asm-ppc/mmu_context.h
@@ -2,8 +2,9 @@
 #ifndef __PPC_MMU_CONTEXT_H
 #define __PPC_MMU_CONTEXT_H
 
+#include <linux/bitops.h>
+
 #include <asm/atomic.h>
-#include <asm/bitops.h>
 #include <asm/mmu.h>
 #include <asm/cputable.h>
 #include <asm-generic/mm_hooks.h>
diff --git a/include/asm-sparc64/smp.h b/include/asm-sparc64/smp.h
index e8a96a3..60f67fe 100644
--- a/include/asm-sparc64/smp.h
+++ b/include/asm-sparc64/smp.h
@@ -26,7 +26,7 @@
  *	Private routines/data
  */
  
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/atomic.h>
 
 extern cpumask_t cpu_sibling_map[NR_CPUS];
diff --git a/include/asm-x86_64/pgtable.h b/include/asm-x86_64/pgtable.h
index 0bea3e7..da31726 100644
--- a/include/asm-x86_64/pgtable.h
+++ b/include/asm-x86_64/pgtable.h
@@ -9,7 +9,7 @@
  * the x86-64 page table tree.
  */
 #include <asm/processor.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <linux/threads.h>
 #include <asm/pda.h>
 
diff --git a/include/asm-x86_64/topology.h b/include/asm-x86_64/topology.h
index 24e9bce..ca33dc8 100644
--- a/include/asm-x86_64/topology.h
+++ b/include/asm-x86_64/topology.h
@@ -5,7 +5,7 @@
 #ifdef CONFIG_NUMA
 
 #include <asm/mpspec.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 
 extern cpumask_t cpu_online_map;
 
diff --git a/include/linux/of.h b/include/linux/of.h
index 6df80e9..5c39b92 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -16,8 +16,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 #include <linux/types.h>
+#include <linux/bitops.h>
 
-#include <asm/bitops.h>
 #include <asm/prom.h>
 
 /* flag descriptions */
diff --git a/lib/hweight.c b/lib/hweight.c
index 360556a..389424e 100644
--- a/lib/hweight.c
+++ b/lib/hweight.c
@@ -1,6 +1,6 @@
 #include <linux/module.h>
+#include <linux/bitops.h>
 #include <asm/types.h>
-#include <asm/bitops.h>
 
 /**
  * hweightN - returns the hamming weight of a N-bit word
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 590a767..daadbcc 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -15,7 +15,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 91bdacb..65f2ac0 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -157,7 +157,7 @@
 #endif
 #include <asm/byteorder.h>
 #include <linux/rcupdate.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 52b2891..13ca0e3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -54,7 +54,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index dd4d79b..0601aea 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -2,13 +2,13 @@
  * GPL (C) 2002 Martin Devera (devik@cdi.cz).
  */
 #include <linux/module.h>
+#include <linux/bitops.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_connbytes.h>
 #include <net/netfilter/nf_conntrack.h>
 
 #include <asm/div64.h>
-#include <asm/bitops.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
