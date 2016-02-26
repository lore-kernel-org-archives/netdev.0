From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] asm-generic: remove old nonatomic-io wrapper files
Date: Fri, 26 Feb 2016 15:29:05 +0100
Message-ID: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yisen Zhuang <yisen.zhuang@huawei.com>,
	yankejian <yankejian@huawei.com>,
	kenneth Lee <liguozhu@hisilicon.com>,
	huangdaode <huangdaode@hisilicon.com>,
	lipeng <lipeng321@huawei.com>, linux-kernel@vger.kernel.org,
	dmaengine@vger.kernel.org, netdev@vger.kernel.org,
	oss-drivers@netronome.com, linux-arch@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The two header files got moved to include/linux, and most
users were already converted, this changes the remaining drivers
and removes the files.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/dma/idma64.h                                | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 +-
 include/asm-generic/io-64-nonatomic-hi-lo.h         | 2 --
 include/asm-generic/io-64-nonatomic-lo-hi.h         | 2 --
 5 files changed, 3 insertions(+), 7 deletions(-)
 delete mode 100644 include/asm-generic/io-64-nonatomic-hi-lo.h
 delete mode 100644 include/asm-generic/io-64-nonatomic-lo-hi.h

diff --git a/drivers/dma/idma64.h b/drivers/dma/idma64.h
index 8423f13ed0da..a52ad6bcf86a 100644
--- a/drivers/dma/idma64.h
+++ b/drivers/dma/idma64.h
@@ -16,7 +16,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include <asm-generic/io-64-nonatomic-lo-hi.h>
+#include <linux/io-64-nonatomic-lo-hi.h>
 
 #include "virt-dma.h"
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index 802d55457f19..fd90f3737963 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -7,7 +7,7 @@
  * (at your option) any later version.
  */
 
-#include <asm-generic/io-64-nonatomic-hi-lo.h>
+#include <linux/io-64-nonatomic-hi-lo.h>
 #include <linux/of_mdio.h>
 #include "hns_dsaf_main.h"
 #include "hns_dsaf_mac.h"
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index ab264e1bccd0..75683fb26734 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -45,7 +45,7 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <asm-generic/io-64-nonatomic-hi-lo.h>
+#include <linux/io-64-nonatomic-hi-lo.h>
 
 #include "nfp_net_ctrl.h"
 
diff --git a/include/asm-generic/io-64-nonatomic-hi-lo.h b/include/asm-generic/io-64-nonatomic-hi-lo.h
deleted file mode 100644
index 32b73abce1b0..000000000000
--- a/include/asm-generic/io-64-nonatomic-hi-lo.h
+++ /dev/null
@@ -1,2 +0,0 @@
-/* XXX: delete asm-generic/io-64-nonatomic-hi-lo.h after converting new users */
-#include <linux/io-64-nonatomic-hi-lo.h>
diff --git a/include/asm-generic/io-64-nonatomic-lo-hi.h b/include/asm-generic/io-64-nonatomic-lo-hi.h
deleted file mode 100644
index 55a627c37721..000000000000
--- a/include/asm-generic/io-64-nonatomic-lo-hi.h
+++ /dev/null
@@ -1,2 +0,0 @@
-/* XXX: delete asm-generic/io-64-nonatomic-lo-hi.h after converting new users */
-#include <linux/io-64-nonatomic-lo-hi.h>
-- 
2.7.0
