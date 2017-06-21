From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 4/4] qed*: Rename qed_roce_if.h to qed_rdma_if.h
Date: Wed, 21 Jun 2017 16:22:46 +0300
Message-ID: <1498051366-22988-5-git-send-email-Michal.Kalderon@cavium.com>
References: <1498051366-22988-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <Ram.Amrani@cavium.com>,
        <Ariel.Elior@cavium.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0050.outbound.protection.outlook.com ([104.47.37.50]:36192
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751641AbdFUNXc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 09:23:32 -0400
In-Reply-To: <1498051366-22988-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the qed_roce_if file to qed_rdma_if as it
represents a common interface for RoCE and iWARP.

this commit affects RDMA/qedr as well.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/infiniband/hw/qedr/qedr.h                  | 2 +-
 drivers/infiniband/hw/qedr/qedr_cm.c               | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.c         | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.h         | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c         | 2 +-
 include/linux/qed/{qed_roce_if.h => qed_rdma_if.h} | 4 ++--
 6 files changed, 7 insertions(+), 7 deletions(-)
 rename include/linux/qed/{qed_roce_if.h => qed_rdma_if.h} (99%)

diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 2376019..15365d5 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -36,7 +36,7 @@
 #include <rdma/ib_addr.h>
 #include <linux/qed/qed_if.h>
 #include <linux/qed/qed_chain.h>
-#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_rdma_if.h>
 #include <linux/qed/qede_rdma.h>
 #include <linux/qed/roce_common.h>
 #include "qedr_hsi_rdma.h"
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.c b/drivers/infiniband/hw/qedr/qedr_cm.c
index eb3dce7..4689e80 100644
--- a/drivers/infiniband/hw/qedr/qedr_cm.c
+++ b/drivers/infiniband/hw/qedr/qedr_cm.c
@@ -44,7 +44,7 @@
 #include <rdma/ib_cache.h>
 
 #include <linux/qed/qed_if.h>
-#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_rdma_if.h>
 #include "qedr.h"
 #include "verbs.h"
 #include <rdma/qedr-abi.h>
diff --git a/drivers/net/ethernet/qlogic/qed/qed_rdma.c b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
index cb620e0..df76e21 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_rdma.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
@@ -53,7 +53,7 @@
 #include "qed_ll2.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
-#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_rdma_if.h>
 #include "qed_rdma.h"
 #include "qed_roce.h"
 #include "qed_sp.h"
diff --git a/drivers/net/ethernet/qlogic/qed/qed_rdma.h b/drivers/net/ethernet/qlogic/qed/qed_rdma.h
index 1836ff1..d91e5c4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_rdma.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_rdma.h
@@ -38,7 +38,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/qed/qed_if.h>
-#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_rdma_if.h>
 #include "qed.h"
 #include "qed_dev_api.h"
 #include "qed_hsi.h"
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index a842693..e53adc3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -53,7 +53,7 @@
 #include "qed_ll2.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
-#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_rdma_if.h>
 #include "qed_rdma.h"
 #include "qed_roce.h"
 #include "qed_sp.h"
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_rdma_if.h
similarity index 99%
rename from include/linux/qed/qed_roce_if.h
rename to include/linux/qed/qed_rdma_if.h
index 8e70f5e..ff9be01 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_rdma_if.h
@@ -29,8 +29,8 @@
  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  * SOFTWARE.
  */
-#ifndef _QED_ROCE_IF_H
-#define _QED_ROCE_IF_H
+#ifndef _QED_RDMA_IF_H
+#define _QED_RDMA_IF_H
 #include <linux/types.h>
 #include <linux/delay.h>
 #include <linux/list.h>
-- 
1.8.3.1
