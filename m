From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv6/: small cleanups
Date: Sat, 7 Jan 2006 19:17:23 +0100
Message-ID: <20060107181723.GP3774@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750938AbWAGSRZ@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- addrconf.c: make addrconf_dad_stop() static
- inet6_connection_sock.c should #include <net/inet6_connection_sock.h>
  for getting the prototypes of it's global functions


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ipv6/addrconf.c              |    2 +-
 net/ipv6/inet6_connection_sock.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.15-mm2-full/net/ipv6/addrconf.c.old	2006-01-07 17:30:04.000000000 +0100
+++ linux-2.6.15-mm2-full/net/ipv6/addrconf.c	2006-01-07 17:30:13.000000000 +0100
@@ -1228,7 +1228,7 @@
 
 /* Gets referenced address, destroys ifaddr */
 
-void addrconf_dad_stop(struct inet6_ifaddr *ifp)
+static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 {
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
--- linux-2.6.15-mm2-full/net/ipv6/inet6_connection_sock.c.old	2006-01-07 17:30:42.000000000 +0100
+++ linux-2.6.15-mm2-full/net/ipv6/inet6_connection_sock.c	2006-01-07 17:30:57.000000000 +0100
@@ -25,6 +25,7 @@
 #include <net/inet_hashtables.h>
 #include <net/ip6_route.h>
 #include <net/sock.h>
+#include <net/inet6_connection_sock.h>
 
 int inet6_csk_bind_conflict(const struct sock *sk,
 			    const struct inet_bind_bucket *tb)
