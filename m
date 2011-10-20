From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
	causes kernel oops
Date: Thu, 20 Oct 2011 11:35:41 +0200
Message-ID: <20111020093541.GA3024@gondor.apana.org.au>
References: <1319008713.17914.8.camel@edumazet-laptop> <20111019.033052.851679720607111734.davem@davemloft.net> <20111019080807.GA25099@gondor.apana.org.au> <20111020.053050.383972361986316046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111020.053050.383972361986316046.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 05:30:50AM -0400, David Miller wrote:
>
> So I'm a little confused what your suggestion for rc10 really
> is :-)

I meant his first initial patch :)

While it is suboptimal in the sense that should the value of
needed_headroom increase we'll end up constantly reallocating
skbs, I believe that it is at least semantically correct.

In the time being I'll look more closely at all the users of
needed_headroom to see if there's anything we've missed.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
