From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: Mon, 11 Apr 2005 07:27:07 +1000
Message-ID: <20050410212707.GA30337@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <1113049844.1090.23.camel@jzny.localdomain> <20050409192926.GA9423@gondor.apana.org.au> <20050409200306.GA9660@gondor.apana.org.au> <1113142244.1088.287.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113142244.1088.287.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 10, 2005 at 10:10:44AM -0400, jamal wrote:
> On Sat, 2005-04-09 at 16:03, Herbert Xu wrote:
> 
> > xfrm_policy_kill can only be called by the one who removed the
> > policy from the linked list.  Therefore it can never fail.
> > 
> > If this logic is wrong we will be getting fat warnings from
> > xfrm_policy_kill.
> 
> The warning will kick in but it may be as rare as the issue of a delete
> and expire happening on the same policy that your patch was supposed to
> stop ;->

What I am saying is that this is impossible.  If it really bothers you
we can turn the WARN_ON into a BUG.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
