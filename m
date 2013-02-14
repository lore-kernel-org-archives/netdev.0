From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/7] xfrm: remove unused xfrm4_policy_fini()
Date: Thu, 14 Feb 2013 12:47:25 +0100
Message-ID: <1360842447-3344-6-git-send-email-steffen.klassert@secunet.com>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44547 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934314Ab3BNLr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:57 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>

Function xfrm4_policy_fini() is unused since xfrm4_fini() was
removed in 2.6.11.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 3be0ac2..0e28383 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -270,15 +270,6 @@ static void __init xfrm4_policy_init(void)
 	xfrm_policy_register_afinfo(&xfrm4_policy_afinfo);
 }
 
-static void __exit xfrm4_policy_fini(void)
-{
-#ifdef CONFIG_SYSCTL
-	if (sysctl_hdr)
-		unregister_net_sysctl_table(sysctl_hdr);
-#endif
-	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
-}
-
 void __init xfrm4_init(void)
 {
 	dst_entries_init(&xfrm4_dst_ops);
-- 
1.7.9.5
