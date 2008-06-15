From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [GIT]: Networking
Date: Sun, 15 Jun 2008 15:31:45 -0700
Message-ID: <20080615153145.27982962@infradead.org>
References: <20080614.001428.26649070.davem@davemloft.net>
	<20080614081656.GA27820@elte.hu>
	<20080614023916.431a868d@infradead.org>
	<20080614.162430.193006643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48948 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbYFOWcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 18:32:00 -0400
In-Reply-To: <20080614.162430.193006643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Jun 2008 16:24:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arjan van de Ven <arjan@infradead.org>
> Date: Sat, 14 Jun 2008 02:39:16 -0700
> 
> > the interesting thing is that there is a clear bias on which drivers
> > are tripping this (r8169 is top when I counted yesterday, with
> > sis900 second and then a long tail of nothing) that I think the
> > WARN_ON() is useful in addition to the always-there printk. Eg it
> > does help in seeing which driver is most likely to trigger this.
> > (Andrew also thought this would trigger a *LOT*, so far it's only a
> > rather modest amount, but it's waiting for Fedora or others to ship
> > a kernel with this in to be sure)
> 
> I agree that it's useful and should stay.
> 
> One thing I noticed is that you can't tell which driver is
> to blame just from the warning and backtrace.  Somehow getting
> a driver name in that warning message would be useful and help
> diagnose problems as well as make it easier for you to compute
> those statistics.

There's a patch in -mm to add a WARN_ON variant that takes printk like
arguments... once that goes to mainline that'd be the thing to use
here... 




-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
