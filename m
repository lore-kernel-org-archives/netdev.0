From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [RFC 13/19] RDMA/qedr: Rename the qedr_cm file as a preparation for iWARP support
Date: Mon, 26 Jun 2017 21:07:03 +0300
Message-ID: <1498500429-22557-14-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:9536
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751440AbdFZSNl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:13:41 -0400
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main differences between iWARP and RoCE lay in the communication
 management functions. These will be placed in separate files.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

---
 drivers/infiniband/hw/qedr/Makefile                      | 2 +-
 drivers/infiniband/hw/qedr/{qedr_cm.c => qedr_roce_cm.c} | 2 +-
 drivers/infiniband/hw/qedr/{qedr_cm.h => qedr_roce_cm.h} | 0
 drivers/infiniband/hw/qedr/verbs.c                       | 2 +-
 4 files changed, 3 insertions(+), 3 deletions(-)
 rename drivers/infiniband/hw/qedr/{qedr_cm.c => qedr_roce_cm.c} (99%)
 rename drivers/infiniband/hw/qedr/{qedr_cm.h => qedr_roce_cm.h} (100%)

diff --git a/drivers/infiniband/hw/qedr/Makefile b/drivers/infiniband/hw/qedr/Makefile
index ba7067c..331a361 100644
--- a/drivers/infiniband/hw/qedr/Makefile
+++ b/drivers/infiniband/hw/qedr/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_INFINIBAND_QEDR) := qedr.o
 
-qedr-y := main.o verbs.o qedr_cm.o
+qedr-y := main.o verbs.o qedr_roce_cm.o
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.c b/drivers/infiniband/hw/qedr/qedr_roce_cm.c
similarity index 99%
rename from drivers/infiniband/hw/qedr/qedr_cm.c
rename to drivers/infiniband/hw/qedr/qedr_roce_cm.c
index 4689e80..c3c249b 100644
--- a/drivers/infiniband/hw/qedr/qedr_cm.c
+++ b/drivers/infiniband/hw/qedr/qedr_roce_cm.c
@@ -48,7 +48,7 @@
 #include "qedr.h"
 #include "verbs.h"
 #include <rdma/qedr-abi.h>
-#include "qedr_cm.h"
+#include "qedr_roce_cm.h"
 
 void qedr_inc_sw_gsi_cons(struct qedr_qp_hwq_info *info)
 {
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.h b/drivers/infiniband/hw/qedr/qedr_roce_cm.h
similarity index 100%
rename from drivers/infiniband/hw/qedr/qedr_cm.h
rename to drivers/infiniband/hw/qedr/qedr_roce_cm.h
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 548e4d1..16637ec 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -49,7 +49,7 @@
 #include "qedr.h"
 #include "verbs.h"
 #include <rdma/qedr-abi.h>
-#include "qedr_cm.h"
+#include "qedr_roce_cm.h"
 
 #define DB_ADDR_SHIFT(addr)		((addr) << DB_PWM_ADDR_OFFSET_SHIFT)
 
-- 
1.8.3.1
