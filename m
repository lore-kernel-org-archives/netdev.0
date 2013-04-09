From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH] tcp_memcontrol: remove a redundant statement in tcp_destroy_cgroup()
Date: Tue, 9 Apr 2013 13:59:28 +0800
Message-ID: <5163AE40.40304@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>,
	LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We read the value but make no use of it.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 net/ipv4/tcp_memcontrol.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index b6f3583..d52196f 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -72,8 +72,6 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 
 	tcp = tcp_from_cgproto(cg_proto);
 	percpu_counter_destroy(&tcp->tcp_sockets_allocated);
-
-	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
-- 
1.8.0.2
