From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: [Bugme-new] [Bug 10435] New: IRQ problem using PLIP installing
 linux on OLD IBM laptop
Date: Thu, 10 Apr 2008 19:13:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804101910330.27545@artax.karlin.mff.cuni.cz>
References: <bug-10435-10286@http.bugzilla.kernel.org/>
 <20080410094639.991b6372.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	cijoml@volny.cz
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artax.karlin.mff.cuni.cz ([195.113.31.125]:49956 "EHLO
	artax.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756701AbYDJRh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 13:37:58 -0400
In-Reply-To: <20080410094639.991b6372.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 10 Apr 2008, Andrew Morton wrote:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 10 Apr 2008 02:27:07 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10435
> > 
> >            Summary: IRQ problem using PLIP installing linux on OLD IBM
> >                     laptop
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.24.4-vanilla, 2.6.18-debian-stable
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Parallel
> >         AssignedTo: drivers_parallel@kernel-bugs.osdl.org
> >         ReportedBy: cijoml@volny.cz
> > 
> > 
> > Latest working kernel version:
> > Earliest failing kernel version:
> > Distribution:
> > Hardware Environment: PLIP, LPT
> > Software Environment: Debian stable, Debian testing
> > Problem Description:
> > 
> > plip0: checksum error
> > Unbalanced enable for IRQ 7
> > WARNING: at kernel/irq/manage.c:174 enable_irq()
> > Pid: 8, comm: events/1 Not tainted 2.6.24.4 #3
> > 
> > Call Trace:
> >  [<ffffffff80264f11>] enable_irq+0x7a/0xba
> >  [<ffffffff8817cac8>] :plip:plip_error+0x7b/0xaf
> >  [<ffffffff8817c21b>] :plip:plip_bh+0x4e/0x274
> >  [<ffffffff8817c1cd>] :plip:plip_bh+0x0/0x274
> >  [<ffffffff8024227e>] run_workqueue+0x87/0x11a
> >  [<ffffffff80242c96>] worker_thread+0xe1/0xf0
> >  [<ffffffff80245de4>] autoremove_wake_function+0x0/0x2e
> >  [<ffffffff80242bb5>] worker_thread+0x0/0xf0
> >  [<ffffffff80245cc2>] kthread+0x47/0x75
> >  [<ffffffff8020c5e8>] child_rip+0xa/0x12
> >  [<ffffffff80245c7b>] kthread+0x0/0x75
> >  [<ffffffff8020c5de>] child_rip+0x0/0x12
> > 
> > I see little bit different stack trace also at old IBM laptop side. 
> > Will try post photo. There are also lot of plip0: transmit 
> > timeout(1,80) messages on both sides.

Regarding the timeouts --- shouldn't the plip timeout message be removed? 
Or enabled only for debugging? The protocol is (mis)designed in such a way 
that timeouts are inevitable.

Mikulas
