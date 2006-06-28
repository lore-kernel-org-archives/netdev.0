From: David Miller <davem@davemloft.net>
Subject: Re: TOE, etc.
Date: Tue, 27 Jun 2006 23:31:01 -0700 (PDT)
Message-ID: <20060627.233101.71091373.davem@davemloft.net>
References: <20060628042959.GA5561@gondor.apana.org.au>
	<20060627.214323.92582051.davem@davemloft.net>
	<20060628053554.GA5928@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, swise@opengridcomputing.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44947
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932748AbWF1GbC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 02:31:02 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060628053554.GA5928@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jun 2006 15:35:54 +1000

> With their RDMA NIC, we'll have TCP/SCTP connections that bypass
> netfilter, tc, IPsec, AF_PACKET/tcpdump and the rest of our stack
> while at the same time it is using the same IP address as us and
> deciding what packets we will or won't see.

That's true.  I don't think we should really add any more
help for these kinds of things then.
