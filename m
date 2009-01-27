From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 10:21:41 -0800 (PST)
Message-ID: <20090127.102141.99756103.davem@davemloft.net>
References: <20090127171857.GB14429@infradead.org>
	<20090127.092017.40699485.davem@davemloft.net>
	<20090127172323.GA7635@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752474AbZA0SVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:21:44 -0500
In-Reply-To: <20090127172323.GA7635@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 27 Jan 2009 12:23:23 -0500

> On Tue, Jan 27, 2009 at 09:20:17AM -0800, David Miller wrote:
> > We're merging this stuff to solve the chicken and egg
> > problem wherein the lttng tree merge is basically
> > stalled.
> > 
> > If the individual subsystem annotations go in, the hope
> > is that they'll have less to merge and thus it's more likely
> > to actually happen.
> 
> I'm rather concerned as I haven't seen any progress on the lttng core
> lately.  I'd really prefer to have a version in close to mergeable shape
> first, that's actively beeing pushed.  Adding the instrumentation is
> trivial as seen by this small patch, but getting the core right (and who
> knows if that involves changing the way actual instrumentation works, it's
> not like that hasn't changed n million times yet) is essential.

The block layer already merged trace annotations.  I therefore see no
harm in merging the net bits.

If you disagree, either submit a revert of the block layer
annotations, or content yourself in being a hypocrite :-)
