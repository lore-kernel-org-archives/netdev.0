From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2 2/5] rhashtable: add function to replace an
 element
Date: Wed, 9 Dec 2015 13:38:41 +0800
Message-ID: <20151209053841.GA25851@gondor.apana.org.au>
References: <20151203.144558.1956397517705186998.davem@davemloft.net>
 <20151208093941.GA17795@gondor.apana.org.au>
 <CALx6S35sG4+5UT87Yrwa1a=O-Mq09SucXw7=xyxnrJVwXY6fkw@mail.gmail.com>
 <20151209024323.GA24768@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36497 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbLIFiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 00:38:52 -0500
Content-Disposition: inline
In-Reply-To: <20151209024323.GA24768@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 10:43:23AM +0800, Herbert Xu wrote:
>
> OK after thinking about it a little bit more I think your approach
> is safe and we won't need to play any more games to get this to
> work.  So I'm fine with this patch.

One suggestion though: your inline function doesn't actually
inline the fast path.  The only thing that's inlined is the loop
which is not that critical.  As this is probably not performance
critical how about just making the whole thing out-of-line?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
