From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Fix ipv6_ifa_notify race
Date: Fri, 19 Nov 2004 11:36:58 -0500 (EST)
Message-ID: <20041119.113658.109538461.yoshfuji@linux-ipv6.org>
References: <4197AC20.6020707@pobox.com>
	<E1CTR5h-0006ac-00@gondolin.me.apana.org.au>
	<20041119094924.GA3726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, acme@conectiva.com.br,
        jgarzik@pobox.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20041119094924.GA3726@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041119094924.GA3726@gondor.apana.org.au> (at Fri, 19 Nov 2004 20:49:24 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Mon, Nov 15, 2004 at 07:35:17AM +1100, Herbert Xu wrote:
> > 
> > Could you please apply this patch and see if the warning triggers
> > before the underflows start coming in? We already know that if it
> > does then it can cause underflows but I want to make sure that
> > this is what's causing your problems.
> 
> Well I think it's time to fix this bug so that we don't release
> 2.6.10 with it.
> 
> This is only a temporary hack that should be rolled back once
> the locking in addrconf.c is fixed properly.  At the moment
> the locking is just too twisted to fix properly for 2.6.10 :(

This patch is wrong (dead is not protected appropriately).
I have another idea to fix this.
I'll send it tomorrow.

--yoshfuji
