From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 14:29:24 +0300
Message-ID: <20081026112924.GA29258@ioremap.net>
References: <20081009231759.GA8664@tservice.net.ru> <20081010115518.GA3159@tservice.net.ru> <20081010115725.GD19487@elte.hu> <200810250025.35734.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752817AbYJZL3s@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200810250025.35734.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 25, 2008 at 12:25:34AM +0200, Rafael J. Wysocki (rjw@sisk.pl) wrote:
> > > > > vanilla 27: 347.222
> > > > > no TSO/GSO: 357.331
> > > > > no hrticks: 382.983
> > > > > no balance: 389.802
> 
> Can anyone please tell me if there was any conclusion of this thread?

For the reference, just pulled git tree (4403b4 commit): 361.184
and with dirty_ratio set to 50: 361.086
without scheduler domain tuning things are essentially the same: 361.367

So, things are getting worse with time, and previous tunes do not help
anymore.

-- 
	Evgeniy Polyakov
