From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 53/73] drivers/isdn: delete non-required instances of include <linux/init.h>
Date: Tue, 21 Jan 2014 16:22:56 -0500
Message-ID: <1390339396-3479-54-git-send-email-paul.gortmaker@windriver.com>
References: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arch@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	Armin Schindler <mac@melware.de>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

None of these files are actually using any __init type directives
and hence don't need to include <linux/init.h>.  Most are just a
left over from __devinit and __cpuinit removal, or simply due to
code getting copied from one driver to the next.

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Armin Schindler <mac@melware.de> (maintainer:ISDN SUBSYSTEM
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/isdn/hardware/avm/avm_cs.c     | 1 -
 drivers/isdn/hardware/eicon/platform.h | 1 -
 drivers/isdn/hisax/amd7930_fn.c        | 1 -
 drivers/isdn/hisax/asuscom.c           | 1 -
 drivers/isdn/hisax/avm_a1.c            | 1 -
 drivers/isdn/hisax/avm_a1p.c           | 1 -
 drivers/isdn/hisax/avma1_cs.c          | 1 -
 drivers/isdn/hisax/bkm_a4t.c           | 1 -
 drivers/isdn/hisax/bkm_a8.c            | 1 -
 drivers/isdn/hisax/diva.c              | 1 -
 drivers/isdn/hisax/elsa.c              | 1 -
 drivers/isdn/hisax/elsa_cs.c           | 1 -
 drivers/isdn/hisax/enternow_pci.c      | 1 -
 drivers/isdn/hisax/fsm.c               | 1 -
 drivers/isdn/hisax/gazel.c             | 1 -
 drivers/isdn/hisax/hfc_2bds0.c         | 1 -
 drivers/isdn/hisax/hfc_2bs0.c          | 1 -
 drivers/isdn/hisax/hfc_pci.c           | 1 -
 drivers/isdn/hisax/hfc_sx.c            | 1 -
 drivers/isdn/hisax/hfcscard.c          | 1 -
 drivers/isdn/hisax/hscx.c              | 1 -
 drivers/isdn/hisax/icc.c               | 1 -
 drivers/isdn/hisax/ipacx.c             | 1 -
 drivers/isdn/hisax/isac.c              | 1 -
 drivers/isdn/hisax/isar.c              | 1 -
 drivers/isdn/hisax/isurf.c             | 1 -
 drivers/isdn/hisax/ix1_micro.c         | 1 -
 drivers/isdn/hisax/jade.c              | 1 -
 drivers/isdn/hisax/mic.c               | 1 -
 drivers/isdn/hisax/netjet.c            | 1 -
 drivers/isdn/hisax/niccy.c             | 1 -
 drivers/isdn/hisax/nj_s.c              | 1 -
 drivers/isdn/hisax/nj_u.c              | 1 -
 drivers/isdn/hisax/s0box.c             | 1 -
 drivers/isdn/hisax/saphir.c            | 1 -
 drivers/isdn/hisax/sedlbauer.c         | 1 -
 drivers/isdn/hisax/sedlbauer_cs.c      | 1 -
 drivers/isdn/hisax/sportster.c         | 1 -
 drivers/isdn/hisax/st5481_b.c          | 1 -
 drivers/isdn/hisax/st5481_usb.c        | 1 -
 drivers/isdn/hisax/teleint.c           | 1 -
 drivers/isdn/hisax/teles0.c            | 1 -
 drivers/isdn/hisax/teles3.c            | 1 -
 drivers/isdn/hisax/teles_cs.c          | 1 -
 drivers/isdn/hisax/telespci.c          | 1 -
 drivers/isdn/hisax/w6692.c             | 1 -
 drivers/isdn/i4l/isdnhdlc.c            | 1 -
 47 files changed, 47 deletions(-)

diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 62b8030..4332bd8 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -11,7 +11,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/string.h>
 #include <linux/tty.h>
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hardware/eicon/platform.h
index b2edb75..b034ac1 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -19,7 +19,6 @@
 #endif
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/skbuff.h>
diff --git a/drivers/isdn/hisax/amd7930_fn.c b/drivers/isdn/hisax/amd7930_fn.c
index 36817e0..4d437f2 100644
--- a/drivers/isdn/hisax/amd7930_fn.c
+++ b/drivers/isdn/hisax/amd7930_fn.c
@@ -58,7 +58,6 @@
 #include "isac.h"
 #include "amd7930_fn.h"
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/gfp.h>
 
 static void Amd7930_new_ph(struct IsdnCardState *cs);
diff --git a/drivers/isdn/hisax/asuscom.c b/drivers/isdn/hisax/asuscom.c
index 62f9c43..cdbbec7 100644
--- a/drivers/isdn/hisax/asuscom.c
+++ b/drivers/isdn/hisax/asuscom.c
@@ -12,7 +12,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/isapnp.h>
 #include "hisax.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/avm_a1.c b/drivers/isdn/hisax/avm_a1.c
index 7dd7408..d3dbf02 100644
--- a/drivers/isdn/hisax/avm_a1.c
+++ b/drivers/isdn/hisax/avm_a1.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/avm_a1p.c b/drivers/isdn/hisax/avm_a1p.c
index bc52d54..50f1b1a 100644
--- a/drivers/isdn/hisax/avm_a1p.c
+++ b/drivers/isdn/hisax/avm_a1p.c
@@ -13,7 +13,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index baad94e..cf305b5 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -13,7 +13,6 @@
 
 
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/isdn/hisax/bkm_a4t.c b/drivers/isdn/hisax/bkm_a4t.c
index c360164..8ac171b 100644
--- a/drivers/isdn/hisax/bkm_a4t.c
+++ b/drivers/isdn/hisax/bkm_a4t.c
@@ -11,7 +11,6 @@
  */
 
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/bkm_a8.c b/drivers/isdn/hisax/bkm_a8.c
index dd663ea..20ad1f7 100644
--- a/drivers/isdn/hisax/bkm_a8.c
+++ b/drivers/isdn/hisax/bkm_a8.c
@@ -11,7 +11,6 @@
  */
 
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "ipac.h"
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 4fc90de..c8d2682 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -15,7 +15,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 2be1c8a..bdf952b 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -18,7 +18,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include "hisax.h"
 #include "arcofi.h"
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 40f6fad..ca35784 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -37,7 +37,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/isdn/hisax/enternow_pci.c b/drivers/isdn/hisax/enternow_pci.c
index e8d431a..2fd3886 100644
--- a/drivers/isdn/hisax/enternow_pci.c
+++ b/drivers/isdn/hisax/enternow_pci.c
@@ -67,7 +67,6 @@
 #include <linux/interrupt.h>
 #include <linux/ppp_defs.h>
 #include <linux/pci.h>
-#include <linux/init.h>
 #include "netjet.h"
 
 
diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index c7a9471..61db6fa 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -16,7 +16,6 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include "hisax.h"
 
 #define FSM_TIMER_DEBUG 0
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index 35c6df6..5157ac7 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -11,7 +11,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/hfc_2bds0.c b/drivers/isdn/hisax/hfc_2bds0.c
index a756e5c..17fcbbd 100644
--- a/drivers/isdn/hisax/hfc_2bds0.c
+++ b/drivers/isdn/hisax/hfc_2bds0.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include "hisax.h"
diff --git a/drivers/isdn/hisax/hfc_2bs0.c b/drivers/isdn/hisax/hfc_2bs0.c
index 838531b..2e2c319 100644
--- a/drivers/isdn/hisax/hfc_2bs0.c
+++ b/drivers/isdn/hisax/hfc_2bs0.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "hfc_2bs0.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 4a48255..5d8a1c7 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -15,7 +15,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "hfc_pci.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index fa1fefd..99c7f09 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -11,7 +11,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "hfc_sx.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index 394da64..1b69f0c 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/isapnp.h>
 #include "hisax.h"
 #include "hfc_2bds0.h"
diff --git a/drivers/isdn/hisax/hscx.c b/drivers/isdn/hisax/hscx.c
index 3e305fe..8c237dc 100644
--- a/drivers/isdn/hisax/hscx.c
+++ b/drivers/isdn/hisax/hscx.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "hscx.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 51dae91..575700f 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -14,7 +14,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "icc.h"
 // #include "arcofi.h"
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 5faa5de..d522dfb 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -11,7 +11,6 @@
  */
 #include <linux/kernel.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include "hisax_if.h"
 #include "hisax.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 7fdf78f..e671728 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -19,7 +19,6 @@
 #include "isdnl1.h"
 #include <linux/interrupt.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 
 #define DBUSY_TIMER_VALUE 80
 #define ARCOFI_USE 1
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index f4956c7..993c6f3 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -8,7 +8,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isar.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/isurf.c b/drivers/isdn/hisax/isurf.c
index 1399ddd..0d5849f 100644
--- a/drivers/isdn/hisax/isurf.c
+++ b/drivers/isdn/hisax/isurf.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "isar.h"
diff --git a/drivers/isdn/hisax/ix1_micro.c b/drivers/isdn/hisax/ix1_micro.c
index 7ae39f5..7d3b35c 100644
--- a/drivers/isdn/hisax/ix1_micro.c
+++ b/drivers/isdn/hisax/ix1_micro.c
@@ -17,7 +17,6 @@
  * Germany
  */
 
-#include <linux/init.h>
 #include <linux/isapnp.h>
 #include "hisax.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/jade.c b/drivers/isdn/hisax/jade.c
index e2ae787..f2c24f7 100644
--- a/drivers/isdn/hisax/jade.c
+++ b/drivers/isdn/hisax/jade.c
@@ -11,7 +11,6 @@
  */
 
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "hscx.h"
 #include "jade.h"
diff --git a/drivers/isdn/hisax/mic.c b/drivers/isdn/hisax/mic.c
index 9339867..6cf1367 100644
--- a/drivers/isdn/hisax/mic.c
+++ b/drivers/isdn/hisax/mic.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/netjet.c b/drivers/isdn/hisax/netjet.c
index 233e432..93b10a5 100644
--- a/drivers/isdn/hisax/netjet.c
+++ b/drivers/isdn/hisax/netjet.c
@@ -14,7 +14,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index e4c33cf..480cc66 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -13,7 +13,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/nj_s.c b/drivers/isdn/hisax/nj_s.c
index 32b4bbd..3c43f52 100644
--- a/drivers/isdn/hisax/nj_s.c
+++ b/drivers/isdn/hisax/nj_s.c
@@ -5,7 +5,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index 4e8adbe..9f6eaab 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -5,7 +5,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "icc.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/hisax/s0box.c b/drivers/isdn/hisax/s0box.c
index 4e7d0aa..3749b09 100644
--- a/drivers/isdn/hisax/s0box.c
+++ b/drivers/isdn/hisax/s0box.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/saphir.c b/drivers/isdn/hisax/saphir.c
index 6b2d0ec..dc36783 100644
--- a/drivers/isdn/hisax/saphir.c
+++ b/drivers/isdn/hisax/saphir.c
@@ -12,7 +12,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index f16a47b..1b9459f 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -38,7 +38,6 @@
  * For example: hisaxctrl <DriverID> 9 ISAR.BIN
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "ipac.h"
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 92ef62d..f738f26 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -37,7 +37,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/isdn/hisax/sportster.c b/drivers/isdn/hisax/sportster.c
index 18cee63..943a186 100644
--- a/drivers/isdn/hisax/sportster.c
+++ b/drivers/isdn/hisax/sportster.c
@@ -12,7 +12,6 @@
  *
  *
  */
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/st5481_b.c b/drivers/isdn/hisax/st5481_b.c
index 4098491..ca141d6 100644
--- a/drivers/isdn/hisax/st5481_b.c
+++ b/drivers/isdn/hisax/st5481_b.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/gfp.h>
 #include <linux/usb.h>
 #include <linux/netdevice.h>
diff --git a/drivers/isdn/hisax/st5481_usb.c b/drivers/isdn/hisax/st5481_usb.c
index ead0a4f..ee78014 100644
--- a/drivers/isdn/hisax/st5481_usb.c
+++ b/drivers/isdn/hisax/st5481_usb.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/usb.h>
 #include <linux/slab.h>
 #include "st5481.h"
diff --git a/drivers/isdn/hisax/teleint.c b/drivers/isdn/hisax/teleint.c
index bf64754..d947abc 100644
--- a/drivers/isdn/hisax/teleint.c
+++ b/drivers/isdn/hisax/teleint.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hfc_2bs0.h"
diff --git a/drivers/isdn/hisax/teles0.c b/drivers/isdn/hisax/teles0.c
index ce9eabd..bd439a9 100644
--- a/drivers/isdn/hisax/teles0.c
+++ b/drivers/isdn/hisax/teles0.c
@@ -15,7 +15,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isdnl1.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/teles3.c b/drivers/isdn/hisax/teles3.c
index 38fb2c1..c608d80 100644
--- a/drivers/isdn/hisax/teles3.c
+++ b/drivers/isdn/hisax/teles3.c
@@ -13,7 +13,6 @@
  *              Beat Doebeli
  *
  */
-#include <linux/init.h>
 #include <linux/isapnp.h>
 #include "hisax.h"
 #include "isac.h"
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index b8dd149..c0e532e 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -18,7 +18,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index 33eeb46..f9b2169 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -12,7 +12,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "isac.h"
 #include "hscx.h"
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index a858955..7e0c60c 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -10,7 +10,6 @@
  *
  */
 
-#include <linux/init.h>
 #include "hisax.h"
 #include "w6692.h"
 #include "isdnl1.h"
diff --git a/drivers/isdn/i4l/isdnhdlc.c b/drivers/isdn/i4l/isdnhdlc.c
index 027d1c5..5daace1 100644
--- a/drivers/isdn/i4l/isdnhdlc.c
+++ b/drivers/isdn/i4l/isdnhdlc.c
@@ -23,7 +23,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/crc-ccitt.h>
 #include <linux/isdn/hdlc.h>
 #include <linux/bitrev.h>
-- 
1.8.4.1
