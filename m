From: denys@visp.net.lb
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 23 Jul 2008 22:47:17 +0300
Message-ID: <200807232247.17218.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200807222346.36284.denys@visp.net.lb> <20080722213603.GA3026@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:57318 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553AbYGWTr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 15:47:29 -0400
In-Reply-To: <20080722213603.GA3026@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems none of patches help with issue.
I will recheck if i apply them correctly.

Here is latest.
Jul 23 21:37:19 10.154.154.1 [28896.091934] Process swapper (pid: 0, ti=c0842000 task=f7c35c80 task.ti=f7c3d000)
Jul 23 21:37:19 10.154.154.1
Jul 23 21:37:19 10.154.154.1 [28896.091934] Stack:
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 c0842eec
Jul 23 21:37:19 10.154.154.1 c01d7cc9
Jul 23 21:37:19 10.154.154.1 c2df6498
Jul 23 21:37:19 10.154.154.1 00000000
Jul 23 21:37:19 10.154.154.1 00000000
Jul 23 21:37:19 10.154.154.1
Jul 23 21:37:19 10.154.154.1 [28896.091934]
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 f6ce64c8
Jul 23 21:37:19 10.154.154.1 c2df6490
Jul 23 21:37:19 10.154.154.1 c0842f0c
Jul 23 21:37:19 10.154.154.1 c0133e9c
Jul 23 21:37:19 10.154.154.1 00000001
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 00000000
Jul 23 21:37:19 10.154.154.1
Jul 23 21:37:19 10.154.154.1 [28896.091934]
Jul 23 21:37:19 10.154.154.1 c2df6490
Jul 23 21:37:19 10.154.154.1 f6ce64c4
Jul 23 21:37:19 10.154.154.1 c2df6490
Jul 23 21:37:19 10.154.154.1 c0842f34
Jul 23 21:37:19 10.154.154.1 c01344d3
Jul 23 21:37:19 10.154.154.1 c2df6484
Jul 23 21:37:19 10.154.154.1 76103400
Jul 23 21:37:19 10.154.154.1 00001a45
Jul 23 21:37:19 10.154.154.1
Jul 23 21:37:19 10.154.154.1 [28896.091934] Call Trace:
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c01d7cc9>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 rb_insert_color+0x99/0xbc
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0133e9c>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 enqueue_hrtimer+0xfa/0x106
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c01344d3>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 hrtimer_start+0xee/0x118
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0267db2>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 qdisc_watchdog_schedule+0x19/0x1f
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<f89eadf3>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 htb_dequeue+0x6a8/0x6b3 [sch_htb]
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0266e5d>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 __qdisc_run+0x5f/0x191
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c025b1a5>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 net_tx_action+0xb4/0xda
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0125817>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 __do_softirq+0x6f/0xe9
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c010614b>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 do_softirq+0x5e/0xa8
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0146f79>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 handle_edge_irq+0x0/0x10a
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0125775>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 irq_exit+0x44/0x77
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0106235>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 do_IRQ+0xa0/0xb7
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0108fb5>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 mwait_idle+0x0/0x43
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c01042fa>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 common_interrupt+0x2e/0x34
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0108fb5>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 mwait_idle+0x0/0x43
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c01300d8>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 param_set_copystring+0x36/0x60
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0108fee>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 mwait_idle+0x39/0x43
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c0102596>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 cpu_idle+0x9a/0xba
Jul 23 21:37:19 10.154.154.1 [28896.091934]  [<c02af0a7>]
Jul 23 21:37:19 10.154.154.1 ?
Jul 23 21:37:19 10.154.154.1 start_secondary+0x160/0x165
Jul 23 21:37:19 10.154.154.1 [28896.091934]  =======================
Jul 23 21:37:19 10.154.154.1 [28896.091934] Code:
Jul 23 21:37:19 10.154.154.1 09
Jul 23 21:37:19 10.154.154.1 8b
Jul 23 21:37:19 10.154.154.1 01
Jul 23 21:37:19 10.154.154.1 83
Jul 23 21:37:19 10.154.154.1 e0
Jul 23 21:37:19 10.154.154.1 03
Jul 23 21:37:19 10.154.154.1 09
Jul 23 21:37:19 10.154.154.1 d8
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 01
Jul 23 21:37:19 10.154.154.1 8b
Jul 23 21:37:19 10.154.154.1 02
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 5a
Jul 23 21:37:19 10.154.154.1 08
Jul 23 21:37:19 10.154.154.1 83
Jul 23 21:37:19 10.154.154.1 e0
Jul 23 21:37:19 10.154.154.1 03
Jul 23 21:37:19 10.154.154.1 09
Jul 23 21:37:19 10.154.154.1 f0
Jul 23 21:37:19 10.154.154.1 85
Jul 23 21:37:19 10.154.154.1 f6
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 02
Jul 23 21:37:19 10.154.154.1 74
Jul 23 21:37:19 10.154.154.1 0f
Jul 23 21:37:19 10.154.154.1 3b
Jul 23 21:37:19 10.154.154.1 5e
Jul 23 21:37:19 10.154.154.1 08
Jul 23 21:37:19 10.154.154.1 75
Jul 23 21:37:19 10.154.154.1 05
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 56
Jul 23 21:37:19 10.154.154.1 08
Jul 23 21:37:19 10.154.154.1 eb
Jul 23 21:37:19 10.154.154.1 07
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 56
Jul 23 21:37:19 10.154.154.1 04
Jul 23 21:37:19 10.154.154.1 eb
Jul 23 21:37:19 10.154.154.1 02
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 17
Jul 23 21:37:19 10.154.154.1 unparseable log message: "<8b> "
Jul 23 21:37:19 10.154.154.1 03
Jul 23 21:37:19 10.154.154.1 83
Jul 23 21:37:19 10.154.154.1 e0
Jul 23 21:37:19 10.154.154.1 03
Jul 23 21:37:19 10.154.154.1 09
Jul 23 21:37:19 10.154.154.1 d0
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 03
Jul 23 21:37:19 10.154.154.1 5b
Jul 23 21:37:19 10.154.154.1 5e
Jul 23 21:37:19 10.154.154.1 5f
Jul 23 21:37:19 10.154.154.1 5d
Jul 23 21:37:19 10.154.154.1 c3
Jul 23 21:37:19 10.154.154.1 55
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 e5
Jul 23 21:37:19 10.154.154.1 57
Jul 23 21:37:19 10.154.154.1 89
Jul 23 21:37:19 10.154.154.1 d7
Jul 23 21:37:19 10.154.154.1 56
Jul 23 21:37:19 10.154.154.1


On Wednesday 23 July 2008, Jarek Poplawski wrote:
> On Tue, Jul 22, 2008 at 11:46:36PM +0300, denys@visp.net.lb wrote:
> > First patch - probably not related. Netconsole is on e100.
> > Second patch looks reasonable, because there is external interface (it is router) and e1000e there, with enabled TSO. Maybe some scanning tools doing connect to SSH and... BOOM.. i will try to patch it, thanks a lot!
> 
> On the other hand, it seems the corruption of skbs fixed by this
> second patch should probably show in some other places...
> 
> I wonder if you tried to run this without netconsole (or maybe
> netconsole on another dev/driver) or without this NMI watchdog,
> and similar lockups still happened?
> 
> Jarek P.
> 
> > 
> > On Tuesday 22 July 2008, Jarek Poplawski wrote:
> > > Jarek Poplawski wrote, On 07/22/2008 10:13 PM:
> > > 
> > > > denys@visp.net.lb wrote, On 07/22/2008 08:42 PM:
> > > > 
> > > >> workload: ifb shapers, HTB, nat, 1 e1000, 3 e100 (heavily used only two e100)
> > > >>
> > > > 
> > > > 
> > > > Maybe it's unconnected but I'd recommend to try this fresh patch for
> > > > possible problems with e1000e vs. netconsole:
> > > > 
> > > > http://permalink.gmane.org/gmane.linux.network/100581
> > >  
> > > 
> > > ...and if you have TSO enabled, here is another "maybe unconnected"
> > > recommendation:
> > > 
> > > http://permalink.gmane.org/gmane.linux.network/99585
> > > 
> > > Jarek P.
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


