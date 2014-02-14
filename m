From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/4] appletalk: fix checkpatch errors with space required or prohibited
Date: Fri, 14 Feb 2014 15:43:43 +0800
Message-ID: <1392363826-8256-2-git-send-email-wangweidong1@huawei.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:19531 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbaBNHoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:44:07 -0500
In-Reply-To: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors while the space is required or prohibited

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/appletalk/aarp.c | 4 ++--
 net/appletalk/ddp.c  | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index d27b86d..d1c55d8 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -926,7 +926,7 @@ static struct aarp_entry *iter_next(struct aarp_iter_state *iter, loff_t *pos)
 	struct aarp_entry *entry;
 
  rescan:
-	while(ct < AARP_HASH_SIZE) {
+	while (ct < AARP_HASH_SIZE) {
 		for (entry = table[ct]; entry; entry = entry->next) {
 			if (!pos || ++off == *pos) {
 				iter->table = table;
@@ -995,7 +995,7 @@ static const char *dt2str(unsigned long ticks)
 {
 	static char buf[32];
 
-	sprintf(buf, "%ld.%02ld", ticks / HZ, ((ticks % HZ) * 100 ) / HZ);
+	sprintf(buf, "%ld.%02ld", ticks / HZ, ((ticks % HZ) * 100) / HZ);
 
 	return buf;
 }
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 02806c6..a878df9 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -936,11 +936,11 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 	int i, copy;
 
 	/* checksum stuff in header space */
-	if ( (copy = start - offset) > 0) {
+	if ((copy = start - offset) > 0) {
 		if (copy > len)
 			copy = len;
 		sum = atalk_sum_partial(skb->data + offset, copy, sum);
-		if ( (len -= copy) == 0)
+		if ((len -= copy) == 0)
 			return sum;
 
 		offset += copy;
@@ -1151,7 +1151,7 @@ static int atalk_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 
 		at->src_net  = addr->sat_addr.s_net = ap->s_net;
-		at->src_node = addr->sat_addr.s_node= ap->s_node;
+		at->src_node = addr->sat_addr.s_node = ap->s_node;
 	} else {
 		err = -EADDRNOTAVAIL;
 		if (!atalk_find_interface(addr->sat_addr.s_net,
-- 
1.7.12
