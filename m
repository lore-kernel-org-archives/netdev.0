From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] pppoe: use pppoe_pernet instead of directly
 net_generic
Date: Mon, 26 Apr 2010 13:46:12 +0200
Message-ID: <20100426114611.GC2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mostrows@earthlink.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab0DZLqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 07:46:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index cdd11ba..c059c8d 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -258,7 +258,7 @@ static inline struct pppox_sock *get_item_by_addr(struct net *net,
 	dev = dev_get_by_name_rcu(net, sp->sa_addr.pppoe.dev);
 	if (dev) {
 		ifindex = dev->ifindex;
-		pn = net_generic(net, pppoe_net_id);
+		pn = pppoe_pernet(net);
 		pppox_sock = get_item(pn, sp->sa_addr.pppoe.sid,
 				sp->sa_addr.pppoe.remote, ifindex);
 	}
