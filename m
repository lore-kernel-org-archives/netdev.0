From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 2/9] net: rds: use this_cpu_ptr per-cpu helper
Date: Wed, 31 Oct 2012 19:22:21 +0800
Message-ID: <509109ED.7060900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan@tencent.com>


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/rds/ib_recv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 8d19491..a4a5064 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -423,7 +423,7 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 
 	local_irq_save(flags);
 
-	chp = per_cpu_ptr(cache->percpu, smp_processor_id());
+	chp = this_cpu_ptr(cache->percpu);
 	if (!chp->first)
 		INIT_LIST_HEAD(new_item);
 	else /* put on front */
-- 
1.7.1
