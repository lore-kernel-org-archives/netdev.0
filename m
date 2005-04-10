From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/4] [IPSEC] Set byid for km_event in xfrm_get_policy
Date: Sun, 10 Apr 2005 17:48:50 +1000
Message-ID: <20050410074849.GA13259@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <20050409111551.GA7378@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050409111551.GA7378@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch fixes policy deletion in xfrm_user so that it sets
km_event.data.byid.  This puts xfrm_user on par with what af_key
does in this case.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

 xfrm_user.c |    1 +
 1 files changed, 1 insertion(+)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-4

===== net/xfrm/xfrm_user.c 1.54 vs edited =====
--- 1.54/net/xfrm/xfrm_user.c	2005-04-09 20:40:43 +10:00
+++ edited/net/xfrm/xfrm_user.c	2005-04-09 20:41:29 +10:00
@@ -877,6 +877,7 @@
 					      MSG_DONTWAIT);
 		}
 	} else {
+		c.data.byid = p->index;
 		c.event = XFRM_SAP_DELETED;
 		c.seq = nlh->nlmsg_seq;
 		c.pid = nlh->nlmsg_pid;

--FCuugMFkClbJLl1L--
