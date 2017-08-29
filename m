From: Dave Jiang <dave.jiang@intel.com>
Subject: [PATCH] net: remove dmaengine.h inclusion from netdevice.h
Date: Tue, 29 Aug 2017 13:17:51 -0700
Message-ID: <150403787157.72820.10644938115323539701.stgit@djiang5-desk3.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32767 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbdH2URw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 16:17:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the removal of NET_DMA, dmaengine.h header file shouldn't be needed
by netdevice.h anymore.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 include/linux/netdevice.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 779b235..dd5b440 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -35,7 +35,6 @@
 
 #include <linux/percpu.h>
 #include <linux/rculist.h>
-#include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 #include <linux/dynamic_queue_limits.h>
 
