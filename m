From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net: ipv6: change %8s to %s for seq_printf of if6_seq_stop
Date: Mon, 05 Nov 2012 19:17:04 +0800
Message-ID: <5097A030.5030209@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:40422 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab2KELQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 06:16:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  the length of ifp->idev->dev->name is 16 (IFNAMSIZ)
  in seq_printf, it is not suitable to use %8s for rt->dst.dev->name.
  so change it to %s, since each line has not been solid any more.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..9f728a8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3281,7 +3281,7 @@ static void if6_seq_stop(struct seq_file *seq,
void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
+	seq_printf(seq, "%pi6 %02x %02x %02x %02x %s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
-- 
1.7.9.5
