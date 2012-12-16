From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] netlink: change presentation of portid in procfs to unsigned
Date: Sun, 16 Dec 2012 02:09:19 +0100
Message-ID: <20121216010919.GA1528@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33654 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab2LPBJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 20:09:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4da797f..fdb7494 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2059,7 +2059,7 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%pK %-3d %-6d %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
+		seq_printf(seq, "%pK %-3d %-6u %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->portid,
