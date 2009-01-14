From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Wed, 14 Jan 2009 02:43:41 -0500
Message-ID: <20090114024341.76ce0dec.billfink@mindspring.com>
References: <20090113063205.GA26047@gondor.apana.org.au>
	<20090113015614.3b815ad7.billfink@mindspring.com>
	<20090113070138.GA26480@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:45135 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753471AbZANHny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 02:43:54 -0500
In-Reply-To: <20090113070138.GA26480@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jan 2009, Herbert Xu wrote:

> On Tue, Jan 13, 2009 at 01:56:14AM -0500, Bill Fink wrote:
> >
> > I'm not familiar with idiag_wqueue, but it sounds like it has something
> > to do with INET_DIAG/INET_TCP_DIAG.  It was a long time ago, but I seem
> > to recall that using INET_DIAG had a negative impact on performance,
> > and since the main point of nuttcp is to measure TCP/UDP performance,
> > that would be contrary to its primary purpose.  Also, I don't want to
> > rely on something that's not guaranteed to be part of the running kernel.
> 
> Well SIOCOUTQ also returns the same information.

I like that.  If both tcpi_unacked and SIOCOUTQ are zero, that should
insure all data has been sent and ACKed.  I'll add that to the nuttcp
TODO list, although it's not an urgent matter in general usage.

The performance argument I gave against INET_DIAG appears to have been
bogus.  At least just loading the inet_diag and tcp_diag modules didn't
have a significant impact on 10-GigE performance with either 1500-byte
packets or 9000-byte jumbo frame packets (CPU usage may have increased
slightly but even that's not definite).

						-Thanks

						-Bill
