From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [11/*] [NET] Move dst_release out of dst->ops->check
Date: Tue, 08 Mar 2005 06:50:46 -0600 (CST)
Message-ID: <20050308.065046.66114517.yoshfuji@linux-ipv6.org>
References: <20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
In-Reply-To: <20050308102741.GA23468@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050308102741.GA23468@gondor.apana.org.au> (at Tue, 8 Mar 2005 21:27:41 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

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

I agree.

--yoshfuji
