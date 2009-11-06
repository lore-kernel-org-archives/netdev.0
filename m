From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 03/16] net: Replace old style lock initializer
Date: Fri, 06 Nov 2009 22:41:15 -0000
Message-ID: <20091106223806.519088363@linutronix.de>
References: <20091106223547.784916750@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933173AbZKFWlv@vger.kernel.org>
Content-Disposition: inline; filename=net-replace-old-style-lock-init.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SPIN_LOCK_UNLOCKED is deprecated. Use DEFINE_SPINLOCK instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: netdev@vger.kernel.org
Cc: David S. Miller <davem@davemloft.net>
---
 net/core/drop_monitor.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/net/core/drop_monitor.c
===================================================================
--- linux-2.6.orig/net/core/drop_monitor.c
+++ linux-2.6/net/core/drop_monitor.c
@@ -41,7 +41,7 @@ static void send_dm_alert(struct work_st
  * netlink alerts
  */
 static int trace_state = TRACE_OFF;
-static spinlock_t trace_state_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(trace_state_lock);
 
 struct per_cpu_dm_data {
 	struct work_struct dm_alert_work;
