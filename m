From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Sun, 1 Feb 2009 13:53:24 -0500
Message-ID: <20090201185324.GA10023@localhost.localdomain>
References: <20090127.102141.99756103.davem@davemloft.net> <20090127184704.GA26403@infradead.org> <20090128212809.GA19228@hmsreliant.think-freely.org> <20090201.020247.247498390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44553 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbZBASxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 13:53:33 -0500
Content-Disposition: inline
In-Reply-To: <20090201.020247.247498390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 01, 2009 at 02:02:47AM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 28 Jan 2009 16:28:09 -0500
> 
> > Of course, these provided tracepoints don't do that, but I think it
> > would be good to get the existing tracepoint set in before I go
> > poking at an implementation of that, just to ensure I avoid
> > duplicate work
> 
> Christoph's point is that it doesn't make any sense to merge
> this stuff in without any upstream users.
> 
> The block stuff has such users, this net syscall trace stuff doesn't.
> 
Not sure thats entirely true.  Frysk can use the net syscall trace points just
as well as it can monitor the block syscalls (Unless I'm missing somethig here).
Granted thats not applicable for the deeper tracepoints, but for the top level
stuff...

> Now your "where is the packet dropped" trace thing, that would
> something we could merge once that patch and a suitable tool exists.
> Just like the block layer cases.
> 
> So I have to toss this patch for now, sorry.
> 
Thats ok, thats why I started small. :).  I'll take a more serious look at
implementing a consise drop monitoring utilty and come back to this.

Thanks for the eyes all!
Neil

