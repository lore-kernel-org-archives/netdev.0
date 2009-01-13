From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
	2.6.24?
Date: Tue, 13 Jan 2009 18:01:38 +1100
Message-ID: <20090113070138.GA26480@gondor.apana.org.au>
References: <20090113063205.GA26047@gondor.apana.org.au> <20090113015614.3b815ad7.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49662 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751058AbZAMHBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:01:53 -0500
Content-Disposition: inline
In-Reply-To: <20090113015614.3b815ad7.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 01:56:14AM -0500, Bill Fink wrote:
>
> I'm not familiar with idiag_wqueue, but it sounds like it has something
> to do with INET_DIAG/INET_TCP_DIAG.  It was a long time ago, but I seem
> to recall that using INET_DIAG had a negative impact on performance,
> and since the main point of nuttcp is to measure TCP/UDP performance,
> that would be contrary to its primary purpose.  Also, I don't want to
> rely on something that's not guaranteed to be part of the running kernel.

Well SIOCOUTQ also returns the same information.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
