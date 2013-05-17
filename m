From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] ipv6: use ipv6_dup_options() from
 ip6_append_data()
Date: Sat, 18 May 2013 07:36:01 +0800
Message-ID: <20130517233601.GA20445@gondor.apana.org.au>
References: <1368742990.3301.67.camel@edumazet-glaptop>
 <1368750452.3301.74.camel@edumazet-glaptop>
 <20130517135804.GA16069@gondor.apana.org.au>
 <1368802393.3301.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50063 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752880Ab3EQXgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 19:36:08 -0400
Content-Disposition: inline
In-Reply-To: <1368802393.3301.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 07:53:13AM -0700, Eric Dumazet wrote:
>
> OK, so I guess for stable we should use kzalloc(), and work on a cleanup
> in net-next.

I agree.  Thank you.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
