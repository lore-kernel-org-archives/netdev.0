From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Sat, 21 Mar 2015 09:10:21 +1100
Message-ID: <20150320221021.GA24140@gondor.apana.org.au>
References: <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
 <20150320092703.GA17081@gondor.apana.org.au>
 <20150320095908.GG21258@acer.localdomain>
 <20150320101603.GA17662@gondor.apana.org.au>
 <20150320102701.GA28736@acer.localdomain>
 <20150320214712.GA23963@gondor.apana.org.au>
 <20150320215612.GA566@casper.infradead.org>
 <20150320215756.GA24045@gondor.apana.org.au>
 <20150320220751.GB566@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43438 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbCTWK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:10:28 -0400
Content-Disposition: inline
In-Reply-To: <20150320220751.GB566@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 10:07:51PM +0000, Thomas Graf wrote:
>
> Attack by whom? If I read the nft_set code correctly then the only
> way to add to an nft_set is via nfnetlink which requires
> CAP_NET_ADMIN. My understanding was that the chain length based
> growth is to counter hash seed attacks.

You cannot trust root in a namespace.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
