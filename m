From: jamal <hadi@cyberus.ca>
Subject: Re: Resend: Re: PATCH: IPSEC acquire in presence of multiple
	managers
Date: 26 Mar 2005 15:13:15 -0500
Message-ID: <1111867995.1089.918.camel@jzny.localdomain>
References: <1111795927.1089.749.camel@jzny.localdomain>
	 <1111862131.1092.872.camel@jzny.localdomain>
	 <20050326192740.GA9638@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326192740.GA9638@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sat, 2005-03-26 at 14:27, Herbert Xu wrote:
> On Sat, Mar 26, 2005 at 01:35:31PM -0500, jamal wrote:
> >
> >  int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
> >  {
> > -	int err = -EINVAL;
> > +	int err = -EINVAL, acqret = -EINVAL;
> 
> BTW, you don't need to initialise acqret here since it's only used
> inside the loop and is always assigned unconditionally..

fair enough. You seem to have no major issues with the patch0 that i
sent. I can submit that instead to Dave with the few tweaks + this
change. Sounds good?

cheers,
jamal
