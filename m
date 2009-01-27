From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 12:23:23 -0500
Message-ID: <20090127172323.GA7635@infradead.org>
References: <20090126195930.GA28208@hmsreliant.think-freely.org> <20090127171857.GB14429@infradead.org> <20090127.092017.40699485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38971 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbZA0RXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:23:25 -0500
Content-Disposition: inline
In-Reply-To: <20090127.092017.40699485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 09:20:17AM -0800, David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Tue, 27 Jan 2009 12:18:57 -0500
> 
> > Do we now have lttng in linux-next?  Otherwise these trace point would
> > be useless there without more patching.
> 
> We're merging this stuff to solve the chicken and egg
> problem wherein the lttng tree merge is basically
> stalled.
> 
> If the individual subsystem annotations go in, the hope
> is that they'll have less to merge and thus it's more likely
> to actually happen.

I'm rather concerned as I haven't seen any progress on the lttng core
lately.  I'd really prefer to have a version in close to mergeable shape
first, that's actively beeing pushed.  Adding the instrumentation is
trivial as seen by this small patch, but getting the core right (and who
knows if that involves changing the way actual instrumentation works, it's
not like that hasn't changed n million times yet) is essential.
