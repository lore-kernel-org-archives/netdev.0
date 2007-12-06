From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch] net/xfrm/xfrm_policy.c: Some small improvements
Date: Fri, 7 Dec 2007 04:40:52 +1100
Message-ID: <20071206174052.GA530@gondor.apana.org.au>
References: <20071206110123.GB2469@hacking> <20071206.031434.179419183.davem@davemloft.net> <4758093A.7010608@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: Richard Knutsson <ricknu-0@student.ltu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1862 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751658AbXLFRxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:53:30 -0500
Content-Disposition: inline
In-Reply-To: <4758093A.7010608@student.ltu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 06, 2007 at 03:37:46PM +0100, Richard Knutsson wrote:
>
> Is it not an improvement to distinct booleans from actual values? Do you 
> use integers for ASCII characters too? It can also avoid some potential 
> bugs like the 'if (i == TRUE)'...
> What is wrong with 'size_t' (since it is unsigned, compared to (some) 
> 'int')?

I agree with Dave.  There are so many useful things that we can do
(and need to do) in IPsec that bool/size_t conversions just add
churn without adding much value.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
