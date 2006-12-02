From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 03/10] chelsio: remove unused mutex
Date: Fri, 01 Dec 2006 16:36:15 -0800
Message-ID: <20061202003707.338053000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:39394 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162415AbWLBAj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:29 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-mutex.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This mutex is unused in current (non TOE) code.

Signed-off-by: Stephen Hemminger<shemminger@osdl.org>

---
 drivers/net/chelsio/common.h |    1 -
 drivers/net/chelsio/cxgb2.c  |    1 -
 2 files changed, 2 deletions(-)

--- chelsio-t2.orig/drivers/net/chelsio/common.h
+++ chelsio-t2/drivers/net/chelsio/common.h
@@ -212,7 +212,6 @@ struct adapter {
 	struct work_struct stats_update_task;
 	struct timer_list stats_update_timer;
 
-	struct semaphore mib_mutex;
 	spinlock_t tpi_lock;
 	spinlock_t work_lock;
 	/* guards async operations */
--- chelsio-t2.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio-t2/drivers/net/chelsio/cxgb2.c
@@ -1040,7 +1040,6 @@ static int __devinit init_one(struct pci
 			adapter->msg_enable = dflt_msg_enable;
 			adapter->mmio_len = mmio_len;
 
-			init_MUTEX(&adapter->mib_mutex);
 			spin_lock_init(&adapter->tpi_lock);
 			spin_lock_init(&adapter->work_lock);
 			spin_lock_init(&adapter->async_lock);

-- 

