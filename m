From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/4]: Revamp TX hashing.
Date: Wed, 28 Jan 2009 20:02:03 +1100
Message-ID: <20090128090203.GA15674@gondor.apana.org.au>
References: <20090127.164024.141230513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46720 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751217AbZA1JCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 04:02:07 -0500
Content-Disposition: inline
In-Reply-To: <20090127.164024.141230513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> The simple_tx_hash() function we currently have in
> net/core/dev.c is very rudimental and doesn't handle
> routing and firewall scenerios very well.

This is really cool! Thanks Dave!

> The next 4 patches attempt to cure that.  The end result
> is:
> 
> 1) The RX queue selection of the input device seeds the
>   TX queue selection for that SKB.
> 
> 2) Locally generated packets seed the TX queue using
>   skb->sk->sk_hash

One thing that I've been thinking about is that it would be
really useful if we guaranteed that every inbound packet carried
a hash with it.  This could be used to help subsequent processing
such as routing, netfilter, etc. since they all need to make
decisions based on flows.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
