From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Tue, 19 Oct 2010 03:37:24 -0400
Message-ID: <20101019033724.0bffbe88.billfink@mindspring.com>
References: <20101014031354.e172d737.billfink@mindspring.com>
	<20101014080939.GA7710@ff.dom.local>
	<20101014085005.GA8349@ff.dom.local>
	<20101015023749.f085006b.billfink@mindspring.com>
	<1287125059.2659.1812.camel@edumazet-laptop>
	<20101015173746.12c7c40a.billfink@mindspring.com>
	<20101015220535.GA1997@del.dom.local>
	<20101016005106.35e4cc8d.billfink@mindspring.com>
	<20101016205824.GA2113@del.dom.local>
	<20101016212434.72ae5250.billfink@mindspring.com>
	<20101017203618.GA1889@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:57443 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755871Ab0JSHh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 03:37:26 -0400
In-Reply-To: <20101017203618.GA1889@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Oct 2010, Jarek Poplawski wrote:

> On Sat, Oct 16, 2010 at 09:24:34PM -0400, Bill Fink wrote:
> > On Sat, 16 Oct 2010, Jarek Poplawski wrote:
> ...
> > > http://code.google.com/p/pspacer/wiki/HTBon10GbE
> > >  
> > > If it doesn't help reconsider hfsc.
> > 
> > Thanks for the link.  From his results, it appears you can
> > get better accuracy by keeping TSO/GSO enabled and upping
> > the tc mtu parameter to 64000.  I will have to try that out.
> 
> Sure, but you have to remember that scheduler doesn't know real packet
> sizes and rate tables are less accurate especially for smaller packets,
> so it depends on conditions.

On my testing on the real data path, TSO/GSO enabled did seem
to give more accurate results for a single stream.  But when
I tried multiple 10-GigE paths simultaneously, each with a
single stream across it, non-TSO/GSO seemed to fare better
overall.

						-Bill
