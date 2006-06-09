From: Matt Mackall <mpm@selenic.com>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Fri, 9 Jun 2006 12:14:07 -0500
Message-ID: <20060609171407.GJ24227@waste.org>
References: <20060608210702.GD24227@waste.org> <4489038C.3050901@intel.com> <20060608.222352.59657133.davem@davemloft.net> <200606090750.25067.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeremy@goop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([64.81.244.121]:24207 "EHLO waste.org")
	by vger.kernel.org with ESMTP id S1030272AbWFIRZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 13:25:08 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200606090750.25067.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2006 at 07:50:25AM +0200, Andi Kleen wrote:
> On Friday 09 June 2006 07:23, David Miller wrote:
> > From: Auke Kok <auke-jan.h.kok@intel.com>
> > Date: Thu, 08 Jun 2006 22:13:48 -0700
> > 
> > > netconsole should retry. There is no timeout programmed here since that might
> > > lose important information, and you rather want netconsole to survive an odd
> > > unplugged cable then to lose vital debugging information when the system is
> > > busy for instance. (losing link will cause the interface to be down and thus
> > > the queue to be stopped)
> > 
> > I completely disagree that netpoll should loop when the ethernet
> > cable is plugged out. 
> 
> Currently it is a bit dumb and doesn't distingush the various cases
> well.
> 
> I submitted a patch to loop to be a bit more clever at some point. It can be still
> found in the netdev archives.

Agreed that timeouts should happen.

IIRC, the trouble with your patch was that it a) timed out on far too
short a timescale and b) locked up on my box. Unfortunately, so did my
own patch, which made timeouts approximately 1ms.

-- 
Mathematics is the supreme nostalgia of our time.
