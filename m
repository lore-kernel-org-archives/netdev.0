From: David Miller <davem@davemloft.net>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 02 Jan 2015 17:06:29 -0500 (EST)
Message-ID: <20150102.170629.1474417873101408441.davem@davemloft.net>
References: <1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150102.153655.1853692198479011402.davem@davemloft.net>
	<20150102220107.GA28599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, thomas.jarosch@intra2net.com,
	netdev@vger.kernel.org, edumazet@google.com,
	steffen.klassert@secunet.com, bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbABWGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:06:32 -0500
In-Reply-To: <20150102220107.GA28599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 3 Jan 2015 09:01:07 +1100

> So has anyone actually observed worse performance with GSO on these
> devices (you could even test on a GSO-capable device simply by
> disabling checksumming)?

Good question.

> Also the fact that this bug took two years to surface means that
> very few people are actually using non-GSO in the real world as
> this bug is easily triggered by a PMTU event.

I think the rarity of PMTU events on non-VPN'd connections plays
a part in how long it took as well.

But I totally accept your point, for sure.
