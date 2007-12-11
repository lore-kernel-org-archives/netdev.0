From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Tue, 11 Dec 2007 12:30:27 -0800
Message-ID: <20071211123027.cd4faa19.akpm@linux-foundation.org>
References: <bug-9543-10286@http.bugzilla.kernel.org/>
	<20071211034603.cbcc4762.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0712111603250.21312@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56411 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756812AbXLKUas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 15:30:48 -0500
In-Reply-To: <Pine.LNX.4.64.0712111603250.21312@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 16:04:27 +0100 (CET) Krzysztof Oledzki <olel@ans.pl> wrote:

> >>  [<783bfa72>] rt_run_flush+0x43/0x8b
> >>  [<783bfa93>] rt_run_flush+0x64/0x8b
> >>  [<7813ac54>] notifier_call_chain+0x2a/0x52
> >>  [<7813ac9e>] raw_notifier_call_chain+0x17/0x1a
> >>  [<783a3471>] netdev_state_change+0x18/0x29
> >>  [<783ac6a9>] __linkwatch_run_queue+0x150/0x17e
> >>  [<783ac6f4>] linkwatch_event+0x1d/0x22
> >>  [<78133cdf>] run_workqueue+0xdb/0x1b6
> >>  [<78133c8b>] run_workqueue+0x87/0x1b6
> >>  [<783ac6d7>] linkwatch_event+0x0/0x22
> >>  [<781346ff>] worker_thread+0x0/0x85
> >>  [<78134778>] worker_thread+0x79/0x85
> >>  [<781371ad>] autoremove_wake_function+0x0/0x35
> >>  [<781370f6>] kthread+0x38/0x5e
> >>  [<781370be>] kthread+0x0/0x5e
> >>  [<78104baf>] kernel_thread_helper+0x7/0x10
> >>  =======================
> >> RTNL: assertion failed at net/ipv6/addrconf.c (1610)
> >
> >
> > Hopefully this is due to the bug you reported in bug #9542.
> >
> > Does this patch fix both issues?
> 
> Unfortunately not. I just updated bugzilla.

argh.  Please conduct these discussions via emailed reply-to-all, not via
the bugzilla web interface.

I think my patch _did_ fix http://bugzilla.kernel.org/show_bug.cgi?id=9542
But then you hit a new bonding locking bug.

Rafael, please track 9542 and 9543 as post-2.6.23 regressions, thanks.
