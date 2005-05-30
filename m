From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv6/ipv6_syms.c: unexport fl6_sock_lookup
Date: Mon, 30 May 2005 22:56:53 +0200
Message-ID: <20050530205653.GZ10441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261754AbVE3VNG@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no usage of this EXPORT_SYMBOL in the kernel.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

---

This patch was already sent on:
- 7 May 2005

--- linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c.old	2005-05-05 22:23:17.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c	2005-05-05 22:23:23.000000000 +0200
@@ -37,5 +37,4 @@
 EXPORT_SYMBOL(xfrm6_rcv);
 #endif
 EXPORT_SYMBOL(rt6_lookup);
-EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
