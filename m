From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] netfilter: fix non-ANSI func. decl.
Date: Tue, 5 Dec 2006 19:37:13 -0800
Message-ID: <20061205193713.e6f106a3.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35955 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759861AbWLFDgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 22:36:48 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix non-ANSI function declaration:
net/netfilter/nf_conntrack_core.c:1096:25: warning: non-ANSI function declaration of function 'nf_conntrack_flush'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/netfilter/nf_conntrack_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.19-git7.orig/net/netfilter/nf_conntrack_core.c
+++ linux-2.6.19-git7/net/netfilter/nf_conntrack_core.c
@@ -1093,7 +1093,7 @@ static void free_conntrack_hash(struct l
 			   get_order(sizeof(struct list_head) * size));
 }
 
-void nf_conntrack_flush()
+void nf_conntrack_flush(void)
 {
 	nf_ct_iterate_cleanup(kill_all, NULL);
 }


---
