From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 07:55:36 -0500 (EST)
Message-ID: <1331637866.93068.1358686536347.JavaMail.root@elliptictech.com>
References: <1358658381.5743.44.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Mike Galbraith <bitbucket@online.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358658381.5743.44.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Mike Galbraith" <bitbucket@online.de>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>, "David Miller"
> <davem@davemloft.net>, "steffen klassert" <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au,
> linux-kernel@vger.kernel.org, netdev@vger.kernel.org, "Michal Kubecek" <mkubecek@suse.cz>
> Sent: Sunday, 20 January, 2013 12:06:21 AM
> Subject: Re: IPsec AH use of ahash
> 
> On Sat, 2013-01-19 at 05:30 -0500, Tom St Denis wrote:
> 
> > For those of us who do Kernel development during business hours
> > it's
> > hard to justify the work when the path to mainline is convoluted
> > and
> > landmined.
> 
> Sounds as though any patches you submit land on your dinner plate
> just
> like potatoes.  Hand the cook a pot of half peeled potatoes, he/she
> may
> say try again.  The result of a little extra effort is tastier taters
> for everybody feasting at the common table.. including you.

No, in reality what happened is the chef made potatos [incorrectly] got busy and asked others to help out and make more potatos.  Then came back and said ...

from ah4.c (which I copied into foo4.c to prove a point) ... that is currently in the kernel

WARNING: networking block comments put the trailing */ on a separate line
#94: FILE: net/ipv4/foo4.c:76:
+ * for validity, so paranoia is not required. */

ERROR: spaces required around that '<' (ctx:VxV)
#112: FILE: net/ipv4/foo4.c:94:
+		if (optlen<2 || optlen>l)
 		          ^

ERROR: spaces required around that '>' (ctx:VxV)
#112: FILE: net/ipv4/foo4.c:94:
+		if (optlen<2 || optlen>l)
 		                      ^

ERROR: do not use assignment in if condition
#180: FILE: net/ipv4/foo4.c:162:
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)

WARNING: line over 80 characters
#223: FILE: net/ipv4/foo4.c:205:
+		ah->hdrlen  = (XFRM_ALIGN4(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;

WARNING: line over 80 characters
#225: FILE: net/ipv4/foo4.c:207:
+		ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;

ERROR: spaces required around that ':' (ctx:VxW)
#281: FILE: net/ipv4/foo4.c:263:
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
 	                                                           ^

WARNING: networking block comments put the trailing */ on a separate line
#337: FILE: net/ipv4/foo4.c:319:
+	 * so... Later this can change. */

ERROR: do not use assignment in if condition
#345: FILE: net/ipv4/foo4.c:327:
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)

ERROR: spaces required around that ':' (ctx:VxW)
#395: FILE: net/ipv4/foo4.c:377:
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
 	                                                           ^

WARNING: space prohibited between function name and open parenthesis '('
#407: FILE: net/ipv4/foo4.c:389:
+	kfree (work_iph);

WARNING: line over 80 characters
#416: FILE: net/ipv4/foo4.c:398:
+	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));

WARNING: line over 80 characters
#429: FILE: net/ipv4/foo4.c:411:
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,

WARNING: networking block comments don't use an empty /* line, use /* Comment...
#466: FILE: net/ipv4/foo4.c:448:
+
+	/*

ERROR: that open brace { should be on the previous line
#522: FILE: net/ipv4/foo4.c:504:
+static const struct xfrm_type ah_type =
+{

WARNING: please, no space before tabs
#525: FILE: net/ipv4/foo4.c:507:
+^I.proto^I     ^I= IPPROTO_AH,$

total: 7 errors, 9 warnings, 547 lines checked


So going back to my original point ... Had I upgraded AH4/AH6 to use AEAD you guys would have rejected it because of style issues too?

The maintainers are not MAINTAINING the code.  Then they call out sous-chef's that come by offering to contribute because the recipe is not being followed...

Tom
