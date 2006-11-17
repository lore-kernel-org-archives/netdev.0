From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv6/sit.c: make 2 functions static
Date: Fri, 17 Nov 2006 18:02:32 +0100
Message-ID: <20061117170232.GH31879@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1424773AbWKQRCj@vger.kernel.org>
To: davem@davemloft.net
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes two needlessly global functions static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/ipip.h |    4 ----
 net/ipv6/sit.c     |    4 ++--
 2 files changed, 2 insertions(+), 6 deletions(-)

--- linux-2.6.19-rc5-mm2/include/net/ipip.h.old	2006-11-17 16:58:59.000000000 +0100
+++ linux-2.6.19-rc5-mm2/include/net/ipip.h	2006-11-17 16:59:06.000000000 +0100
@@ -44,8 +44,4 @@
 	}								\
 } while (0)
 
-
-extern int	sit_init(void);
-extern void	sit_cleanup(void);
-
 #endif
--- linux-2.6.19-rc5-mm2/net/ipv6/sit.c.old	2006-11-17 16:37:49.000000000 +0100
+++ linux-2.6.19-rc5-mm2/net/ipv6/sit.c	2006-11-17 16:38:53.000000000 +0100
@@ -809,7 +809,7 @@
 	}
 }
 
-void __exit sit_cleanup(void)
+static void __exit sit_cleanup(void)
 {
 	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
 
@@ -819,7 +819,7 @@
 	rtnl_unlock();
 }
 
-int __init sit_init(void)
+static int __init sit_init(void)
 {
 	int err;
 
