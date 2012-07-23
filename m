From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: [PATCH] ipv4: Remove redundant assignment
Date: Mon, 23 Jul 2012 22:11:21 +0800
Message-ID: <1343052681.4600.5.camel@monkey32>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:46087 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab2GWOMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 10:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is redundant to set no_addr and accept_local to 0 and then set them
with other values just after that.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 net/ipv4/fib_frontend.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f277cf0..8732cc7 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -258,7 +258,6 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 
-	no_addr = accept_local = 0;
 	no_addr = idev->ifa_list == NULL;
 
 	accept_local = IN_DEV_ACCEPT_LOCAL(idev);
