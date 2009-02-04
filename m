From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 19:59:07 +1100
Message-ID: <20090204085907.GA19388@gondor.apana.org.au>
References: <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net> <20090203122535.GB8633@1wt.eu> <20090203.164734.76871204.davem@davemloft.net> <20090204061947.GD20673@1wt.eu> <20090204081201.GB10445@ioremap.net> <20090204085432.GA21638@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49049 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751781AbZBDI7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 03:59:53 -0500
Content-Disposition: inline
In-Reply-To: <20090204085432.GA21638@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 09:54:32AM +0100, Willy Tarreau wrote:
>
> My server is running 2.4 :-), but I observed the same issues with older
> 2.6 as well. I can certainly imagine that things have changed a lot since,
> but the initial point remains : jumbo frames are expensive to deal with,
> and with recent NICs and drivers, we might get close performance for
> little additional cost. After all, initial justification for jumbo frames
> was the devastating interrupt rate and all NICs coalesce interrupts now.

This is total crap! Jumbo frames are way better than any of the
hacks (such as GSO) that people have come up with to get around it.
The only reason we are not using it as much is because of this
nasty thing called the Internet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
