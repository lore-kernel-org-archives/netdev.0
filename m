From: jamal <hadi@cyberus.ca>
Subject: patch2: del/get byid
Date: Wed, 27 Apr 2005 22:11:24 -0400
Message-ID: <1114654284.7663.50.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-yb9JkUB3JzVPV1nxlh3i"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-yb9JkUB3JzVPV1nxlh3i
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This is definetely a bug. It doesnt seem like get/del by index worked.
For some reason i thought i tested this before and it worked.

cheers,
jamal

--=-yb9JkUB3JzVPV1nxlh3i
Content-Disposition: attachment; filename=polid_p3
Content-Type: text/plain; name=polid_p3; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_policy.c	2005/04/27 15:35:50	1.2
+++ b/net/xfrm/xfrm_policy.c	2005/04/27 20:23:07
@@ -417,7 +417,7 @@
 	struct xfrm_policy *pol, **p;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[id & 7]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
 		if (pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete)

--=-yb9JkUB3JzVPV1nxlh3i--
