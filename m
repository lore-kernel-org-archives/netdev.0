From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 21 Aug 2009 00:14:21 -0400
Message-ID: <20090821001421.214a560b.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090807221211.GA16874@localhost.localdomain>
	<20090807205442.32918186.billfink@mindspring.com>
	<20090808015612.GA17710@localhost.localdomain>
	<20090814164412.be5daa74.billfink@mindspring.com>
	<20090814232543.GA28599@hmsreliant.think-freely.org>
	<20090820035044.9b70fca6.billfink@mindspring.com>
	<20090820201919.GA20750@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:54516 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbZHUEOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 00:14:22 -0400
In-Reply-To: <20090820201919.GA20750@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2009, Neil Horman wrote:

> On Thu, Aug 20, 2009 at 03:50:44AM -0400, Bill Fink wrote:
> 
> > When I tried an actual nuttcp performance test, even when rate limiting
> > to just 1 Mbps, I immediately got a kernel oops.  I tried to get a
> > crashdump via kexec/kdump, but the kexec kernel, instead of just
> > generating a crashdump, fully booted the new kernel, which was
> > extremely sluggish until I rebooted it through a BIOS re-init,
> > and never produced a crashdump.  I tried this several times and
> > an immediate kernel oops was always the result (with either a TCP
> > or UDP test).  A ping test of 1000 9000-byte packets with an interval
> > of 0.001 seconds (which is 72 Mbps for 1 second) on the other hand
> > worked just fine.
> 
> The sluggishness is expected, since the kdump kernel operates out of such
> limited memory.  don't know why you booted to a full system rather than did a
> crash recovery.  Don't suppose you got a backtrace did you?

There was a backtrace on the screen but I didn't have a chance to
record it.  BTW did anyone ever think to print the backtrace in
reverse (first to some reserved memory and then output to the display)
so the more interesting parts wouldn't have scrolled off the top of
the screen?

						-Bill
