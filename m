From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/ipv6/ipv6_syms.c: unexport fl6_sock_lookup
Date: Sat, 7 May 2005 01:20:00 +0200
Message-ID: <20050506232000.GC3590@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is no usage of this EXPORT_SYMBOL in the kernel.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c.old	2005-05-05 22:23:17.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c	2005-05-05 22:23:23.000000000 +0200
@@ -37,5 +37,4 @@
 EXPORT_SYMBOL(xfrm6_rcv);
 #endif
 EXPORT_SYMBOL(rt6_lookup);
-EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
