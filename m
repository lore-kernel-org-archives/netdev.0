From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: remove duplicated declaration of ip6_fragment()
Date: Wed, 23 Jan 2013 11:22:07 +0800
Message-ID: <1358911327-12122-1-git-send-email-amwang@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145Ab3AWDWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 22:22:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is declared in:
include/net/ip6_route.h:187:int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));

and net/ip6_route.h is already included.

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7eee94c..7dea45a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,8 +56,6 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
-
 int __ip6_local_out(struct sk_buff *skb)
 {
 	int len;
