From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3/5] net: mvneta: do not schedule in mvneta_tx_timeout
Date: Sun, 12 Jan 2014 23:14:05 +0100
Message-ID: <20140112221405.GF16576@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-4-git-send-email-w@1wt.eu> <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk> <20140112165548.GC16576@1wt.eu> <1389548333.3720.73.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55266 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbaALWOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 17:14:12 -0500
Content-Disposition: inline
In-Reply-To: <1389548333.3720.73.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Sun, Jan 12, 2014 at 05:38:53PM +0000, Ben Hutchings wrote:
> [Putting another hat on]
> 
> On Sun, 2014-01-12 at 17:55 +0100, Willy Tarreau wrote:
> > Hi Ben,
> > 
> > On Sun, Jan 12, 2014 at 04:49:51PM +0000, Ben Hutchings wrote:
> > (...)
> > > > So for now, let's simply ignore these timeouts generally caused by bugs
> > > > only.
> > > 
> > > No, don't ignore them.  Schedule a work item to reset the device.  (And
> > > remember to cancel it when stopping the device.)
> > 
> > OK I can try to do that. Could you recommend me one driver which does this
> > successfully so that I can see exactly what needs to be taken care of ?
> 
> sfc does it, though the reset logic there is more complicated than you
> would need.

OK.

> I think this will DTRT, but it's compile-tested only.

OK, I'll test it ASAP. I think I can force the tx timeout by disabling
the link state detection and unplugging the cable during a transfer.

> I have been given an OpenBlocks AX3 but haven't set it up yet.

Ah you're another lucky owner of this really great device :-)

I've sent Eric Leblond a complete howto in french, so it won't be of
a big use to you but if I can find some time and you don't find other
info, I can try to redo it in english. However you may be interested
in this article I put online with a few patches to make your life
easier :

   http://1wt.eu/articles/openblocks-http-server/

It's a line-rate (1.488 Mpps) HTTP server I've done on it with a few
patches that may be useful for other network tests.

Cheers,
Willy
