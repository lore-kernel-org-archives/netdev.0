From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 2 Mar 2011 16:07:23 +0800
Message-ID: <20110302080723.GA18773@gondor.apana.org.au>
References: <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop> <20110301131823.GB8028@gondor.apana.org.au> <1298997084.3284.119.camel@edumazet-laptop> <20110302002353.GA15009@gondor.apana.org.au> <1299031203.2930.26.camel@edumazet-laptop> <20110302023920.GA16072@gondor.apana.org.au> <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com> <20110302073123.GA18443@gondor.apana.org.au> <1299053048.2930.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44286 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab1CBIHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 03:07:39 -0500
Content-Disposition: inline
In-Reply-To: <1299053048.2930.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 09:04:08AM +0100, Eric Dumazet wrote:
> 
> Not sure why two UDP packets from the same cpu should be sent on same
> queue.
> 
> - Some qdisc do reorder packets anyway.

Which qdisc reorders packets belonging to the same flow?

> - Some bonding setups use two links in round-robin mode (link
> aggregation)

Just because the Internet may reorder things doesn't mean that
we should.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
