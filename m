From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] [IPV6]: Fix hardcoded removing of old module code
Date: Wed, 13 Feb 2008 17:37:47 +0800
Message-ID: <47B2BA6B.2000003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64294 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751849AbYBMJkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 04:40:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty hardcoded the old module code.
We can remove it now.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/af_inet6.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bddac0e..f0aa977 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -752,14 +752,6 @@ static int __init inet6_init(void)
 
 	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));
 
-#ifdef MODULE
-#if 0 /* FIXME --RR */
-	if (!mod_member_present(&__this_module, can_unload))
-	  return -EINVAL;
-
-	__this_module.can_unload = &ipv6_unload;
-#endif
-#endif
 	err = proto_register(&tcpv6_prot, 1);
 	if (err)
 		goto out;
-- WCN

