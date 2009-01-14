From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
	2.6.24?
Date: Wed, 14 Jan 2009 19:29:10 +1100
Message-ID: <20090114082910.GC16692@gondor.apana.org.au>
References: <20090113063205.GA26047@gondor.apana.org.au> <20090113015614.3b815ad7.billfink@mindspring.com> <20090113070138.GA26480@gondor.apana.org.au> <20090114024341.76ce0dec.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40981 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756265AbZANI30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:29:26 -0500
Content-Disposition: inline
In-Reply-To: <20090114024341.76ce0dec.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:43:41AM -0500, Bill Fink wrote:
> 
> I like that.  If both tcpi_unacked and SIOCOUTQ are zero, that should

Why do you still need tcpi_unacked? SIOCOUTQ returns the amount
of all outstanding data so that alone should be good enough.
 
> The performance argument I gave against INET_DIAG appears to have been
> bogus.  At least just loading the inet_diag and tcp_diag modules didn't
> have a significant impact on 10-GigE performance with either 1500-byte
> packets or 9000-byte jumbo frame packets (CPU usage may have increased
> slightly but even that's not definite).

Well if you don't make diag requests diag has zero impact on
the system.  How much of an impact diag has if you do make requests
is dependent on the number of open sockets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
