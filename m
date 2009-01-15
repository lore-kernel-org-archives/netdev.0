From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Thu, 15 Jan 2009 01:33:44 -0500
Message-ID: <20090115013344.4b85a26d.billfink@mindspring.com>
References: <20090113063205.GA26047@gondor.apana.org.au>
	<20090113015614.3b815ad7.billfink@mindspring.com>
	<20090113070138.GA26480@gondor.apana.org.au>
	<20090114024341.76ce0dec.billfink@mindspring.com>
	<20090114082910.GC16692@gondor.apana.org.au>
	<20090114040550.407c2a0c.billfink@mindspring.com>
	<20090114113026.GC18662@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:47495 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbZAOGeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 01:34:03 -0500
In-Reply-To: <20090114113026.GC18662@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Herbert Xu wrote:

> On Wed, Jan 14, 2009 at 04:05:50AM -0500, Bill Fink wrote:
> >
> > Well, my man tcp(7) just says:
> > 
> >    SIOCOUTQ
> >           Returns the amount of unsent data in the socket send queue.  The
> >           socket must not be in LISTEN state, otherwise an error  (EINVAL)
> >           is returned.
> 
> You still read man pages? :)
> 
> If you look at the actual code, SIOCOUTQ returns
> 
> 	tp->write_seq - tp->snd_una
> 
> Really you can't get any more precise than that for what you want.

Thanks for the clarification!  That does make it crystal clear.

						-Bill
