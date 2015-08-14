From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next] ipv6: trivial whitespace fix
Date: Fri, 14 Aug 2015 22:43:38 +0100
Message-ID: <1439588618-7100-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:39132 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751748AbbHNVty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 17:49:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change brace placement to be in line with coding standards

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/udp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e51fc3e..0aba654 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1496,7 +1496,8 @@ int __net_init udp6_proc_init(struct net *net)
 	return udp_proc_register(net, &udp6_seq_afinfo);
 }
 
-void udp6_proc_exit(struct net *net) {
+void udp6_proc_exit(struct net *net)
+{
 	udp_proc_unregister(net, &udp6_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
-- 
1.9.1
