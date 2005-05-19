From: jamal <hadi@cyberus.ca>
Subject: another git excuse patch
Date: Wed, 18 May 2005 21:23:45 -0400
Message-ID: <1116465825.6240.27.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-OeXu7fNqfFdekE+h/zBq"
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-OeXu7fNqfFdekE+h/zBq
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Against Herbert's ipsec-2.6.git. 

Small fixup to use netlink macros instead of hardcoding.
Signed-off-by: Jamal Hadi Salim


cheers,
jamal

--=-OeXu7fNqfFdekE+h/zBq
Content-Disposition: attachment; filename=ipsec12_p
Content-Type: text/plain; name=ipsec12_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

net/xfrm/xfrm_user.c: needs update
Index: net/xfrm/xfrm_user.c
===================================================================
--- c24f26cfe03081d10a3a3f66d5d3e503395090b4/net/xfrm/xfrm_user.c  (mode:100644)
+++ uncommitted/net/xfrm/xfrm_user.c  (mode:100644)
@@ -1114,9 +1114,9 @@
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_user_expire));
 
-	/* fix to do alloc using NLM macros */
-	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
+	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 

--=-OeXu7fNqfFdekE+h/zBq--
