From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [IPSEC] Remove unnecessary inet_ecn.h inclusions
Date: Mon, 2 Aug 2004 19:31:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802093153.GA19706@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is a couple of clean-ups stemming from the xfrm_output change.

I should've removed the inet_ecn.h inclusions in that change as the
ECN code has been moved to xfrm[46]_output.c.  This patch does exactly
that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p1

===== net/ipv4/ah4.c 1.38 vs edited =====
--- 1.38/net/ipv4/ah4.c	2004-07-30 21:16:40 +10:00
+++ edited/net/ipv4/ah4.c	2004-08-02 17:44:36 +10:00
@@ -1,6 +1,5 @@
 #include <linux/config.h>
 #include <linux/module.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/ah.h>
===== net/ipv4/esp4.c 1.53 vs edited =====
--- 1.53/net/ipv4/esp4.c	2004-07-12 20:00:21 +10:00
+++ edited/net/ipv4/esp4.c	2004-08-02 17:44:49 +10:00
@@ -1,6 +1,5 @@
 #include <linux/config.h>
 #include <linux/module.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/esp.h>
===== net/ipv4/ipcomp.c 1.28 vs edited =====
--- 1.28/net/ipv4/ipcomp.c	2004-07-12 20:00:21 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-08-02 17:44:55 +10:00
@@ -18,7 +18,6 @@
 #include <asm/scatterlist.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
===== net/ipv4/xfrm4_tunnel.c 1.13 vs edited =====
--- 1.13/net/ipv4/xfrm4_tunnel.c	2004-07-12 20:00:21 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-02 17:44:30 +10:00
@@ -7,7 +7,6 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/inet_ecn.h>
 
 int xfrm4_tunnel_check_size(struct sk_buff *skb)
 {
===== net/ipv6/ah6.c 1.38 vs edited =====
--- 1.38/net/ipv6/ah6.c	2004-08-02 07:15:03 +10:00
+++ edited/net/ipv6/ah6.c	2004-08-02 17:45:20 +10:00
@@ -26,7 +26,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/ah.h>
 #include <linux/crypto.h>
===== net/ipv6/esp6.c 1.34 vs edited =====
--- 1.34/net/ipv6/esp6.c	2004-08-02 07:15:03 +10:00
+++ edited/net/ipv6/esp6.c	2004-08-02 17:45:23 +10:00
@@ -26,7 +26,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/esp.h>
===== net/ipv6/ipcomp6.c 1.19 vs edited =====
--- 1.19/net/ipv6/ipcomp6.c	2004-08-02 07:15:03 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-08-02 17:45:25 +10:00
@@ -32,7 +32,6 @@
  */
 #include <linux/config.h>
 #include <linux/module.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/ipcomp.h>

--GvXjxJ+pjyke8COw--
