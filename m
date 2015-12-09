From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2 2/5] rhashtable: add function to replace an
 element
Date: Wed, 9 Dec 2015 10:43:23 +0800
Message-ID: <20151209024323.GA24768@gondor.apana.org.au>
References: <20151203.144558.1956397517705186998.davem@davemloft.net>
 <20151208093941.GA17795@gondor.apana.org.au>
 <CALx6S35sG4+5UT87Yrwa1a=O-Mq09SucXw7=xyxnrJVwXY6fkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38656 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbbLICnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:43:31 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35sG4+5UT87Yrwa1a=O-Mq09SucXw7=xyxnrJVwXY6fkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 09:14:24AM -0800, Tom Herbert wrote:
> 
> That creates one more level of indirection. I don't see how add an
> atomic replace operation adds any complexity to the rhashtable, none
> of the semantics for rhashtable need to be changed.

OK after thinking about it a little bit more I think your approach
is safe and we won't need to play any more games to get this to
work.  So I'm fine with this patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
