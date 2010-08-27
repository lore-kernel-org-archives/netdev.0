From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 21:42:01 -0700
Message-ID: <20100827044201.GA24224@gondor.apana.org.au>
References: <20100825.135726.189708768.davem@davemloft.net> <1282770911.2681.205.camel@edumazet-laptop> <1282883713.2501.29.camel@edumazet-laptop> <20100826.213816.112615295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45117 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab0H0EmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:42:06 -0400
Content-Disposition: inline
In-Reply-To: <20100826.213816.112615295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 26, 2010 at 09:38:16PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Aug 2010 06:35:13 +0200
> 
> > +	fold |= *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
> 
> Shouldn't these be "+ 8" instead of "+ 6"?

I think +6 is right since we're trying to compare 14 bytes worth
of data.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
