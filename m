From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 3/4] ipv6: Use IS_ERR_OR_NULL().
Date: Wed, 23 Jan 2013 01:32:54 +0900
Message-ID: <50FEBF36.5060001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51859 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754468Ab3AVQcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:32:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 420e563..80d5980 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1051,7 +1051,7 @@ retry:
 		ipv6_add_addr(idev, &addr, tmp_plen,
 			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
 			      addr_flags) : NULL;
-	if (!ift || IS_ERR(ift)) {
+	if (IS_ERR_OR_NULL(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
 		pr_info("%s: retry temporary address regeneration\n", __func__);
@@ -2079,7 +2079,7 @@ ok:
 						    addr_type&IPV6_ADDR_SCOPE_MASK,
 						    addr_flags);
 
-			if (!ifp || IS_ERR(ifp)) {
+			if (IS_ERR_OR_NULL(ifp)) {
 				in6_dev_put(in6_dev);
 				return;
 			}
-- 
1.7.9.5
