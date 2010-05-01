From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Sat, 1 May 2010 01:07:35 -0400
Message-ID: <20100501010735.dfe097bc.billfink@mindspring.com>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	<20100429.233958.212393607.davem@davemloft.net>
	<i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
	<20100430.164115.257514715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:45345 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0EAFHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 01:07:40 -0400
In-Reply-To: <20100430.164115.257514715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Apr 2010, David Miller wrote:

> From: Tom Herbert <therbert@google.com>
> Date: Fri, 30 Apr 2010 00:58:32 -0700
> 
> >> All these new checks and branches for a feature of questionable value.
> > 
> >> If you can modify you apps to grab this information you can also probe
> >> for the information using external probing tools.
> >>
> > I don't see an nice way to do that, we're profiling a significant
> > percentage of millions of connections over thousands of paths as part
> > of standard operations while incurring negligible overhead.  The app
> > can can easily timestamp its operations, but without some mechanism
> > for getting timestamps out of a TCP connection, the networking portion
> > of servicing requests is pretty much a black box in that.
> 
> If other people have an opinion about this, now would be the time
> to speak up. :-)

Not being a kernel hacker, I will naively ask if the kernel tracing
facility could somehow be used to provide the desired info (or could
be modified to provide it).

						-Bill
