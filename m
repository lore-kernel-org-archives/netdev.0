From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net: sched: fix typo in net_device ifdef
Date: Mon, 11 May 2015 19:28:49 +0200
Message-ID: <45ab7891f81f127f688ac20fdac86d5c13afed57.1431364704.git.daniel@iogearbox.net>
Cc: fengguang.wu@intel.com, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60146 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbbEKR3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:29:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should have been #ifdef not #if.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Very sorry for the typo.

 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c4e1caf..a6d706b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1655,7 +1655,7 @@ struct net_device {
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
-#if CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *ingress_cl_list;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
-- 
1.9.3
