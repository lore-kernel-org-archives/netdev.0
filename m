From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Fri, 20 Jun 2008 15:41:24 -0400
Message-ID: <20080620154124.eb91fd5e.billfink@mindspring.com>
References: <20080619.041024.116139711.davem@davemloft.net>
	<OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
	<20080620145233.3e11b6fe.billfink@mindspring.com>
	<20080620.120422.193703152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, mchan@broadcom.com, netdev@vger.kernel.org,
	vinay@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:47368 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbYFTTl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 15:41:28 -0400
In-Reply-To: <20080620.120422.193703152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008, David Miller wrote:

> From: Bill Fink <billfink@mindspring.com>
> Date: Fri, 20 Jun 2008 14:52:33 -0400
> 
> > I have a general question about this new tx queueing model, which
> > I haven't seen discussed to this point.
> > 
> > Although hopefully not frequent events, if the tx queue is kept in
> > the driver rather than the network midlayer, what are the ramifications
> > of a routing change which requires changing the output to a new interface,
> > considering for example that on our 10-GigE interfaces we typically set
> > txqueuelen to 10000.
> 
> All of the packets would have been in the existing mid-layer generic
> backlog anyways, way past the routing decisions.  Nothing about
> behavior in this area would be changing.

Great.  I wasn't aware the mid-layer generic backlog was after the
routing decisions.  Thanks for educating me (and others).  I learn
new things about the Linux network stack all the time, plus it's
always changing, so can be a challenge to keep up with it if you're
not a full-time developer.

> > Similarly, what are the ramifications of such a change to the bonding
> > driver (either in a load balancing or active/backup scenario) when one
> > of the interfaces fails (again hopefully a rare event).
> 
> Since the bonding driver acts like a pass-thru, and because of the
> above, I expect no real ramifications in this area as well.

Also good to know.

						-Thanks

						-Bill
