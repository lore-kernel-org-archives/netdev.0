From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sunrpc: fix missing kernel-doc
Date: Fri, 25 Apr 2008 08:57:50 -0700
Message-ID: <20080425085750.8c064403.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, torvalds <torvalds@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19297 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606AbYDYQFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 12:05:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix missing sunrpc kernel-doc:

Warning(linux-2.6.25-git7//net/sunrpc/xprt.c:451): No description found for parameter 'action'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sunrpc/xprt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.25-git7.orig/net/sunrpc/xprt.c
+++ linux-2.6.25-git7/net/sunrpc/xprt.c
@@ -445,7 +445,7 @@ EXPORT_SYMBOL_GPL(xprt_wake_pending_task
 /**
  * xprt_wait_for_buffer_space - wait for transport output buffer to clear
  * @task: task to be put to sleep
- *
+ * @action: function pointer to be executed after wait
  */
 void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
 {
