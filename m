From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] wireless: delete non-required instances of include <linux/init.h>
Date: Thu, 2 Jan 2014 18:58:32 -0500
Message-ID: <1388707112-5669-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43651 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbaABX7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 18:59:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of these files are actually using any __init type directives
and hence don't need to include <linux/init.h>.  Most are just a
left over from __devinit and __cpuinit removal, or simply due to
code getting copied from one driver to the next.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Applied to net-next v3.13-rc4-1273-gde6fb28 ; Compile tested with
 x86_64 allmodconfig, and ppc allmodconfig ; diffstat speaks for
 itself somewhat.... ]

 drivers/net/wireless/adm8211.c                 | 1 -
 drivers/net/wireless/airo_cs.c                 | 1 -
 drivers/net/wireless/ath/ar5523/ar5523.c       | 1 -
 drivers/net/wireless/ath/carl9170/debug.c      | 1 -
 drivers/net/wireless/ath/carl9170/main.c       | 1 -
 drivers/net/wireless/ath/carl9170/rx.c         | 1 -
 drivers/net/wireless/ath/carl9170/tx.c         | 1 -
 drivers/net/wireless/atmel.c                   | 1 -
 drivers/net/wireless/atmel_cs.c                | 1 -
 drivers/net/wireless/atmel_pci.c               | 1 -
 drivers/net/wireless/cw1200/fwio.c             | 1 -
 drivers/net/wireless/cw1200/main.c             | 1 -
 drivers/net/wireless/hostap/hostap_cs.c        | 1 -
 drivers/net/wireless/hostap/hostap_pci.c       | 1 -
 drivers/net/wireless/hostap/hostap_plx.c       | 1 -
 drivers/net/wireless/ipw2x00/ipw2200.h         | 1 -
 drivers/net/wireless/iwlegacy/3945-rs.c        | 1 -
 drivers/net/wireless/iwlegacy/3945.c           | 1 -
 drivers/net/wireless/iwlegacy/4965-rs.c        | 1 -
 drivers/net/wireless/iwlegacy/4965.c           | 1 -
 drivers/net/wireless/iwlegacy/common.c         | 1 -
 drivers/net/wireless/iwlwifi/dvm/led.c         | 1 -
 drivers/net/wireless/iwlwifi/dvm/lib.c         | 1 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c    | 1 -
 drivers/net/wireless/iwlwifi/dvm/power.c       | 1 -
 drivers/net/wireless/iwlwifi/dvm/rs.c          | 1 -
 drivers/net/wireless/iwlwifi/dvm/tt.c          | 1 -
 drivers/net/wireless/iwlwifi/dvm/tx.c          | 1 -
 drivers/net/wireless/iwlwifi/dvm/ucode.c       | 1 -
 drivers/net/wireless/iwlwifi/mvm/power.c       | 1 -
 drivers/net/wireless/iwlwifi/mvm/rs.c          | 1 -
 drivers/net/wireless/mwl8k.c                   | 1 -
 drivers/net/wireless/orinoco/hermes.c          | 1 -
 drivers/net/wireless/orinoco/orinoco_cs.c      | 1 -
 drivers/net/wireless/orinoco/orinoco_usb.c     | 1 -
 drivers/net/wireless/orinoco/spectrum_cs.c     | 1 -
 drivers/net/wireless/p54/eeprom.c              | 1 -
 drivers/net/wireless/p54/fwio.c                | 1 -
 drivers/net/wireless/p54/led.c                 | 1 -
 drivers/net/wireless/p54/main.c                | 1 -
 drivers/net/wireless/p54/p54pci.c              | 1 -
 drivers/net/wireless/p54/p54usb.c              | 1 -
 drivers/net/wireless/p54/txrx.c                | 1 -
 drivers/net/wireless/rndis_wlan.c              | 1 -
 drivers/net/wireless/rt2x00/rt2400pci.c        | 1 -
 drivers/net/wireless/rt2x00/rt2500pci.c        | 1 -
 drivers/net/wireless/rt2x00/rt2500usb.c        | 1 -
 drivers/net/wireless/rt2x00/rt2800usb.c        | 1 -
 drivers/net/wireless/rt2x00/rt61pci.c          | 1 -
 drivers/net/wireless/rt2x00/rt73usb.c          | 1 -
 drivers/net/wireless/rtl818x/rtl8180/dev.c     | 1 -
 drivers/net/wireless/rtl818x/rtl8180/grf5101.c | 1 -
 drivers/net/wireless/rtl818x/rtl8180/max2820.c | 1 -
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c | 1 -
 drivers/net/wireless/rtl818x/rtl8180/sa2400.c  | 1 -
 drivers/net/wireless/rtl818x/rtl8187/dev.c     | 1 -
 drivers/net/wireless/rtl818x/rtl8187/rtl8225.c | 1 -
 drivers/net/wireless/wl3501_cs.c               | 1 -
 58 files changed, 58 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 1d40c69..55eda7a 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -15,7 +15,6 @@
  * more details.
  */
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/if.h>
 #include <linux/skbuff.h>
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 14128fd..7e9ede6 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -23,7 +23,6 @@
 #ifdef __IN_PCMCIA_PACKAGE__
 #include <pcmcia/k_compat.h>
 #endif
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/ptrace.h>
diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index 280fc3d..8aa20df 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -25,7 +25,6 @@
  * that and only has minimal functionality.
  */
 #include <linux/compiler.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/list.h>
diff --git a/drivers/net/wireless/ath/carl9170/debug.c b/drivers/net/wireless/ath/carl9170/debug.c
index 3d70cd2..1c0af9c 100644
--- a/drivers/net/wireless/ath/carl9170/debug.c
+++ b/drivers/net/wireless/ath/carl9170/debug.c
@@ -37,7 +37,6 @@
  *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 349fa22..4c3f576 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -37,7 +37,6 @@
  *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index e935f61..142602f 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -37,7 +37,6 @@
  *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/ath/carl9170/tx.c
index e3f696e..4cadfd4 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -37,7 +37,6 @@
  *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index b73b7e3..bf93ea8 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -39,7 +39,6 @@
 
 ******************************************************************************/
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 
 #include <linux/kernel.h>
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 5e2749d..4cfb4d9 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -32,7 +32,6 @@
 #ifdef __IN_PCMCIA_PACKAGE__
 #include <pcmcia/k_compat.h>
 #endif
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/ptrace.h>
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index 64d5973..5cd97e3 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -22,7 +22,6 @@
 #include <linux/pci.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include "atmel.h"
 
diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/cw1200/fwio.c
index acdff0f..5a9ffd3 100644
--- a/drivers/net/wireless/cw1200/fwio.c
+++ b/drivers/net/wireless/cw1200/fwio.c
@@ -14,7 +14,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/vmalloc.h>
 #include <linux/sched.h>
 #include <linux/firmware.h>
diff --git a/drivers/net/wireless/cw1200/main.c b/drivers/net/wireless/cw1200/main.c
index 090f015..d1270da 100644
--- a/drivers/net/wireless/cw1200/main.c
+++ b/drivers/net/wireless/cw1200/main.c
@@ -21,7 +21,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <linux/vmalloc.h>
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 56cd01c..9f825f2 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -1,7 +1,6 @@
 #define PRISM2_PCCARD
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/if.h>
 #include <linux/slab.h>
 #include <linux/wait.h>
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 05ca340..91158e2 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -5,7 +5,6 @@
  * Andy Warner <andyw@pobox.com> */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/if.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index c3d067e..3bf530d 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -8,7 +8,6 @@
 
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/if.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.h b/drivers/net/wireless/ipw2x00/ipw2200.h
index 570d6fb..aa301d1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.h
+++ b/drivers/net/wireless/ipw2x00/ipw2200.h
@@ -29,7 +29,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/mutex.h>
 
diff --git a/drivers/net/wireless/iwlegacy/3945-rs.c b/drivers/net/wireless/iwlegacy/3945-rs.c
index aea667b..9a45f6f 100644
--- a/drivers/net/wireless/iwlegacy/3945-rs.c
+++ b/drivers/net/wireless/iwlegacy/3945-rs.c
@@ -25,7 +25,6 @@
  *****************************************************************************/
 
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index f09e257..f6c52db 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -26,7 +26,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/wireless/iwlegacy/4965-rs.c b/drivers/net/wireless/iwlegacy/4965-rs.c
index 3ccbaf7..4d5e332 100644
--- a/drivers/net/wireless/iwlegacy/4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/4965-rs.c
@@ -24,7 +24,6 @@
  *
  *****************************************************************************/
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/iwlegacy/4965.c b/drivers/net/wireless/iwlegacy/4965.c
index 777a578..fe47db9 100644
--- a/drivers/net/wireless/iwlegacy/4965.c
+++ b/drivers/net/wireless/iwlegacy/4965.c
@@ -26,7 +26,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index a27b14c..3081c15 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -33,7 +33,6 @@
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/lockdep.h>
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
diff --git a/drivers/net/wireless/iwlwifi/dvm/led.c b/drivers/net/wireless/iwlwifi/dvm/led.c
index 33c7e15..10f6588 100644
--- a/drivers/net/wireless/iwlwifi/dvm/led.c
+++ b/drivers/net/wireless/iwlwifi/dvm/led.c
@@ -27,7 +27,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/wireless/iwlwifi/dvm/lib.c b/drivers/net/wireless/iwlwifi/dvm/lib.c
index 3d5bdc4..5275365 100644
--- a/drivers/net/wireless/iwlwifi/dvm/lib.c
+++ b/drivers/net/wireless/iwlwifi/dvm/lib.c
@@ -29,7 +29,6 @@
 #include <linux/etherdevice.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/sched.h>
 #include <net/mac80211.h>
 
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
index 9f4239d..4e8918b 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -28,7 +28,6 @@
  *****************************************************************************/
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
diff --git a/drivers/net/wireless/iwlwifi/dvm/power.c b/drivers/net/wireless/iwlwifi/dvm/power.c
index 77cb597..1864cc0 100644
--- a/drivers/net/wireless/iwlwifi/dvm/power.c
+++ b/drivers/net/wireless/iwlwifi/dvm/power.c
@@ -30,7 +30,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <net/mac80211.h>
 #include "iwl-io.h"
 #include "iwl-debug.h"
diff --git a/drivers/net/wireless/iwlwifi/dvm/rs.c b/drivers/net/wireless/iwlwifi/dvm/rs.c
index b647e50..3036a0c 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rs.c
@@ -24,7 +24,6 @@
  *
  *****************************************************************************/
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/iwlwifi/dvm/tt.c b/drivers/net/wireless/iwlwifi/dvm/tt.c
index fbeee08..612eb7b 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tt.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tt.c
@@ -30,7 +30,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <net/mac80211.h>
 #include "iwl-io.h"
 #include "iwl-modparams.h"
diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/iwlwifi/dvm/tx.c
index e12b1a6..4d1cfc4 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
@@ -29,7 +29,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/ieee80211.h>
 #include "iwl-io.h"
diff --git a/drivers/net/wireless/iwlwifi/dvm/ucode.c b/drivers/net/wireless/iwlwifi/dvm/ucode.c
index 6363794..2245e5f 100644
--- a/drivers/net/wireless/iwlwifi/dvm/ucode.c
+++ b/drivers/net/wireless/iwlwifi/dvm/ucode.c
@@ -28,7 +28,6 @@
  *****************************************************************************/
 
 #include <linux/kernel.h>
-#include <linux/init.h>
 
 #include "iwl-io.h"
 #include "iwl-agn-hw.h"
diff --git a/drivers/net/wireless/iwlwifi/mvm/power.c b/drivers/net/wireless/iwlwifi/mvm/power.c
index 483ecc6..f6bfa58 100644
--- a/drivers/net/wireless/iwlwifi/mvm/power.c
+++ b/drivers/net/wireless/iwlwifi/mvm/power.c
@@ -64,7 +64,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 
 #include <net/mac80211.h>
 
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/iwlwifi/mvm/rs.c
index d6d28d7..2bd471e 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.c
@@ -24,7 +24,6 @@
  *
  *****************************************************************************/
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b953ad6..2bf3ce9 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -9,7 +9,6 @@
  * warranty of any kind, whether express or implied.
  */
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/drivers/net/wireless/orinoco/hermes.c b/drivers/net/wireless/orinoco/hermes.c
index 75c15bc..43790fb 100644
--- a/drivers/net/wireless/orinoco/hermes.c
+++ b/drivers/net/wireless/orinoco/hermes.c
@@ -40,7 +40,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 
 #include "hermes.h"
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index d21d959..c0a2737 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -15,7 +15,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index bdfe637..f9805c9 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -52,7 +52,6 @@
 #include <linux/signal.h>
 #include <linux/errno.h>
 #include <linux/poll.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/fcntl.h>
 #include <linux/spinlock.h>
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index e2264bc..b60048c 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -23,7 +23,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index d43e374..0fe67d2 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -16,7 +16,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <linux/sort.h>
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index b3879fb..bc065e8 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -16,7 +16,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/wireless/p54/led.c b/drivers/net/wireless/p54/led.c
index 3837e1e..1f6fd5f 100644
--- a/drivers/net/wireless/p54/led.c
+++ b/drivers/net/wireless/p54/led.c
@@ -16,7 +16,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 
diff --git a/drivers/net/wireless/p54/main.c b/drivers/net/wireless/p54/main.c
index 067e6f2..80d93cb 100644
--- a/drivers/net/wireless/p54/main.c
+++ b/drivers/net/wireless/p54/main.c
@@ -16,7 +16,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index f9a07b0..d411de4 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -13,7 +13,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/firmware.h>
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index e328d30..6e635cf 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -12,7 +12,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/usb.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index f95de0d..6d8fb4d 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/export.h>
-#include <linux/init.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <asm/div64.h>
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index c3cdda1..5028557 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -26,7 +26,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 4ad0de9..4ccfef5 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -24,7 +24,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/pci.h>
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 4f61ffb..abc5f56 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -24,7 +24,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/pci.h>
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 1bb7693..9f16824 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -24,7 +24,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 49ff178..5c5c490 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -29,7 +29,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/usb.h>
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index b76f604..2440298 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -25,7 +25,6 @@
 #include <linux/crc-itu-t.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index ade88d7..a140170 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -25,7 +25,6 @@
 #include <linux/crc-itu-t.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index a91506b..8ec17aa 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -15,7 +15,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8180/grf5101.c b/drivers/net/wireless/rtl818x/rtl8180/grf5101.c
index dc845693..b1bfee7 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/grf5101.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/grf5101.c
@@ -19,7 +19,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8180/max2820.c b/drivers/net/wireless/rtl818x/rtl8180/max2820.c
index a63c443..eebf239 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/max2820.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/max2820.c
@@ -18,7 +18,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8180/rtl8225.c b/drivers/net/wireless/rtl818x/rtl8180/rtl8225.c
index ee638d0..d60a5f3 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/rtl8225.c
@@ -15,7 +15,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8180/sa2400.c b/drivers/net/wireless/rtl818x/rtl8180/sa2400.c
index 7614d9c..959b049 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/sa2400.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/sa2400.c
@@ -19,7 +19,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index ec9aa5b..fd78df8 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -20,7 +20,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/usb.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
diff --git a/drivers/net/wireless/rtl818x/rtl8187/rtl8225.c b/drivers/net/wireless/rtl818x/rtl8187/rtl8225.c
index a26193a..5ecf18e 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/rtl8225.c
@@ -16,7 +16,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/usb.h>
 #include <net/mac80211.h>
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 1477d7f..d24d4a9 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -29,7 +29,6 @@
 
 #include <linux/delay.h>
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
-- 
1.8.4.1
