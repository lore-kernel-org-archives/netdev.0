From: akpm@osdl.org
Subject: [patch 1/4] tr.c warning fix
Date: Wed, 23 Jun 2004 23:30:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406240631.i5O6VSZ31238@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



A few things popped up when using current gcc cvs.

net/802/tr.c: In function `tr_header':
net/802/tr.c:113: warning: 'trh' is used uninitialized in this function

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/802/tr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/802/tr.c~tr-warning-fixes net/802/tr.c
--- 25/net/802/tr.c~tr-warning-fixes	2004-06-23 22:55:28.191161688 -0700
+++ 25-akpm/net/802/tr.c	2004-06-23 22:55:39.811395144 -0700
@@ -110,7 +110,7 @@ int tr_header(struct sk_buff *skb, struc
 	 */
 	if (type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP)
 	{
-		struct trllc *trllc=(struct trllc *)(trh+1);
+		struct trllc *trllc;
 
 		hdr_len = sizeof(struct trh_hdr) + sizeof(struct trllc);
 		trh = (struct trh_hdr *)skb_push(skb, hdr_len);
_
