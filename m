From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [9/*] [IPSEC] Check dst validity harder in xfrm_bundle_ok
Date: Mon, 7 Mar 2005 09:32:09 -0800
Message-ID: <20050307093209.023c3a1a.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307103536.GB7137@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Mar 2005 21:35:36 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> There is another bug in xfrm_bundle_ok where I forgot to
> check the validity of xdst->route.  In fact, the check
> on dst->path isn't strong enough either.  For IPv6 entries,
> dst->path->obsolete is always negative until you call
> ipv6_dst_check.  So we really need to do that here.
> 
> Here's the patch to fix those two problems.  Yes I know
> my dst_check implementation is lame.  I'll come back and
> fix up all the dst_check functions by moving their dst_release
> calls out.  It proves that you were right in that IPv6 dst
> leak thread :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
