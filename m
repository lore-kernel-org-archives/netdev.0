From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] xfrm6: Remove commented out function call to xfrm6_input_fini
Date: Thu, 22 Nov 2012 09:02:42 +0100
Message-ID: <1353571362-6774-5-git-send-email-steffen.klassert@secunet.com>
References: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36099 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932384Ab2KVTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:01:18 -0500
In-Reply-To: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm6_input_fini() is not in the tree since more than 10 years,
so remove the commented out function call.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6ce4a4f..c984413 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -356,7 +356,6 @@ void xfrm6_fini(void)
 	if (sysctl_hdr)
 		unregister_net_sysctl_table(sysctl_hdr);
 #endif
-	//xfrm6_input_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
 	dst_entries_destroy(&xfrm6_dst_ops);
-- 
1.7.9.5
