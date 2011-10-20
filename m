From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Thu, 20 Oct 2011 16:21:00 -0400 (EDT)
Message-ID: <20111020.162100.936624966779816387.davem@davemloft.net>
References: <20111019080807.GA25099@gondor.apana.org.au>
	<20111020.053050.383972361986316046.davem@davemloft.net>
	<20111020093541.GA3024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: herbert@gondor.hengli.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111020093541.GA3024@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Thu, 20 Oct 2011 11:35:41 +0200

> On Thu, Oct 20, 2011 at 05:30:50AM -0400, David Miller wrote:
>>
>> So I'm a little confused what your suggestion for rc10 really
>> is :-)
> 
> I meant his first initial patch :)
> 
> While it is suboptimal in the sense that should the value of
> needed_headroom increase we'll end up constantly reallocating
> skbs, I believe that it is at least semantically correct.

Ok, I applied Eric's patch which removes the dynamic changing of the
needed_headroom in IP_GRE.

Thanks everyone!
