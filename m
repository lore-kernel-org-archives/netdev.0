From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 10:08:48 +1100
Message-ID: <20150322230848.GA8989@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150322215612.GA8274@gondor.apana.org.au>
 <20150322.185850.927485035002538859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	roland@purestorage.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52053 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbCVXIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:08:52 -0400
Content-Disposition: inline
In-Reply-To: <20150322.185850.927485035002538859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 06:58:50PM -0400, David Miller wrote:
>
> But I do not agree with the idea that it is in any way possible to
> stop someone with root access on the physical network from crudding up
> our ARP hash tables.

But you don't need root access to exploit the neighbour hash
table.  You just need a sufficiently large (e.g., /16) route
to a network and anybody on the system can then generate traffic
to it.

Granted these days hardly anybody on IPv4 would have such a route
but if you do then the hash table makes you exposed.

And for IPv6 everybody is potentially exposed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
