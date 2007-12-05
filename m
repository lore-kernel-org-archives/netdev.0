From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 17:51:32 +1100
Message-ID: <20071205065132.GA11476@gondor.apana.org.au>
References: <4755A21F.2020407@simon.arlott.org.uk> <20071205001230.GA11391@gondor.apana.org.au> <20071204.223023.262159049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3839 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750954AbXLEGvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:51:39 -0500
Content-Disposition: inline
In-Reply-To: <20071204.223023.262159049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 10:30:23PM -0800, David Miller wrote:
> 
> We made an explicit decision not to do things this way.

Thanks for pointing this out.

> Non-blocking has a meaning dependant upon the xfrm_larval_drop sysctl
> setting, and this is across the board.  If xfrm_larval_drop is zero,
> non-blocking semantics do not extend to IPSEC route resolution,
> otherwise it does.
> 
> If he sets this sysctl to "1" as I detailed in my reply, he'll
> get the behavior he wants.

Does anybody actually need the 0 setting? What would we break if
the default became 1?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
