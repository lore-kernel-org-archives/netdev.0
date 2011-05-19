From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] net: ping: fix the coding style
Date: Thu, 19 May 2011 15:16:01 +0800
Message-ID: <1305789361-5366-2-git-send-email-xiaosuo@gmail.com>
References: <1305789361-5366-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:41085 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab1ESHRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:17:11 -0400
Received: by mail-pz0-f46.google.com with SMTP id 9so1059935pzk.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 00:17:11 -0700 (PDT)
In-Reply-To: <1305789361-5366-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The characters in a line should be no more than 80.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/ping.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 5f9e2d1..1f3bb11 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -187,7 +187,8 @@ exit:
 	return sk;
 }
 
-static void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t *high)
+static void inet_get_ping_group_range_net(struct net *net, gid_t *low,
+					  gid_t *high)
 {
 	gid_t *data = net->ipv4.sysctl_ping_group_range;
 	unsigned seq;
@@ -437,7 +438,8 @@ static int ping_getfrag(void *from, char * to,
 	return 0;
 }
 
-static int ping_push_pending_frames(struct sock *sk, struct pingfakehdr *pfh, struct flowi4 *fl4)
+static int ping_push_pending_frames(struct sock *sk, struct pingfakehdr *pfh,
+				    struct flowi4 *fl4)
 {
 	struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
 
@@ -754,7 +756,9 @@ static struct sock *ping_get_first(struct seq_file *seq, int start)
 	for (state->bucket = start; state->bucket < PING_HTABLE_SIZE;
 	     ++state->bucket) {
 		struct hlist_nulls_node *node;
-		struct hlist_nulls_head *hslot = &ping_table.hash[state->bucket];
+		struct hlist_nulls_head *hslot;
+
+		hslot = &ping_table.hash[state->bucket];
 
 		if (hlist_nulls_empty(hslot))
 			continue;
