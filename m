From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] netns: rename unregister_pernet_subsys parameter
Date: Sun, 25 Apr 2010 09:41:39 +0200
Message-ID: <20100425074138.GA2866@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab0DYHln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 03:41:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stay consistent with other functions and with comment also and name
pernet_operations parameter properly.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index bd8c471..69a20bf 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -469,10 +469,10 @@ EXPORT_SYMBOL_GPL(register_pernet_subsys);
  *	addition run the exit method for all existing network
  *	namespaces.
  */
-void unregister_pernet_subsys(struct pernet_operations *module)
+void unregister_pernet_subsys(struct pernet_operations *ops)
 {
 	mutex_lock(&net_mutex);
-	unregister_pernet_operations(module);
+	unregister_pernet_operations(ops);
 	mutex_unlock(&net_mutex);
 }
 EXPORT_SYMBOL_GPL(unregister_pernet_subsys);
