From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: netconf notes and materials
Date: Fri, 09 Oct 2009 16:01:29 -0700
Message-ID: <1255129289.8937.39.camel@localhost.localdomain>
References: <20091007.044718.233642056.davem@davemloft.net>
	 <20091009174949.467ddc50.billfink@mindspring.com>
	 <20091009.145151.130967664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "billfink@mindspring.com" <billfink@mindspring.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9775 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176AbZJIXCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 19:02:04 -0400
In-Reply-To: <20091009.145151.130967664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-09 at 14:51 -0700, David Miller wrote:
> From: Bill Fink <billfink@mindspring.com>
> Date: Fri, 9 Oct 2009 17:49:49 -0400
> 
> > How did you do the NUMA memory performance monitoring that was
> > presented on one of your slides?
> 
> Using proprietary internal tools Intel is unlikely to release.
> 
> On the bright side, some of those metrics will make their way into the
> 'perf' facilities in the kernel so they can be monitored, but not all
> of them.

Yes, they are tools written by our CPU and chipset teams to assist in
debug.  To reinforce what David just said, I know Jesse Barnes is
working hard with the Intel powers-that-be to get the "approved" public
PMU counters into the perf utility.  I'd imagine the PMU counters for
IOH memory throughput will be deemed ok, since it's not uncovering any
IP.

If I hear anything about any of the performance counters, I'll be sure
to forward that on.

Cheers,
-PJ

