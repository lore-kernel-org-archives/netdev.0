From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [11/*] [NET] Move dst_release out of dst->ops->check
Date: Thu, 10 Mar 2005 18:17:50 -0800
Message-ID: <20050310181750.420c073d.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050308102741.GA23468@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005 21:27:41 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Mar 07, 2005 at 09:35:36PM +1100, herbert wrote:
> > 
> > Here's the patch to fix those two problems.  Yes I know
> > my dst_check implementation is lame.  I'll come back and
> > fix up all the dst_check functions by moving their dst_release
> > calls out.  It proves that you were right in that IPv6 dst
> > leak thread :)
> 
> As promised here is the patch that moves dst_release out of
> dst->ops->check.  It bloats sk_dst_check/__sk_dst_check slightly
> but they're only used in a handful of places so it isn't too bad.
> I actually counted, it's about a few hundred bytes.

Applied, thanks Herbert.
