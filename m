From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] NET: Set NLM_F_MULTI for neighbour rtnetlink messages to userspace
Date: Thu, 20 Jan 2005 16:26:17 +0100
Message-ID: <20050120152617.GF26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.29-bk1.orig/net/core/neighbour.c	2005-01-20 15:36:15.000000000 +0100
+++ linux-2.4.29-bk1/net/core/neighbour.c	2005-01-20 16:23:10.000000000 +0100
@@ -1469,6 +1469,7 @@
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ndm));
 	ndm = NLMSG_DATA(nlh);
+	nlh->nlmsg_flags = pid ? NLM_F_MULTI : 0;
 	ndm->ndm_family = n->ops->family;
 	ndm->ndm_flags = n->flags;
 	ndm->ndm_type = n->type;
