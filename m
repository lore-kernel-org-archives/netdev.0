From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/4] net/rps: Protect cpu_rmap.h from double inclusion
Date: Wed, 18 Jul 2012 17:19:20 +0300
Message-ID: <1342621162-18498-3-git-send-email-ogerlitz@mellanox.com>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:55488 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753257Ab2GROTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:19:34 -0400
In-Reply-To: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/cpu_rmap.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/cpu_rmap.h b/include/linux/cpu_rmap.h
index 473771a..ac3bbb5 100644
--- a/include/linux/cpu_rmap.h
+++ b/include/linux/cpu_rmap.h
@@ -1,3 +1,6 @@
+#ifndef __LINUX_CPU_RMAP_H
+#define __LINUX_CPU_RMAP_H
+
 /*
  * cpu_rmap.c: CPU affinity reverse-map support
  * Copyright 2011 Solarflare Communications Inc.
@@ -71,3 +74,4 @@ extern void free_irq_cpu_rmap(struct cpu_rmap *rmap);
 extern int irq_cpu_rmap_add(struct cpu_rmap *rmap, int irq);
 
 #endif
+#endif /* __LINUX_CPU_RMAP_H */
-- 
1.7.1
