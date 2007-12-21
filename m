From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [SOCK] Avoid integer divides where not necessary in include/net/sock.h
Date: Fri, 21 Dec 2007 20:58:31 +0800
Message-ID: <E1J5hSR-0000Nw-00@gondolin.me.apana.org.au>
References: <20071221.030640.100066714.davem@davemloft.net>
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4972 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756617AbXLUM6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 07:58:38 -0500
In-Reply-To: <20071221.030640.100066714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> When I was playing with this crap a long time ago I
> think I remember that sk->sk_forward_alloc can become
> negative in some circumstances.
> 
> Or maybe that was just a bug :-)

Yeah we had a few bugs there in the early days of TSO but it's
been quiet for the last 18 months.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
