From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPCOMP]: Fix truesize after decompression
Date: Wed, 12 Jul 2006 09:22:28 +1000
Message-ID: <20060711232228.GA6907@gondor.apana.org.au>
References: <20060711114544.GA11396@gondor.apana.org.au> <20060711.135553.106801039.davem@davemloft.net> <20060711231251.GA6725@gondor.apana.org.au> <20060711.162217.101672676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1040 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932233AbWGKXWe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 19:22:34 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060711.162217.101672676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 04:22:17PM -0700, David Miller wrote:
> 
> What ATM is doing here is charging the SKB to the virtual circuit
> sockets.  At least in the few cases I've looked at just now, the
> skb is some private ATM level signalling message, and not part of
> a normal transmit/receive packet from the normal networking stack.

Indeed, at least they do have an sk to charge things to :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
