From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 30 Mar 2005 21:55:59 -0500
Message-ID: <1112237759.1092.35.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
	 <1111950449.1089.938.camel@jzny.localdomain>
	 <20050330004903.GA3399@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330004903.GA3399@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert,

On Tue, 2005-03-29 at 19:49, Herbert Xu wrote:
> Hi Jamal:
> 
> On Sun, Mar 27, 2005 at 02:07:29PM -0500, jamal wrote:
> >

> > +/* callback structure passed from either netlink or pfkey */
> > +struct xfrm_sa_cb
> > +{
> > +	u32	type; /* the type of caller netlink/pfkey/other */
> > +	u32	data; /* callee to caller */
> > +	void *hdr;
> > +	struct sk_buff *skb;
> 
> I don't think we need to carry the original hdr and skb around.

Any objection to still calling it (new name) struct xfrm_sa_cb but
with only one 32 bit value in it - namely data?
This way i could add any other thing in the future in it without
changing the function call paramaters.

cheers,
jamal
