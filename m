From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 15:35:54 +1000
Message-ID: <20060628053554.GA5928@gondor.apana.org.au>
References: <20060628033708.GA4922@gondor.apana.org.au> <44A20311.5050301@pobox.com> <20060628042959.GA5561@gondor.apana.org.au> <20060627.214323.92582051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, swise@opengridcomputing.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43787 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030184AbWF1FgN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 01:36:13 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060627.214323.92582051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 09:43:23PM -0700, David Miller wrote:
> 
> Socket state, and that is one thing I don't see them doing yet.

I wonder what happens when the Linux TCP stack attempts to open a
connection to a remote host when that connection is already open
in the RDMA NIC?  For that matter what happens if a Linux application
decides to listen on a TCP port already listened on by the RDMA
NIC?

The only saving grace is that they're only doing RDMA rather than
arbitrary TCP.  However, exactly the same infrastructure can be used
to do arbitrary TCP should they wish to.
 
> But we have to realize they've already been given %95 of the
> interfaces they need to speak IP using our routes and our neighbour
> entries.
> 
> Right?

Yes, however I think the same argument could be applied to TOE.

With their RDMA NIC, we'll have TCP/SCTP connections that bypass
netfilter, tc, IPsec, AF_PACKET/tcpdump and the rest of our stack
while at the same time it is using the same IP address as us and
deciding what packets we will or won't see.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
