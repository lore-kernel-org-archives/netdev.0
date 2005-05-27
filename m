From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [8/10] [IPSEC] Use NLMSG_LENGTH in xfrm_exp_state_notify
Date: Fri, 27 May 2005 21:15:34 +1000
Message-ID: <20050527111534.GH4545@gondor.apana.org.au>
References: <20050527110730.GA4424@gondor.apana.org.au> <20050527110816.GA4545@gondor.apana.org.au> <20050527110852.GB4545@gondor.apana.org.au> <20050527110929.GC4545@gondor.apana.org.au> <20050527111007.GD4545@gondor.apana.org.au> <20050527111037.GE4545@gondor.apana.org.au> <20050527111140.GF4545@gondor.apana.org.au> <20050527111458.GG4545@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fmEUq8M7S0s+Fl0V"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527111458.GG4545@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fmEUq8M7S0s+Fl0V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Small fixup to use netlink macros instead of hardcoding.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--fmEUq8M7S0s+Fl0V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p10.patch"

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1114,9 +1114,9 @@ nlmsg_failure:
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_user_expire));
 
-	/* fix to do alloc using NLM macros */
-	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
+	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 

--fmEUq8M7S0s+Fl0V--
