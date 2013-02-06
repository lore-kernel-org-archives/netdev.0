From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec-next v2 1/2] xfrm: remove unused xfrm4_policy_fini()
Date: Wed,  6 Feb 2013 10:46:23 +0100 (CET)
Message-ID: <1c95e237b69917707bd1148e119e7eb14b7947bc.1360143430.git.mkubecek@suse.cz>
References: <cover.1360143430.git.mkubecek@suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58504 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab3BFJqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 04:46:24 -0500
In-Reply-To: <cover.1360143430.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function xfrm4_policy_fini() is unused since xfrm4_fini() was
removed in 2.6.11.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
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
1.7.10.4
