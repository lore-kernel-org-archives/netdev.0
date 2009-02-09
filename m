From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TX pre-headers...
Date: Mon, 9 Feb 2009 21:07:13 +1100
Message-ID: <20090209100713.GA8299@gondor.apana.org.au>
References: <20090206.014107.231141422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46398 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751743AbZBIKHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 05:07:16 -0500
Content-Disposition: inline
In-Reply-To: <20090206.014107.231141422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> I think the way to solve this is to have each device indicate how
> much TX slack space it neads for it's preheaders.  On device
> registration we have some global "netdev_max_tx_hdr_space" that
> records the maximum value seen.

We can already solve it right now with dev->needed_headroom.

Of course it's not optimal because it involves a copy so we
might still need your solution.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
