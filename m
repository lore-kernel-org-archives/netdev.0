From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: lockdep warning
Date: Fri, 22 Feb 2008 12:16:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802221214020.7699@twin.jikos.cz>
References: <20080222104049.BD95A93C12F@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Anders Eriksson <aeriksson@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:54320 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbYBVLQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 06:16:13 -0500
In-Reply-To: <20080222104049.BD95A93C12F@tippex.mynet.homeunix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Anders Eriksson wrote:

> I found this is a newly booted 2.6.25-rc2's syslog.
> Feb 21 20:46:33 tippex BUG: rwlock wrong owner on CPU#0, runscript.sh/2633, d2c04084
> Feb 21 20:46:33 tippex Pid: 2633, comm: runscript.sh Not tainted 2.6.25-rc2 #3
> Feb 21 20:46:33 tippex [<c02342d0>] rwlock_bug+0x50/0x60
> Feb 21 20:46:33 tippex [<c0234356>] _raw_write_unlock+0x56/0x60
> Feb 21 20:46:33 tippex [<c040365d>] _write_unlock+0x1d/0x50
> Feb 21 20:46:33 tippex [<c03289be>] neigh_timer_handler+0x18e/0x2d0
> Feb 21 20:46:33 tippex [<c0125449>] run_timer_softirq+0x119/0x180
> Feb 21 20:46:33 tippex [<c013856d>] ? lock_release_holdtime+0x5d/0x80
> Feb 21 20:46:33 tippex [<c0328830>] ? neigh_timer_handler+0x0/0x2d0
> Feb 21 20:46:33 tippex [<c0121a64>] __do_softirq+0x54/0xb0
> Feb 21 20:46:33 tippex [<c0121af5>] do_softirq+0x35/0x40
> Feb 21 20:46:33 tippex [<c0121cb4>] irq_exit+0x44/0x50
> Feb 21 20:46:33 tippex [<c0105757>] do_IRQ+0x47/0x80
> Feb 21 20:46:33 tippex [<c01039c3>] common_interrupt+0x23/0x28
> Feb 21 20:46:33 tippex =======================

This needs to be CCed to netdev.

Any chance that

	git revert 69cc64d8d92

makes this report go away?

-- 
Jiri Kosina
SUSE Labs

