From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] qed: Remove unused including <linux/version.h>
Date: Thu, 18 May 2017 15:26:29 +0000
Message-ID: <20170518152629.12503-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35170 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933863AbdERP0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:26:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so6179746pfd.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 08:26:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove including <linux/version.h> that is not needed.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c  | 1 -
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 1 -
 drivers/net/ethernet/qlogic/qed/qed_l2.c    | 1 -
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   | 1 -
 drivers/net/ethernet/qlogic/qed/qed_main.c  | 1 -
 5 files changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
index 21a58ff..690dd2b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
@@ -43,7 +43,6 @@
 #include <linux/slab.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
-#include <linux/version.h>
 #include <linux/workqueue.h>
 #include <linux/errno.h>
 #include <linux/list.h>
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 339c91d..f2fd09c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -44,7 +44,6 @@
 #include <linux/slab.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
-#include <linux/version.h>
 #include <linux/workqueue.h>
 #include <linux/errno.h>
 #include <linux/list.h>
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 746fed4..fab6e69 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -43,7 +43,6 @@
 #include <linux/slab.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
-#include <linux/version.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
 #include <linux/bug.h>
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 09c8641..b04dfc4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -38,7 +38,6 @@
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/stddef.h>
-#include <linux/version.h>
 #include <linux/workqueue.h>
 #include <net/ipv6.h>
 #include <linux/bitops.h>
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 537d123..f286daa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -34,7 +34,6 @@
 #include <linux/pci.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
-#include <linux/version.h>
 #include <linux/delay.h>
 #include <asm/byteorder.h>
 #include <linux/dma-mapping.h>
