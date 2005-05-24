From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] : bug fix in multipath drr code.
Date: Tue, 24 May 2005 17:11:46 +1000
Message-ID: <20050524071146.GA30995@gondor.apana.org.au>
References: <4291CBFF.6080106@calsoftinc.com> <20050523232224.GA25349@gondor.apana.org.au> <4292CDCE.2090600@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: pravin b shelar <pravins@calsoftinc.com>
Content-Disposition: inline
In-Reply-To: <4292CDCE.2090600@calsoftinc.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 12:16:38PM +0530, pravin b shelar wrote:
>
> >The multipath_comparekeys isn't necessary either.
>
> In concurrent invocations of drr_select_route() last_selection will
> change to different route.
> So in that case we can not  use last_selection route on basis of
> FLOWI_FLAG_MULTIPATHOLDROUTE flag only, since old
> route might be totally different due another invocation of same function.
> So, I think multipath_comparekeys is necessary.

Indeed.  In fact this whole MULTIPATHOLDROUTE thing can't possibly
work at all.  I'd suggest that it be removed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
