From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Fri, 5 Feb 2010 11:53:26 +1100
Message-ID: <20100205005326.GA10046@gondor.apana.org.au>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com> <20100205000816.GA9575@gondor.apana.org.au> <1265329020.31059.18.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44149 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932703Ab0BEAxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 19:53:30 -0500
Content-Disposition: inline
In-Reply-To: <1265329020.31059.18.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2010 at 04:17:00PM -0800, Sridhar Samudrala wrote:
>
> > So how is the caller going to pass the protocol value through?
> 
> via sockaddr_ll->sll_protocol in msg->msg_name.

OK that works.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
