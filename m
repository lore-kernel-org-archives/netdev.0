From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 10:20:02 -0700
Message-ID: <20071002172002.GO17418@bitmover.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com> <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org> <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org> <20071002005917.GB5480@bitmover.com> <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org> <20071002022059.GE7037@bitmover.com> <47027C63.803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43525 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754396AbXJBRUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 13:20:03 -0400
Content-Disposition: inline
In-Reply-To: <47027C63.803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 10:14:11AM -0700, Rick Jones wrote:
> Larry McVoy wrote:
> >A short summary is "can someone please post a test program that sources
> >and sinks data at the wire speed?"  because apparently I'm too old and
> >clueless to write such a thing.
> 
> WRT the different speeds in each direction talking with HP-UX, perhaps 
> there is an interaction between the Linux TCP stack (TSO perhaps) and 
> HP-UX's ACK avoidance heuristics. If that is the case, tweaking 
> tcp_deferred_ack_max with ndd on the HP-UX system might yield different 
> results.

I doubt it because I see the same sort of behaviour when I have a group
of Linux clients talking to the server.  The HP box is in the mix
simply because it has a gigabit card and that makes driving the load
simpler.  But if I do several loads from 100Mbit clients I get the same
packet throughput.

> WRT the small program making a setsockopt(SO_*BUF) call going slower than 
> the rsh, does rsh make the setsockopt() call, or does it bend itself to the 
> will of the linux stack's autotuning?  What happens if your small program 
> does not make setsockopt(SO_*BUF) calls?

I haven't tracked down if rsh does that but I've tried doing it with 
values of default, 64K, 1MB, and 10MB with no difference.

> *) depending on the quantity of CPU around, and the type of test one is 

These are fast CPUs and they are running at 93% idle while running the test.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
