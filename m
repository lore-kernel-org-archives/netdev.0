From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix ip_conntrack_put prototype
Date: Tue, 26 Jul 2005 16:56:59 +0200
Message-ID: <20050726145659.GR3160@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261850AbVGZPAy@vger.kernel.org>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function is not inline.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/include/linux/netfilter_ipv4/ip_conntrack.h.old	2005-07-26 13:44:20.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/include/linux/netfilter_ipv4/ip_conntrack.h	2005-07-26 13:45:41.000000000 +0200
@@ -236,7 +236,7 @@
 }
 
 /* decrement reference count on a conntrack */
-extern inline void ip_conntrack_put(struct ip_conntrack *ct);
+extern void ip_conntrack_put(struct ip_conntrack *ct);
 
 /* call to create an explicit dependency on ip_conntrack. */
 extern void need_ip_conntrack(void);
