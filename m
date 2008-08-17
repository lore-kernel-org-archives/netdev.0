From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 14:38:25 +0200
Message-ID: <20080817123825.GE2907@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171301.56002.denys@visp.net.lb> <20080817105534.GD2907@ami.dom.local> <200808171506.06292.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:21560 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbYHQMhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 08:37:21 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1853454ika.5
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 05:37:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171506.06292.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 03:06:06PM +0300, Denys Fedoryshchenko wrote:
> Seems stable (without this patch yet) on normal shaper, and 
> crashing on new version of shaper (it is doing very intensive 
> classes creation/destroy).
> 
> I'm not sure if it is same bug, i will try to test on regular shaper
> more things.
> 
> I will try to apply last patch also and test on another pppoe 
> server.

Denys, I would like to be sure: do you mean here the last patch
attached below? So, the alternative shaper works with previous
patches, but not this one? If so, than no need to test this patch
anymore, only confirm this, please.

Jarek P.

> 
> 
> Here is panic i got when i try to run alternative shaper.
> 
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] BUG: unable to handle kernel
> Aug 17 15:01:54 192.168.20.66 paging request
> Aug 17 15:01:54 192.168.20.66 at 50639a62
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] IP:
> Aug 17 15:01:54 192.168.20.66 [<c025fd4e>] net_tx_action+0x78/0xd8
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Oops: 0000 [#1]
> Aug 17 15:01:54 192.168.20.66 SMP
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Modules linked in:
> Aug 17 15:01:54 192.168.20.66 cls_flow
> Aug 17 15:01:54 192.168.20.66 act_police
> Aug 17 15:01:54 192.168.20.66 sch_ingress
> Aug 17 15:01:54 192.168.20.66 sch_prio
> Aug 17 15:01:54 192.168.20.66 netconsole
> Aug 17 15:01:54 192.168.20.66 configfs
> Aug 17 15:01:54 192.168.20.66 nf_nat_pptp
> Aug 17 15:01:54 192.168.20.66 nf_nat_proto_gre
> Aug 17 15:01:54 192.168.20.66 nf_conntrack_pptp
> Aug 17 15:01:54 192.168.20.66 nf_conntrack_proto_gre
> Aug 17 15:01:54 192.168.20.66 iTCO_wdt
> Aug 17 15:01:54 192.168.20.66 e752x_edac
> Aug 17 15:01:54 192.168.20.66 edac_core
> Aug 17 15:01:54 192.168.20.66 cls_u32
> Aug 17 15:01:54 192.168.20.66 em_meta
> Aug 17 15:01:54 192.168.20.66 cls_basic
> Aug 17 15:01:54 192.168.20.66 xt_dscp
> Aug 17 15:01:54 192.168.20.66 xt_DSCP
> Aug 17 15:01:54 192.168.20.66 ipt_REJECT
> Aug 17 15:01:54 192.168.20.66 ts_bm
> Aug 17 15:01:54 192.168.20.66 xt_string
> Aug 17 15:01:54 192.168.20.66 ipt_ttl
> Aug 17 15:01:54 192.168.20.66 ifb
> Aug 17 15:01:54 192.168.20.66 cls_fw
> Aug 17 15:01:54 192.168.20.66 sch_tbf
> Aug 17 15:01:54 192.168.20.66 sch_htb
> Aug 17 15:01:54 192.168.20.66 act_ipt
> Aug 17 15:01:54 192.168.20.66 act_mirred
> Aug 17 15:01:54 192.168.20.66 xt_MARK
> Aug 17 15:01:54 192.168.20.66 pppoe
> Aug 17 15:01:54 192.168.20.66 pppox
> Aug 17 15:01:54 192.168.20.66 ppp_generic
> Aug 17 15:01:54 192.168.20.66 slhc
> Aug 17 15:01:54 192.168.20.66 xt_TCPMSS
> Aug 17 15:01:54 192.168.20.66 xt_mark
> Aug 17 15:01:54 192.168.20.66 xt_tcpudp
> Aug 17 15:01:54 192.168.20.66 iptable_mangle
> Aug 17 15:01:54 192.168.20.66 iptable_nat
> Aug 17 15:01:54 192.168.20.66 nf_nat
> Aug 17 15:01:54 192.168.20.66 nf_conntrack_ipv4
> Aug 17 15:01:54 192.168.20.66 nf_conntrack
> Aug 17 15:01:54 192.168.20.66 rtc_cmos
> Aug 17 15:01:54 192.168.20.66 rtc_core
> Aug 17 15:01:54 192.168.20.66 rtc_lib
> Aug 17 15:01:54 192.168.20.66 iptable_filter
> Aug 17 15:01:54 192.168.20.66 ip_tables
> Aug 17 15:01:54 192.168.20.66 x_tables
> Aug 17 15:01:54 192.168.20.66 8021q
> Aug 17 15:01:54 192.168.20.66 garp
> Aug 17 15:01:54 192.168.20.66 stp
> Aug 17 15:01:54 192.168.20.66 llc
> Aug 17 15:01:54 192.168.20.66 tun
> Aug 17 15:01:54 192.168.20.66 loop
> Aug 17 15:01:54 192.168.20.66 tulip
> Aug 17 15:01:54 192.168.20.66 r8169
> Aug 17 15:01:54 192.168.20.66 sky2
> Aug 17 15:01:54 192.168.20.66 via_velocity
> Aug 17 15:01:54 192.168.20.66 via_rhine
> Aug 17 15:01:54 192.168.20.66 sis900
> Aug 17 15:01:54 192.168.20.66 ne2k_pci
> Aug 17 15:01:54 192.168.20.66 8390
> Aug 17 15:01:54 192.168.20.66 skge
> Aug 17 15:01:54 192.168.20.66 tg3
> Aug 17 15:01:54 192.168.20.66 libphy
> Aug 17 15:01:54 192.168.20.66 8139too
> Aug 17 15:01:54 192.168.20.66 e1000
> Aug 17 15:01:54 192.168.20.66 e100
> Aug 17 15:01:54 192.168.20.66 usb_storage
> Aug 17 15:01:54 192.168.20.66 mtdblock
> Aug 17 15:01:54 192.168.20.66 mtd_blkdevs
> Aug 17 15:01:54 192.168.20.66 usbhid
> Aug 17 15:01:54 192.168.20.66 uhci_hcd
> Aug 17 15:01:54 192.168.20.66 ehci_hcd
> Aug 17 15:01:54 192.168.20.66 ohci_hcd
> Aug 17 15:01:54 192.168.20.66 usbcore
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Pid: 4, comm: ksoftirqd/0 Not tainted (2.6.27-rc3-git3-build-0031 #7)
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] EIP: 0060:[<c025fd4e>] EFLAGS: 00010206 CPU: 0
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] EIP is at net_tx_action+0x78/0xd8
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] EAX: 01deb6a8 EBX: 506399ee ECX: 00000002 EDX: 00000001
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] ESI: f6429224 EDI: f6429238 EBP: c0861fd4 ESP: c0861fc4
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Process ksoftirqd/0 (pid: 4, ti=c0861000 task=f78399b0 task.ti=f7841000)
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Stack:
> Aug 17 15:01:54 192.168.20.66 506399ee
> Aug 17 15:01:54 192.168.20.66 c039ea88
> Aug 17 15:01:54 192.168.20.66 c085a554
> Aug 17 15:01:54 192.168.20.66 00000003
> Aug 17 15:01:54 192.168.20.66 c0861ff8
> Aug 17 15:01:54 192.168.20.66 c012626b
> Aug 17 15:01:54 192.168.20.66 c085d700
> Aug 17 15:01:54 192.168.20.66 c085d700
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]
> Aug 17 15:01:54 192.168.20.66 00000006
> Aug 17 15:01:54 192.168.20.66 00000000
> Aug 17 15:01:54 192.168.20.66 f7841fac
> Aug 17 15:01:54 192.168.20.66 f7841000
> Aug 17 15:01:54 192.168.20.66 c01261f0
> Aug 17 15:01:54 192.168.20.66 f7841fbc
> Aug 17 15:01:54 192.168.20.66 c01060b3
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Call Trace:
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c012626b>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 __do_softirq+0x7b/0xf4
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c01261f0>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 __do_softirq+0x0/0xf4
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c01060b3>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 do_softirq+0x65/0xb6
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c0125cfc>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 ksoftirqd+0x59/0xc8
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c0125ca3>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 ksoftirqd+0x0/0xc8
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c01320e5>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 k
> Aug 17 15:01:54 192.168.20.66 thread+0x3b/0x61
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c01320aa>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 kthread+0x0/0x61
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  [<c010451b>]
> Aug 17 15:01:54 192.168.20.66 ?
> Aug 17 15:01:54 192.168.20.66 kernel_thread_helper+0x7/0x10
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634]  =======================
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] Code:
> Aug 17 15:01:54 192.168.20.66 1e
> Aug 17 15:01:54 192.168.20.66 ec
> Aug 17 15:01:54 192.168.20.66 ff
> Aug 17 15:01:54 192.168.20.66 89
> Aug 17 15:01:54 192.168.20.66 d8
> Aug 17 15:01:54 192.168.20.66 89
> Aug 17 15:01:54 192.168.20.66 fb
> Aug 17 15:01:54 192.168.20.66 e8
> Aug 17 15:01:54 192.168.20.66 6e
> Aug 17 15:01:54 192.168.20.66 c2
> Aug 17 15:01:54 192.168.20.66 ff
> Aug 17 15:01:54 192.168.20.66 ff
> Aug 17 15:01:54 192.168.20.66 85
> Aug 17 15:01:54 192.168.20.66 db
> Aug 17 15:01:54 192.168.20.66 75
> Aug 17 15:01:54 192.168.20.66 d9
> Aug 17 15:01:54 192.168.20.66 83
> Aug 17 15:01:54 192.168.20.66 3e
> Aug 17 15:01:54 192.168.20.66 00
> Aug 17 15:01:54 192.168.20.66 74
> Aug 17 15:01:54 192.168.20.66 70
> Aug 17 15:01:54 192.168.20.66 fa
> Aug 17 15:01:54 192.168.20.66 e8
> Aug 17 15:01:54 192.168.20.66 e7
> Aug 17 15:01:54 192.168.20.66 ca
> Aug 17 15:01:54 192.168.20.66 ed
> Aug 17 15:01:54 192.168.20.66 ff
> Aug 17 15:01:54 192.168.20.66 8b
> Aug 17 15:01:54 192.168.20.66 1e
> Aug 17 15:01:54 192.168.20.66 c7
> Aug 17 15:01:54 192.168.20.66 06
> Aug 17 15:01:54 192.168.20.66 00
> Aug 17 15:01:54 192.168.20.66 00
> Aug 17 15:01:54 192.168.20.66 00
> Aug 17 15:01:54 192.168.20.66 00
> Aug 17 15:01:54 192.168.20.66 e8
> Aug 17 15:01:54 192.168.20.66 c1
> Aug 17 15:01:54 192.168.20.66 dd
> Aug 17 15:01:54 192.168.20.66 ed
> Aug 17 15:01:54 192.168.20.66 ff
> Aug 17 15:01:54 192.168.20.66 fb
> Aug 17 15:01:54 192.168.20.66 eb
> Aug 17 15:01:54 192.168.20.66 56
> Aug 17 15:01:54 192.168.20.66 unparseable log message: "<8b> "
> Aug 17 15:01:54 192.168.20.66 43
> Aug 17 15:01:54 192.168.20.66 74
> Aug 17 15:01:54 192.168.20.66 89
> Aug 17 15:01:54 192.168.20.66 45
> Aug 17 15:01:54 192.168.20.66 f0
> Aug 17 15:01:54 192.168.20.66 8d
> Aug 17 15:01:54 192.168.20.66 73
> Aug 17 15:01:54 192.168.20.66 24
> Aug 17 15:01:54 192.168.20.66 f0
> Aug 17 15:01:54 192.168.20.66 80
> Aug 17 15:01:54 192.168.20.66 63
> Aug 17 15:01:54 192.168.20.66 24
> Aug 17 15:01:54 192.168.20.66 fd
> Aug 17 15:01:54 192.168.20.66 f6
> Aug 17 15:01:54 192.168.20.66 43
> Aug 17 15:01:54 192.168.20.66 08
> Aug 17 15:01:54 192.168.20.66 01
> Aug 17 15:01:54 192.168.20.66 8d
> Aug 17 15:01:54 192.168.20.66 7b
> Aug 17 15:01:54 192.168.20.66 38
> Aug 17 15:01:54 192.168.20.66
> Aug 17 15:01:54 192.168.20.66 [ 7222.089634] EIP: [<c025fd4e>]
> Aug 17 15:01:54 192.168.20.66 net_tx_action+0x78/0xd8
> Aug 17 15:01:54 192.168.20.66 SS:ESP 0068:c0861fc4
> Aug 17 15:01:54 192.168.20.66 [ 7222.094000] Kernel panic - not syncing: Fatal exception in interrupt
> Aug 17 15:01:54 192.168.20.66 [ 7222.094626] Rebooting in 5 seconds..
> 
> 
> On Sunday 17 August 2008, Jarek Poplawski wrote:
> > On Sun, Aug 17, 2008 at 01:01:55PM +0300, Denys Fedoryshchenko wrote:
> > > Ok, now things finally organized.
> > > fixing patch #1 was missing.
> > >
> > > Rebooting system to this kernel. But strange thing, without fixing patch
> > > #1 it didn't crash for whole night, and 1-3 hours now (with same options
> > > as before).
> > >
> > > Let's test now complete set of patches. I will keep around 2 hours on
> > > most loaded pppoe NAS, then distribute to 2-3 servers more if it doesn't
> > > crash.
> >
> > BTW, after you complete this testing (no hurry) I would be glad if you
> > could try one more patch which I send earlier to the list. IMHO, it's
> > needed to fix some other locking problems. This patch could be applied
> > and tested as an addition to all currently tested patches (but let's
> > first be sure they really work).
> >
> > Thanks,
> > Jarek P.
> >
> > ------------->
> >
> > pkt_sched: Destroy qdiscs under rtnl_lock again.
> >
> > We don't need to trigger __qdisc_destroy() as an RCU callback because
> > the use of qdisc isn't controlled by RCU alone: after querying RCU
> > with synchronize_rcu() in dev_deactivate() we additionaly wait in a
> > loop checking some flags. After the loop is done there could be no
> > outstanding use of the qdisc, so call_rcu() doesn't make any sense.
> >
> > On the other hand, current calling Qdisc's ->destroy() from a softirq
> > context without locking (rtnl) can break various things like:
> > qdisc_put_rtab(), tcf_destroy_chain() (e.g. u32_destroy()), and
> > probably more.
> >
> >
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >
> > ---
> >
> >  net/sched/sch_generic.c |    8 ++------
> >  1 files changed, 2 insertions(+), 6 deletions(-)
> >
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index 4685746..e7379d2 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -518,12 +518,8 @@ void qdisc_reset(struct Qdisc *qdisc)
> >  }
> >  EXPORT_SYMBOL(qdisc_reset);
> >
> > -/* this is the rcu callback function to clean up a qdisc when there
> > - * are no further references to it */
> > -
> > -static void __qdisc_destroy(struct rcu_head *head)
> > +static void __qdisc_destroy(struct Qdisc *qdisc)
> >  {
> > -	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
> >  	const struct Qdisc_ops  *ops = qdisc->ops;
> >
> >  #ifdef CONFIG_NET_SCHED
> > @@ -554,7 +550,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
> >  	if (qdisc->parent)
> >  		list_del(&qdisc->list);
> >
> > -	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
> > +	__qdisc_destroy(qdisc);
> >  }
> >  EXPORT_SYMBOL(qdisc_destroy);
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
