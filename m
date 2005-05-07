From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/7] [IPSEC] Add complete xfrm event notification
Date: Sun, 8 May 2005 05:42:44 +1000
Message-ID: <20050507194244.GB28991@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au> <427CD5F5.9010605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427CD5F5.9010605@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2005 at 04:51:33PM +0200, Patrick McHardy wrote:
> 
> This introduces a leak when xfrm_state_add()/xfrm_state_update()
> fail. We hold two references (one from xfrm_state_alloc(), one
> from xfrm_state_hold()), but only drop one. We need to take the
> reference because the reference from xfrm_state_alloc() can
> be dropped by __xfrm_state_delete(), so the fix is to drop both
> references on error. Same problem in xfrm_user.c.

Patch applied.  Thanks for plugging the leaks :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
