From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] tcp_memcg: remove useless var old_lim
Date: Fri, 22 Nov 2013 14:48:40 +0800
Message-ID: <1385102920-31215-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: glommer@parallels.com, Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12153 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751621Ab3KVGrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Nov 2013 01:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nobody needs it. remove.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/tcp_memcontrol.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 03e9154..269a89e 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -60,7 +60,6 @@ EXPORT_SYMBOL(tcp_destroy_cgroup);
 static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 {
 	struct cg_proto *cg_proto;
-	u64 old_lim;
 	int i;
 	int ret;
 
@@ -71,7 +70,6 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	if (val > RES_COUNTER_MAX)
 		val = RES_COUNTER_MAX;
 
-	old_lim = res_counter_read_u64(&cg_proto->memory_allocated, RES_LIMIT);
 	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
 	if (ret)
 		return ret;
-- 
1.8.3.1
