From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] NET: Set NLM_F_MULTI for neighbour rtnetlink messages to userspace
Date: Thu, 20 Jan 2005 15:31:35 +0100
Message-ID: <20050120143135.GE26856@postel.suug.ch>
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

--- linux-2.6.10-bk14.orig/net/core/neighbour.c	2005-01-13 10:56:33.000000000 +0100
+++ linux-2.6.10-bk14/net/core/neighbour.c	2005-01-20 15:29:14.000000000 +0100
@@ -1556,6 +1556,7 @@
 					 sizeof(struct ndmsg));
 	struct ndmsg *ndm = NLMSG_DATA(nlh);
 
+	nlh->nlmsg_flags = pid ? NLM_F_MULTI : 0;
 	ndm->ndm_family	 = n->ops->family;
 	ndm->ndm_flags	 = n->flags;
 	ndm->ndm_type	 = n->type;
