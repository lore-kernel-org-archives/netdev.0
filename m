From: akpm@osdl.org
Subject: [patch 2/4] fc.c warning fix
Date: Wed, 23 Jun 2004 23:30:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406240631.i5O6VUZ31243@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/802/fc.c: In function `fc_header':
net/802/fc.c:50: warning: 'fch' is used uninitialized in this function

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/802/fc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/802/fc.c~fc-warning-fix net/802/fc.c
--- 25/net/802/fc.c~fc-warning-fix	2004-06-23 23:30:09.627735232 -0700
+++ 25-akpm/net/802/fc.c	2004-06-23 23:30:09.630734776 -0700
@@ -47,7 +47,7 @@ int fc_header(struct sk_buff *skb, struc
 	 */
 	if (type == ETH_P_IP || type == ETH_P_ARP)
 	{
-		struct fcllc *fcllc=(struct fcllc *)(fch+1);
+		struct fcllc *fcllc;
 
 		hdr_len = sizeof(struct fch_hdr) + sizeof(struct fcllc);
 		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
_
