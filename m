From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 18:16:07 +1100
Message-ID: <20071205071607.GA11852@gondor.apana.org.au>
References: <20071205001230.GA11391@gondor.apana.org.au> <20071204.223023.262159049.davem@davemloft.net> <20071205065132.GA11476@gondor.apana.org.au> <20071204.231200.117152338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3971 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751455AbXLEHQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 02:16:13 -0500
Content-Disposition: inline
In-Reply-To: <20071204.231200.117152338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 11:12:00PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 5 Dec 2007 17:51:32 +1100
> 
> > Does anybody actually need the 0 setting? What would we break if
> > the default became 1?
> 
> I bet there are UDP apps out there that would break if we
> didn't do this.

Right.  This is definitely bad for protocols without a retransmission
mechanism.

However, is the 0 setting ever useful for TCP and in particular, TCP's
connect(2) call? Perhaps we can just make that one always drop.

Well, until someone implements queueing to fix all of this properly
that is :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
