From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv6/tcp_ipv6.c: Use compressed IPv6 address
Date: Sat, 02 Jan 2010 15:51:41 -0800
Message-ID: <1262476301.1932.90.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1473 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab0ABXvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jan 2010 18:51:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "[compressed ipv6]:port" form suggested by:
http://tools.ietf.org/id/draft-ietf-6man-text-addr-representation-03.txt

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index febfd59..1c832bf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -876,7 +876,7 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash %s for (%pI6, %u)->(%pI6, %u)\n",
+			printk(KERN_INFO "MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
 			       genhash ? "failed" : "mismatch",
 			       &ip6h->saddr, ntohs(th->source),
 			       &ip6h->daddr, ntohs(th->dest));



