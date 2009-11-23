From: Joe Perches <joe@perches.com>
Subject: [net-next-2.6 PATCH] net/ipv6: Move && and || to end of previous
 line
Date: Mon, 23 Nov 2009 10:58:44 -0800
Message-ID: <1259002724.16503.83.camel@Joe-Laptop.home>
References: <4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>
	 <20091122.163112.80105623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1092 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbZKWS6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 13:58:39 -0500
In-Reply-To: <20091122.163112.80105623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-22 at 16:31 -0800, David Miller wrote:
> It should be of the form:
> 	if (x &&
> 	    y)
> 
> or:
> 	if (x && y)
> 
> Fix patches, rather than complaints, for existing cases where things
> do not follow this pattern are certainly welcome.

Compile tested only.

Signed-off-by: Joe Perches <joe@perches.com>

 net/ipv6/ip6_flowlabel.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 7712578..593a67e 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -377,8 +377,8 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 		goto done;
 	fl->share = freq->flr_share;
 	addr_type = ipv6_addr_type(&freq->flr_dst);
-	if ((addr_type&IPV6_ADDR_MAPPED)
-	    || addr_type == IPV6_ADDR_ANY) {
+	if ((addr_type & IPV6_ADDR_MAPPED) ||
+	    addr_type == IPV6_ADDR_ANY) {
 		err = -EINVAL;
 		goto done;
 	}
@@ -421,8 +421,8 @@ static int mem_check(struct sock *sk)
 
 	if (room <= 0 ||
 	    ((count >= FL_MAX_PER_SOCK ||
-	     (count > 0 && room < FL_MAX_SIZE/2) || room < FL_MAX_SIZE/4)
-	     && !capable(CAP_NET_ADMIN)))
+	      (count > 0 && room < FL_MAX_SIZE/2) || room < FL_MAX_SIZE/4) &&
+	     !capable(CAP_NET_ADMIN)))
 		return -ENOBUFS;
 
 	return 0;


