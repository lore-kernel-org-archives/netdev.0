From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Fwd: Re: Linux r8169 interrupt patch
Date: Sat, 21 Aug 2010 22:03:12 +0200
Message-ID: <201008212203.13062.rjw@sisk.pl>
References: <4C6FBF5D.2070409@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, romieu@fr.zoreil.com, davem@davemloft.net,
	adobriyan@gmail.com, jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alex <alexbtk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:32818 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab0HUUE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Aug 2010 16:04:26 -0400
In-Reply-To: <4C6FBF5D.2070409@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, August 21, 2010, Alex wrote:
> Hello gyus,
> 
> I am writing to you, on case of the linux r8169 interrupt bug. Sergey 
> gave me your addresses. I assume you can read all the neccessary 
> informations below. Please reopen the thread at the bugtracker.
> I have several servers running with this chipset and driver. In my case, 
> the problem is very critical. Network brokes even every day down. I can 
> provide some testing if you would give me some patches or solution tips.
> 
> Thanks in advance for your reply.

https://bugzilla.kernel.org/show_bug.cgi?id=15704 reopened.

Thanks,
Rafael


> -------- Original-Nachricht --------
> Betreff: 	Re: Linux r8169 interrupt patch
> Datum: 	Sat, 21 Aug 2010 14:14:36 +0300
> Von: 	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> An: 	alex <alexbtk@gmx.de>
> CC: 	sergey.senozhatsky@gmail.com
> 
> 
> 
> On (08/20/10 22:24), alex wrote:
> >  Date: Fri, 20 Aug 2010 22:24:20 +0200
> >  From: alex<alexbtk@gmx.de>
> >  To: sergey.senozhatsky@gmail.com
> >  Subject: Linux r8169 interrupt patch
> >  User-Agent: Opera Mail/10.61 (Win32)
> >
> >  Hello Sergey,
> >
> 
> Hello Alex,
> 
> >  I write to you, because of your conversation in this tracker:
> >  http://patchwork.ozlabs.org/patch/47889/
> >
> >  I have the same problem on the 2.6.33.7 kernel. I even upgraded
> >  yesterday from 2.6.33.6, hoping to solve this bug. My kernel-panic
> >  occurs even every day. That's very disgustig.
> >  Here the trace:
> >
> >  Aug 20 02:41:48 het1 kernel: [49652.963863] ------------[ cut here
> >  ]------------
> >  Aug 20 02:41:48 het1 kernel: [49652.964033] WARNING: at
> >  net/sched/sch_generic.c:259 dev_watchdog+0x14d/0x208()
> >  Aug 20 02:41:48 het1 kernel: [49652.964346] Hardware name: MS-7522
> >  Aug 20 02:41:48 het1 kernel: [49652.964504] NETDEV WATCHDOG: eth0
> >  (r8169): transmit queue 0 timed out
> >  Aug 20 02:41:48 het1 kernel: [49652.964670] Pid: 71, comm:
> >  sirq-timer/5 Not tainted 2.6.33.7-rt29 #1
> >  Aug 20 02:41:48 het1 kernel: [49652.964835] Call Trace:
> >  Aug 20 02:41:48 het1 kernel: [49652.964997]  [<ffffffff812fcf32>] ?
> >  dev_watchdog+0x14d/0x208
> >  Aug 20 02:41:48 het1 kernel: [49652.965001]  [<ffffffff8103233c>] ?
> >  warn_slowpath_common+0x72/0x9e
> >  Aug 20 02:41:48 het1 kernel: [49652.965004]  [<ffffffff810323c4>] ?
> >  warn_slowpath_fmt+0x51/0x59
> >  Aug 20 02:41:48 het1 kernel: [49652.965008]  [<ffffffff8102e474>] ?
> >  try_to_wake_up+0x351/0x37f
> >  Aug 20 02:41:48 het1 kernel: [49652.965012]  [<ffffffff8106dce4>] ?
> >  cpupri_set+0x10f/0x138
> >  Aug 20 02:41:48 het1 kernel: [49652.965016]  [<ffffffff812ebb40>] ?
> >  netdev_drivername+0x3b/0x40
> >  Aug 20 02:41:48 het1 kernel: [49652.965019]  [<ffffffff812fcf32>] ?
> >  dev_watchdog+0x14d/0x208
> >  Aug 20 02:41:48 het1 kernel: [49652.965022]  [<ffffffff81027e68>] ?
> >  update_curr_rt+0x114/0x18b
> >  Aug 20 02:41:48 het1 kernel: [49652.965025]  [<ffffffff8102c972>] ?
> >  finish_task_switch+0x4a/0xa3
> >  Aug 20 02:41:48 het1 kernel: [49652.965028]  [<ffffffff812fcde5>] ?
> >  dev_watchdog+0x0/0x208
> >  Aug 20 02:41:48 het1 kernel: [49652.965031]  [<ffffffff8103b688>] ?
> >  run_timer_softirq+0x20b/0x2a9
> >  Aug 20 02:41:48 het1 kernel: [49652.965035]  [<ffffffff81036b50>] ?
> >  run_ksoftirqd+0x182/0x2a6
> >  Aug 20 02:41:48 het1 kernel: [49652.965038]  [<ffffffff810369ce>] ?
> >  run_ksoftirqd+0x0/0x2a6
> >  Aug 20 02:41:48 het1 kernel: [49652.965041]  [<ffffffff81044759>] ?
> >  kthread+0x79/0x81
> >  Aug 20 02:41:48 het1 kernel: [49652.965044]  [<ffffffff8102c972>] ?
> >  finish_task_switch+0x4a/0xa3
> >  Aug 20 02:41:48 het1 kernel: [49652.965048]  [<ffffffff81003714>] ?
> >  kernel_thread_helper+0x4/0x10
> >  Aug 20 02:41:48 het1 kernel: [49652.965051]  [<ffffffff810446e0>] ?
> >  kthread+0x0/0x81
> >  Aug 20 02:41:48 het1 kernel: [49652.965053]  [<ffffffff81003710>] ?
> >  kernel_thread_helper+0x0/0x10
> >  Aug 20 02:41:48 het1 kernel: [49652.965055] ---[ end trace
> >  1af3434dfa0224f2 ]---
> >
> >  I read that the patch fix the rx_interrupt(), but as I can see in my
> >  case, he fails while sending the packets "transmit queue 0 timed
> >  out".
> >  My question now: Have you solved the problem? If yes, by applying the
> >  patch?
> >
> 
> No, unfortunately no. The problem is that this laptop (with r8169) is no longer
> available.
> 
> We had a later conversation with Eric, and he had proposed several patches
> (none of them, however didn't solve the problem).
> 
> So, I'll recommend to contanct Eric Dumazet<eric.dumazet@gmail.com>
> and "Rafael J. Wysocki"<rjw@sisk.pl>  to reopen bug entry:
> 
> >  Bug-Entry   : http://bugzilla.kernel.org/show_bug.cgi?id=15704
> >  Subject             : [r8169] WARNING: at net/sched/sch_generic.c
> >  Submitter   : Sergey Senozhatsky<sergey.senozhatsky@gmail.com>
> >  Date                : 2010-03-31 10:21 (124 days old)
> >  Message-ID  :<20100331102142.GA3294@swordfish.minsk.epam.com>
> >  References  : http://marc.info/?l=linux-kernel&m=127003090406108&w=2
> >
> 
> as now we have hardware to reproduce this.
> 
> Maintainers of r8169 are:
> Francois Romieu<romieu@fr.zoreil.com>
> "David S. Miller"<davem@davemloft.net>
> Alexey Dobriyan<adobriyan@gmail.com>
> Jiri Pirko<jpirko@redhat.com>
> netdev@vger.kernel.org
> linux-kernel@vger.kernel.org
> 
> So, please Cc them too.
> 
> 
> >  Thanks for your answer in advance, I hope to hear from you soon.
> >
> >  Best regards
> >  Alexey Batyuk
> >
> 
> All the best,
> 
> 	
> 	Sergey
> 
> 
> 

