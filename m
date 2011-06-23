From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 13/37] Remove unneeded version.h includes from drivers/net/
Date: Fri, 24 Jun 2011 00:21:10 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106240017510.17688@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1106232344480.17688@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, linux-wireless@vger.kernel.org,
	linux-usb@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Casey Leedom <leedom@chelsio.com>, Dmitry Kozlov <xeb@mail.ru>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"David S. Miller" <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106232344480.17688@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was pointed out by 'make versioncheck' that some includes of
linux/version.h are not needed in drivers/net/.
This patch removes them.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/atl1c/atl1c.h              |    1 -
 drivers/net/atl1e/atl1e.h              |    1 -
 drivers/net/benet/be.h                 |    1 -
 drivers/net/bna/cna.h                  |    1 -
 drivers/net/caif/caif_serial.c         |    1 -
 drivers/net/caif/caif_shm_u5500.c      |    1 -
 drivers/net/caif/caif_spi.c            |    1 -
 drivers/net/caif/caif_spi_slave.c      |    1 -
 drivers/net/can/c_can/c_can.c          |    1 -
 drivers/net/can/c_can/c_can_platform.c |    1 -
 drivers/net/can/softing/softing_main.c |    1 -
 drivers/net/cxgb4vf/cxgb4vf_main.c     |    1 -
 drivers/net/cxgb4vf/t4vf_hw.c          |    1 -
 drivers/net/davinci_emac.c             |    1 -
 drivers/net/pptp.c                     |    1 -
 drivers/net/sfc/net_driver.h           |    1 -
 drivers/net/usb/cdc_ncm.c              |    1 -
 drivers/net/wireless/rtlwifi/wifi.h    |    1 -
 18 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 925929d..695398c 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -22,7 +22,6 @@
 #ifndef _ATL1C_H_
 #define _ATL1C_H_
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index 490d3b3..3861949 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -23,7 +23,6 @@
 #ifndef _ATL1E_H_
 #define _ATL1E_H_
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index a7db870..66ae5b5 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -20,7 +20,6 @@
 
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
-#include <linux/version.h>
 #include <linux/delay.h>
 #include <net/tcp.h>
 #include <net/ip.h>
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index bbd39dc..8ee9e38 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -19,7 +19,6 @@
 #ifndef __CNA_H__
 #define __CNA_H__
 
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/pci.h>
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 3df0c0f..175e134 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -5,7 +5,6 @@
  */
 
 #include <linux/init.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/types.h>
diff --git a/drivers/net/caif/caif_shm_u5500.c b/drivers/net/caif/caif_shm_u5500.c
index 5f771ab..89d76b7 100644
--- a/drivers/net/caif/caif_shm_u5500.c
+++ b/drivers/net/caif/caif_shm_u5500.c
@@ -7,7 +7,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ":" fmt
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 57e6393..0f8defc 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -5,7 +5,6 @@
  * License terms: GNU General Public License (GPL) version 2.
  */
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_spi_slave.c
index b009e03..e139e13 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -4,7 +4,6 @@
  * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
  * License terms: GNU General Public License (GPL) version 2.
  */
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 7e5cc0b..80adc83 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -26,7 +26,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index cc90824..0e300cf 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -20,7 +20,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 60a49e5..849e4a0 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -17,7 +17,6 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index e71c08e..8a6f891 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -33,7 +33,6 @@
  * SOFTWARE.
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index 192db22..fe3fd3d 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -33,7 +33,6 @@
  * SOFTWARE.
  */
 
-#include <linux/version.h>
 #include <linux/pci.h>
 
 #include "t4vf_common.h"
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index dcc4a17..a8adf0c 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -48,7 +48,6 @@
 #include <linux/highmem.h>
 #include <linux/proc_fs.h>
 #include <linux/ctype.h>
-#include <linux/version.h>
 #include <linux/spinlock.h>
 #include <linux/dma-mapping.h>
 #include <linux/clk.h>
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 1286fe2..eae542a 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -30,7 +30,6 @@
 #include <linux/ip.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
-#include <linux/version.h>
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e8d5f03..1affbf4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -17,7 +17,6 @@
 #define DEBUG
 #endif
 
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f33ca6a..fd622a6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -47,7 +47,6 @@
 #include <linux/mii.h>
 #include <linux/crc32.h>
 #include <linux/usb.h>
-#include <linux/version.h>
 #include <linux/timer.h>
 #include <linux/spinlock.h>
 #include <linux/atomic.h>
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 693395e..dd85110 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -32,7 +32,6 @@
 
 #include <linux/sched.h>
 #include <linux/firmware.h>
-#include <linux/version.h>
 #include <linux/etherdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/usb.h>
-- 
1.7.5.2


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
