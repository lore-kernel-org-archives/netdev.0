From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Fri, 24 Jul 2009 11:47:24 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907241142370.2084@ppwaskie-MOBL2.amr.corp.intel.com>
References: <1248266678.17215.15.camel@localhost.localdomain>
 <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
 <1248338779.17215.23.camel@localhost.localdomain>
 <1248362493.17215.45.camel@localhost.localdomain>
 <1248424910.17215.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25033 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721AbZGXSrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2009 14:47:23 -0400
In-Reply-To: <1248424910.17215.54.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jul 2009, Jesper Dangaard Brouer wrote:

> On Thu, 2009-07-23 at 17:21 +0200, Jesper Dangaard Brouer wrote:
> > I'm going to run a test with a no-preempt kernel over night...
> 
> The no-preempt kernel has been stable for 17 hours, while running a four
> times 10GbE pktgen load test (using 1024 bytes packets).
> 
> Kernel git version (git describe):
>  v2.6.31-rc1-932-g8e321c4
> 
> Git ("git log e594e96..8e321c4 drivers/net/ixgbe") reports not changes
> to the ixgbe driver between these two kernel versions.

Thanks for the additional info Jesper.  This is definately a good data 
point.  I'm not sure where to go with the preemption debugging at this 
point with our driver under heavy load.  We're still trying to repro here.  
I'll keep digging around though in the meantime.

This is the second preemption-induced bug from ixgbe we've had reported in 
a few days.  Eek!

Cheers,
-PJ Waskiewicz
