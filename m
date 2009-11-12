From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Thu, 12 Nov 2009 23:16:20 +1030
Message-ID: <20091112231620.0b56c0b0@opy.nosense.org>
References: <20091111.124235.243348591.davem@davemloft.net>
	<20091111133342.1011e16a@nehalam>
	<200911112347.41425.opurdila@ixiacom.com>
	<20091111.183626.202530131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:60924 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbZKLMqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 07:46:24 -0500
In-Reply-To: <20091111.183626.202530131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Nov 2009 18:36:26 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed, 11 Nov 2009 23:47:41 +0200
> 
> > We could use a similar function that will work in the per namespace
> > initialization context, but this might upset net namespace folks
> > since we will get a large hash for every namespace.
> 
> Use kzalloc(), that's sufficient for a 64K or so hash table which is
> way more than you ever will need.
> 
> Use the GFP_* flags that will silently (ie. without a log message)
> fail, and divide by two until you successfully allocate the table if
> you're worried about memory fragmentation at allocation time.
> 
> This is so straightforward, I can't believe we're talking so much
> about how to implement this, it's a 15 minute hack :-)

Yes, but sadly, sometimes there is too much history(!) to be able to be
fully aware of it. "suck-it-and-see" type patches are possibly a
quicker way to find out what people are thinking right now!

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
