From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv6/: make two functions static
Date: Wed, 23 Nov 2005 02:23:59 +0100
Message-ID: <20051123012359.GH3963@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030302AbVKWBYE@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes two needlessly global functions static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ipv6/ip6_output.c    |    3 ++-
 net/ipv6/ipv6_sockglue.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

--- linux-2.6.15-rc1-mm2-full/net/ipv6/ip6_output.c.old	2005-11-23 02:10:08.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/net/ipv6/ip6_output.c	2005-11-23 02:10:25.000000000 +0100
@@ -774,7 +774,8 @@
 	*dst = NULL;
 	return err;
 }
-inline int ip6_ufo_append_data(struct sock *sk,
+
+static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
--- linux-2.6.15-rc1-mm2-full/net/ipv6/ipv6_sockglue.c.old	2005-11-23 02:10:43.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/net/ipv6/ipv6_sockglue.c	2005-11-23 02:11:02.000000000 +0100
@@ -628,8 +628,8 @@
 	return -EINVAL;
 }
 
-int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_opt_hdr *hdr,
-			   char __user *optval, int len)
+static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_opt_hdr *hdr,
+				  char __user *optval, int len)
 {
 	if (!hdr)
 		return 0;
