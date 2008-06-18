From: Bill Fink <billfink@mindspring.com>
Subject: Re: Gentle Guide to the Network Stack
Date: Wed, 18 Jun 2008 00:40:28 -0400
Message-ID: <20080618004028.5ff5ce55.billfink@mindspring.com>
References: <200806171105.23069.okir@lst.de>
	<20080617145655.GB16229@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Olaf Kirch <okir@lst.de>, netdev@vger.kernel.org
To: Karen Shaeffer <shaeffer@neuralscape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:42936 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452AbYFREkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:40:42 -0400
In-Reply-To: <20080617145655.GB16229@synapse.neuralscape.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Olaf,

On Tue, 17 Jun 2008, Karen Shaeffer wrote:

> On Tue, Jun 17, 2008 at 11:05:22AM +0200, Olaf Kirch wrote:
> > 
> > I started putting together a paper on the Linux network stack,
> > focusing on how things fit together, and help relative beginners
> > understand the machinery, rather than giving a full-blown highly
> > detailed cross reference (which would be outdated more quickly
> > than you can re-run latex anyway :-)
> > I intend to release it under the GPL or GNU FDL or similar license -
> > I haven't fully made up my mind yet on what works best.
> > 
> > You can find the first couple of pages at
> > http://oss.oracle.com/~okir/network/paper.pdf
> > 
> > I'd be very interested in general feedback on the approach taken,
> > the level of detail and such. In case I missed the fact that
> > someone else is currently doing the same, please let me know, too.
> 
> I suggest you take a close look at O'Reilly's "Understanding
> Linux Network Internals" as a jumping off point. This work
> deals with IPv4 Layer 3, and L2 implementations for the 2.6
> kernel. In my opinion, it is very well done. What would be a
> very nice compliment is to focus on L4 protocols and
> implementations and the socket API implementation within the kernel.

I strongly agree.  I have not found any good, up-to-date reference
that gives any detail on the Linux TCP implementation.  It would be
very useful to beginners for example to have a good description of
the locking done by the TCP stack, what exactly the different locks
protect, and the different logic flows through the TCP stack and
how they interact (xmit, rcv, and control).  Similarly it would
be great to have an overview of other locking that is done at
other layers of the Linux network stack, to get an idea of how
it all fits together.  At least for me, this is one of the most
difficult things to get my head around when trying to read and
understand the Linux network code, and I'm still not nearly where
I would like to be, so any edification you could provide via this
kind of document would be greatly appreciated.

						-Thanks

						-Bill
