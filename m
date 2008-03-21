From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: possible lockdep crash (was Re: kernel panic, ip_route_input, 2.6.25-rc6-git2)
Date: Fri, 21 Mar 2008 12:59:05 +0200
Message-ID: <20080321105821.M24815@visp.net.lb>
References: <20080321093052.M39677@visp.net.lb> <20080321.033530.249188954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45186 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbYCUK7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 06:59:21 -0400
In-Reply-To: <20080321.033530.249188954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is one more, it's seems easy to reproduce, but seems it is same. But 
maybe will be useful.

Mar 21 12:56:46 205.177.186.74 [   31.387311] BUG: unable to handle kernel
Mar 21 12:56:46 205.177.186.74 paging request
Mar 21 12:56:46 205.177.186.74 at c013d19a
Mar 21 12:56:46 205.177.186.74 [   31.387427] IP:
Mar 21 12:56:46 205.177.186.74 [<c0285798>] ip_route_input+0xa70/0xe56
Mar 21 12:56:46 205.177.186.74 [   31.387505] Oops: 0003 [#1]
Mar 21 12:56:46 205.177.186.74 SMP
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.387602] Modules linked in:
Mar 21 12:56:46 205.177.186.74 softdog
Mar 21 12:56:46 205.177.186.74 nf_nat_pptp
Mar 21 12:56:46 205.177.186.74 nf_nat_proto_gre
Mar 21 12:56:46 205.177.186.74 nf_conntrack_pptp
Mar 21 12:56:46 205.177.186.74 nf_conntrack_proto_gre
Mar 21 12:56:46 205.177.186.74 netconsole
Mar 21 12:56:46 205.177.186.74 configfs
Mar 21 12:56:46 205.177.186.74 hangcheck_timer
Mar 21 12:56:46 205.177.186.74 xt_tcpudp
Mar 21 12:56:46 205.177.186.74 ipt_TTL
Mar 21 12:56:46 205.177.186.74 ipt_ttl
Mar 21 12:56:46 205.177.186.74 xt_NOTRACK
Mar 21 12:56:46 205.177.186.74 iptable_raw
Mar 21 12:56:46 205.177.186.74 iptable_mangle
Mar 21 12:56:46 205.177.186.74 ifb
Mar 21 12:56:46 205.177.186.74 e1000e
Mar 21 12:56:46 205.177.186.74 em_nbyte
Mar 21 12:56:46 205.177.186.74 cls_tcindex
Mar 21 12:56:46 205.177.186.74 act_gact
Mar 21 12:56:46 205.177.186.74 cls_rsvp
Mar 21 12:56:46 205.177.186.74 sch_htb
Mar 21 12:56:46 205.177.186.74 cls_fw
Mar 21 12:56:46 205.177.186.74 act_mirred
Mar 21 12:56:46 205.177.186.74 em_u32
Mar 21 12:56:46 205.177.186.74 sch_red
Mar 21 12:56:46 205.177.186.74 sch_sfq
Mar 21 12:56:46 205.177.186.74 sch_tbf
Mar 21 12:56:46 205.177.186.74 sch_teql
Mar 21 12:56:46 205.177.186.74 cls_basic
Mar 21 12:56:46 205.177.186.74 act_police
Mar 21 12:56:46 205.177.186.74 sch_gred
Mar 21 12:56:46 205.177.186.74 act_pedit
Mar 21 12:56:46 205.177.186.74 sch_hfsc
Mar 21 12:56:46 205.177.186.74 cls_rsvp6
Mar 21 12:56:46 205.177.186.74 sch_ingress
Mar 21 12:56:46 205.177.186.74 em_meta
Mar 21 12:56:46 205.177.186.74 em_text
Mar 21 12:56:46 205.177.186.74 act_ipt
Mar 21 12:56:46 205.177.186.74 sch_dsmark
Mar 21 12:56:46 205.177.186.74 sch_prio
Mar 21 12:56:46 205.177.186.74 sch_netem
Mar 21 12:56:46 205.177.186.74 act_simple
Mar 21 12:56:46 205.177.186.74 cls_u32
Mar 21 12:56:46 205.177.186.74 em_cmp
Mar 21 12:56:46 205.177.186.74 sch_cbq
Mar 21 12:56:46 205.177.186.74 cls_route
Mar 21 12:56:46 205.177.186.74 xt_TCPMSS
Mar 21 12:56:46 205.177.186.74 iptable_nat
Mar 21 12:56:46 205.177.186.74 nf_conntrack_ipv4
Mar 21 12:56:46 205.177.186.74 ipt_LOG
Mar 21 12:56:46 205.177.186.74 ipt_MASQUERADE
Mar 21 12:56:46 205.177.186.74 ipt_REDIRECT
Mar 21 12:56:46 205.177.186.74 nf_nat
Mar 21 12:56:46 205.177.186.74 nf_conntrack
Mar 21 12:56:46 205.177.186.74 nfnetlink
Mar 21 12:56:46 205.177.186.74 iptable_filter
Mar 21 12:56:46 205.177.186.74 ip_tables
Mar 21 12:56:46 205.177.186.74 x_tables
Mar 21 12:56:46 205.177.186.74 8021q
Mar 21 12:56:46 205.177.186.74 tun
Mar 21 12:56:46 205.177.186.74 tulip
Mar 21 12:56:46 205.177.186.74 r8169
Mar 21 12:56:46 205.177.186.74 sky2
Mar 21 12:56:46 205.177.186.74 via_velocity
Mar 21 12:56:46 205.177.186.74 via_rhine
Mar 21 12:56:46 205.177.186.74 sis900
Mar 21 12:56:46 205.177.186.74 ne2k_pci
Mar 21 12:56:46 205.177.186.74 8390
Mar 21 12:56:46 205.177.186.74 skge
Mar 21 12:56:46 205.177.186.74 tg3
Mar 21 12:56:46 205.177.186.74 8139too
Mar 21 12:56:46 205.177.186.74 e1000
Mar 21 12:56:46 205.177.186.74 e100
Mar 21 12:56:46 205.177.186.74 usb_storage
Mar 21 12:56:46 205.177.186.74 mtdblock
Mar 21 12:56:46 205.177.186.74 mtd_blkdevs
Mar 21 12:56:46 205.177.186.74 usbhid
Mar 21 12:56:46 205.177.186.74 uhci_hcd
Mar 21 12:56:46 205.177.186.74 ehci_hcd
Mar 21 12:56:46 205.177.186.74 ohci_hcd
Mar 21 12:56:46 205.177.186.74 usbcore
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259]
Mar 21 12:56:46 205.177.186.74 [   31.388259] Pid: 0, comm: swapper Not 
tainted (2.6.25-rc6-git2-build-0024 #8)
Mar 21 12:56:46 205.177.186.74 [   31.388259] EIP: 0060:[<c0285798>] EFLAGS: 
00010286 CPU: 0
Mar 21 12:56:46 205.177.186.74 [   31.388259] EIP is at ip_route_input
+0xa70/0xe56
Mar 21 12:56:46 205.177.186.74 [   31.388259] EAX: c0999200 EBX: 000000c2 
ECX: c038ea2c EDX: c013d182
Mar 21 12:56:46 205.177.186.74 [   31.388259] ESI: c099ff04 EDI: c099ff04 
EBP: c099ff30 ESP: c099fe94
Mar 21 12:56:46 205.177.186.74 [   31.388259]  DS: 007b ES: 007b FS: 00d8 GS: 
0000 SS: 0068
Mar 21 12:56:46 205.177.186.74 [   31.388259] Process swapper (pid: 0, 
ti=c099f000 task=c038e460 task.ti=c03b9000)
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259] Stack:
Mar 21 12:56:46 205.177.186.74 c099fec8
Mar 21 12:56:46 205.177.186.74 9a9b92c2
Mar 21 12:56:46 205.177.186.74 0514dc0a
Mar 21 12:56:46 205.177.186.74 f45abb40
Mar 21 12:56:46 205.177.186.74 c013bdc3
Mar 21 12:56:46 205.177.186.74 00000001
Mar 21 12:56:46 205.177.186.74 c038e460
Mar 21 12:56:46 205.177.186.74 00000001
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259]
Mar 21 12:56:46 205.177.186.74 ffffff8f
Mar 21 12:56:46 205.177.186.74 0099fec8
Mar 21 12:56:46 205.177.186.74 f7c3bd00
Mar 21 12:56:46 205.177.186.74 c0be25a0
Mar 21 12:56:46 205.177.186.74 0038e460
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000003
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259]
Mar 21 12:56:46 205.177.186.74 0514dc0a
Mar 21 12:56:46 205.177.186.74 9a9b92c2
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74 00000000
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259] Call Trace:
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c013bdc3>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 mark_held_locks+0x41/0x5c
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c013d182>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 lock_release+0x16b/0x172
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c02825e8>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 nf_hook_slow+0xa1/0xc1
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c02871a0>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 ip_rcv_finish+0x2c/0x2f4
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c028789b>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 ip_rcv+0x202/0x22c
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c026c809>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 netif_receive_skb+0x38d/0x3ec
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c026ee8b>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 process_backlog+0x6c/0xd3
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c026ee96>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 process_backlog+0x77/0xd3
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c026e977>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 net_rx_action+0xb3/0x1d8
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c0125846>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 __do_softirq+0x6f/0xe9
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c01060ab>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 do_softirq+0x5e/0xa8
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c0146413>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 handle_fasteoi_irq+0x0/0xb6
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c01257a4>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 irq_exit+0x44/0x77
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c01061af>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 do_IRQ+0xba/0xd3
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c010438e>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 common_interrupt+0x2e/0x34
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c01300d8>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 sys_clock_nanosleep+0x19/0xb0
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c01021ba>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 mwait_idle_with_hints+0x3a/0x3e
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c0102365>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 mwait_idle+0x0/0x14
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c0102377>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 mwait_idle+0x12/0x14
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c010266d>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 cpu_idle+0x8a/0xa6
Mar 21 12:56:46 205.177.186.74 [   31.388259]  [<c02b86c5>]
Mar 21 12:56:46 205.177.186.74 ?
Mar 21 12:56:46 205.177.186.74 rest_init+0x49/0x4b
Mar 21 12:56:46 205.177.186.74 [   31.388259]  =======================
Mar 21 12:56:46 205.177.186.74 [   31.388259] Code:
Mar 21 12:56:46 205.177.186.74 80
Mar 21 12:56:46 205.177.186.74 01
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 8b
Mar 21 12:56:46 205.177.186.74 55
Mar 21 12:56:46 205.177.186.74 8c
Mar 21 12:56:46 205.177.186.74 f0
Mar 21 12:56:46 205.177.186.74 ff
Mar 21 12:56:46 205.177.186.74 4a
Mar 21 12:56:46 205.177.186.74 04
Mar 21 12:56:46 205.177.186.74 0f
Mar 21 12:56:46 205.177.186.74 94
Mar 21 12:56:46 205.177.186.74 c0
Mar 21 12:56:46 205.177.186.74 84
Mar 21 12:56:46 205.177.186.74 c0
Mar 21 12:56:46 205.177.186.74 74
Mar 21 12:56:46 205.177.186.74 07
Mar 21 12:56:46 205.177.186.74 89
Mar 21 12:56:46 205.177.186.74 d0
Mar 21 12:56:46 205.177.186.74 e8
Mar 21 12:56:46 205.177.186.74 df
Mar 21 12:56:46 205.177.186.74 02
Mar 21 12:56:46 205.177.186.74 02
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 83
Mar 21 12:56:46 205.177.186.74 7d
Mar 21 12:56:46 205.177.186.74 80
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 0f
Mar 21 12:56:46 205.177.186.74 84
Mar 21 12:56:46 205.177.186.74 e2
Mar 21 12:56:46 205.177.186.74 03
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 8b
Mar 21 12:56:46 205.177.186.74 55
Mar 21 12:56:46 205.177.186.74 d8
Mar 21 12:56:46 205.177.186.74 85
Mar 21 12:56:46 205.177.186.74 d2
Mar 21 12:56:46 205.177.186.74 74
Mar 21 12:56:46 205.177.186.74 12
Mar 21 12:56:46 205.177.186.74 unparseable log message: "<f0> "
Mar 21 12:56:46 205.177.186.74 ff
Mar 21 12:56:46 205.177.186.74 4a
Mar 21 12:56:46 205.177.186.74 18
Mar 21 12:56:46 205.177.186.74 0f
Mar 21 12:56:46 205.177.186.74 94
Mar 21 12:56:46 205.177.186.74 c0
Mar 21 12:56:46 205.177.186.74 84
Mar 21 12:56:46 205.177.186.74 c0
Mar 21 12:56:46 205.177.186.74 74
Mar 21 12:56:46 205.177.186.74 07
Mar 21 12:56:46 205.177.186.74 89
Mar 21 12:56:46 205.177.186.74 d0
Mar 21 12:56:46 205.177.186.74 e8
Mar 21 12:56:46 205.177.186.74 cf
Mar 21 12:56:46 205.177.186.74 7c
Mar 21 12:56:46 205.177.186.74 02
Mar 21 12:56:46 205.177.186.74 00
Mar 21 12:56:46 205.177.186.74 8b
Mar 21 12:56:46 205.177.186.74 55
Mar 21 12:56:46 205.177.186.74 dc
Mar 21 12:56:46 205.177.186.74
Mar 21 12:56:46 205.177.186.74 [   31.388259] EIP: [<c0285798>]
Mar 21 12:56:46 205.177.186.74 ip_route_input+0xa70/0xe56
Mar 21 12:56:46 205.177.186.74 SS:ESP 0068:c099fe94
Mar 21 12:56:46 205.177.186.74 [   31.388259] Kernel panic - not syncing: 
Fatal exception in interrupt
Mar 21 12:56:46 205.177.186.74 [   31.388259] Rebooting in 1 seconds..


On Fri, 21 Mar 2008 03:35:30 -0700 (PDT), David Miller wrote
> From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> Date: Fri, 21 Mar 2008 11:33:04 +0200
> 
> > Hi, after trying to boot 2.6.25-rc6-git2 on loaded router, got kernel 
panic 
> > almost immediately (i am able to ssh, but router panic's in next 10-30 
> > seconds)
> > 
> > Here is netconsole output. It crashes also without netconsole (cause i 
heard 
> > patch not in stable yet, i tried to not use netconsole to avoid this bug).
> 
> The IP may point to ip_route_input(), but the entire top of the
> backtrace is in the lockdep code.  Which makes me quite suspicious.
> 
> > Mar 21 11:26:46 ROUTER [   12.125124] BUG: unable to handle kernel
> > Mar 21 11:26:46 ROUTER paging request
> > Mar 21 11:26:46 ROUTER at c013d19a
> > Mar 21 11:26:46 ROUTER [   12.125181] IP:
> > Mar 21 11:26:46 ROUTER [<c0285798>] ip_route_input+0xa70/0xe56
> > Mar 21 11:26:46 ROUTER [   12.125181] Oops: 0003 [#1]
> > Mar 21 11:26:46 ROUTER SMP
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181] Modules linked in:
> > Mar 21 11:26:46 ROUTER softdog
> > Mar 21 11:26:46 ROUTER nf_nat_pptp
> > Mar 21 11:26:46 ROUTER nf_nat_proto_gre
> > Mar 21 11:26:46 ROUTER nf_conntrack_pptp
> > Mar 21 11:26:46 ROUTER nf_conntrack_proto_gre
> > Mar 21 11:26:46 ROUTER netconsole
> > Mar 21 11:26:46 ROUTER configfs
> > Mar 21 11:26:46 ROUTER xt_tcpudp
> > Mar 21 11:26:46 ROUTER ipt_TTL
> > Mar 21 11:26:46 ROUTER ipt_ttl
> > Mar 21 11:26:46 ROUTER xt_NOTRACK
> > Mar 21 11:26:46 ROUTER iptable_raw
> > Mar 21 11:26:46 ROUTER iptable_mangle
> > Mar 21 11:26:46 ROUTER ifb
> > Mar 21 11:26:46 ROUTER e1000e
> > Mar 21 11:26:46 ROUTER em_nbyte
> > Mar 21 11:26:46 ROUTER cls_tcindex
> > Mar 21 11:26:46 ROUTER act_gact
> > Mar 21 11:26:46 ROUTER cls_rsvp
> > Mar 21 11:26:46 ROUTER sch_htb
> > Mar 21 11:26:46 ROUTER cls_fw
> > Mar 21 11:26:46 ROUTER act_mirred
> > Mar 21 11:26:46 ROUTER em_u32
> > Mar 21 11:26:46 ROUTER sch_red
> > Mar 21 11:26:46 ROUTER sch_sfq
> > Mar 21 11:26:46 ROUTER sch_tbf
> > Mar 21 11:26:46 ROUTER sch_teql
> > Mar 21 11:26:46 ROUTER cls_basic
> > Mar 21 11:26:46 ROUTER act_police
> > Mar 21 11:26:46 ROUTER sch_gred
> > Mar 21 11:26:46 ROUTER act_pedit
> > Mar 21 11:26:46 ROUTER sch_hfsc
> > Mar 21 11:26:46 ROUTER cls_rsvp6
> > Mar 21 11:26:46 ROUTER sch_ingress
> > Mar 21 11:26:46 ROUTER em_meta
> > Mar 21 11:26:46 ROUTER em_text
> > Mar 21 11:26:46 ROUTER act_ipt
> > Mar 21 11:26:46 ROUTER sch_dsmark
> > Mar 21 11:26:46 ROUTER sch_prio
> > Mar 21 11:26:46 ROUTER sch_netem
> > Mar 21 11:26:46 ROUTER act_simple
> > Mar 21 11:26:46 ROUTER cls_u32
> > Mar 21 11:26:46 ROUTER em_cmp
> > Mar 21 11:26:46 ROUTER sch_cbq
> > Mar 21 11:26:46 ROUTER cls_route
> > Mar 21 11:26:46 ROUTER xt_TCPMSS
> > Mar 21 11:26:46 ROUTER iptable_nat
> > Mar 21 11:26:46 ROUTER nf_conntrack_ipv4
> > Mar 21 11:26:46 ROUTER ipt_LOG
> > Mar 21 11:26:46 ROUTER ipt_MASQUERADE
> > Mar 21 11:26:46 ROUTER ipt_REDIRECT
> > Mar 21 11:26:46 ROUTER nf_nat
> > Mar 21 11:26:46 ROUTER nf_conntrack
> > Mar 21 11:26:46 ROUTER nfnetlink
> > Mar 21 11:26:46 ROUTER iptable_filter
> > Mar 21 11:26:46 ROUTER ip_tables
> > Mar 21 11:26:46 ROUTER x_tables
> > Mar 21 11:26:46 ROUTER 8021q
> > Mar 21 11:26:46 ROUTER tun
> > Mar 21 11:26:46 ROUTER tulip
> > Mar 21 11:26:46 ROUTER r8169
> > Mar 21 11:26:46 ROUTER sky2
> > Mar 21 11:26:46 ROUTER via_velocity
> > Mar 21 11:26:46 ROUTER via_rhine
> > Mar 21 11:26:46 ROUTER sis900
> > Mar 21 11:26:46 ROUTER ne2k_pci
> > Mar 21 11:26:46 ROUTER 8390
> > Mar 21 11:26:46 ROUTER skge
> > Mar 21 11:26:46 ROUTER tg3
> > Mar 21 11:26:46 ROUTER 8139too
> > Mar 21 11:26:46 ROUTER e1000
> > Mar 21 11:26:46 ROUTER e100
> > Mar 21 11:26:46 ROUTER usb_storage
> > Mar 21 11:26:46 ROUTER mtdblock
> > Mar 21 11:26:46 ROUTER mtd_blkdevs
> > Mar 21 11:26:46 ROUTER usbhid
> > Mar 21 11:26:46 ROUTER uhci_hcd
> > Mar 21 11:26:46 ROUTER ehci_hcd
> > Mar 21 11:26:46 ROUTER ohci_hcd
> > Mar 21 11:26:46 ROUTER usbcore
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181]
> > Mar 21 11:26:46 ROUTER [   12.125181] Pid: 0, comm: swapper Not tainted 
> > (2.6.25-rc6-git2-build-0024 #8)
> > Mar 21 11:26:46 ROUTER [   12.125181] EIP: 0060:[<c0285798>] EFLAGS: 
00010286 
> > CPU: 0
> > Mar 21 11:26:46 ROUTER [   12.125181] EIP is at ip_route_input+0xa70/0xe56
> > Mar 21 11:26:46 ROUTER [   12.125181] EAX: c0999200 EBX: 000000c2 ECX: 
> > c038ea2c EDX: c013d182
> > Mar 21 11:26:46 ROUTER [   12.125181] ESI: c099ff04 EDI: c099ff04 EBP: 
> > c099ff30 ESP: c099fe94
> > Mar 21 11:26:46 ROUTER [   12.125181]  DS: 007b ES: 007b FS: 00d8 GS: 
0000 
> > SS: 0068
> > Mar 21 11:26:46 ROUTER [   12.125181] Process swapper (pid: 0, 
ti=c099f000 
> > task=c038e460 task.ti=c03b9000)
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181] Stack:
> > Mar 21 11:26:46 ROUTER c099fec8
> > Mar 21 11:26:46 ROUTER be9a92c2
> > Mar 21 11:26:46 ROUTER de0aa8c0
> > Mar 21 11:26:46 ROUTER f6fc6cc0
> > Mar 21 11:26:46 ROUTER c013bdc3
> > Mar 21 11:26:46 ROUTER 00000001
> > Mar 21 11:26:46 ROUTER c038e460
> > Mar 21 11:26:46 ROUTER 00000001
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181]
> > Mar 21 11:26:46 ROUTER ffffff8f
> > Mar 21 11:26:46 ROUTER 0099fec8
> > Mar 21 11:26:46 ROUTER f7c3bc00
> > Mar 21 11:26:46 ROUTER c0be25a0
> > Mar 21 11:26:46 ROUTER 0038e460
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000003
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181]
> > Mar 21 11:26:46 ROUTER de0aa8c0
> > Mar 21 11:26:46 ROUTER be9a92c2
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER 00000000
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181] Call Trace:
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c013bdc3>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER mark_held_locks+0x41/0x5c
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c013d182>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER lock_release+0x16b/0x172
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c02825e8>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER nf_hook_slow+0xa1/0xc1
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c02871a0>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER ip_rcv_finish+0x2c/0x2f4
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c028789b>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER ip_rcv+0x202/0x22c
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c026c809>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER netif_receive_skb+0x38d/0x3ec
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c026ee8b>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER process_backlog+0x6c/0xd3
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c026ee96>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER process_backlog+0x77/0xd3
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c026e977>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER net_rx_action+0xb3/0x1d8
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c0125846>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER __do_softirq+0x6f/0xe9
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c01060ab>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER do_softirq+0x5e/0xa8
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c0146413>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER handle_fasteoi_irq+0x0/0xb6
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c01257a4>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER irq_exit+0x44/0x77
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c01061af>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER do_IRQ+0xba/0xd3
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c010438e>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER common_interrupt+0x2e/0x34
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c01300d8>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER sys_clock_nanosleep+0x19/0xb0
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c01021ba>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER mwait_idle_with_hints+0x3a/0x3e
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c0102365>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER mwait_idle+0x0/0x14
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c0102377>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER mwait_idle+0x12/0x14
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c010266d>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER cpu_idle+0x8a/0xa6
> > Mar 21 11:26:46 ROUTER [   12.125181]  [<c02b86c5>]
> > Mar 21 11:26:46 ROUTER ?
> > Mar 21 11:26:46 ROUTER rest_init+0x49/0x4b
> > Mar 21 11:26:46 ROUTER [   12.125181]  =======================
> > Mar 21 11:26:46 ROUTER [   12.125181] Code:
> > Mar 21 11:26:46 ROUTER 80
> > Mar 21 11:26:46 ROUTER 01
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 8b
> > Mar 21 11:26:46 ROUTER 55
> > Mar 21 11:26:46 ROUTER 8c
> > Mar 21 11:26:46 ROUTER f0
> > Mar 21 11:26:46 ROUTER ff
> > Mar 21 11:26:46 ROUTER 4a
> > Mar 21 11:26:46 ROUTER 04
> > Mar 21 11:26:46 ROUTER 0f
> > Mar 21 11:26:46 ROUTER 94
> > Mar 21 11:26:46 ROUTER c0
> > Mar 21 11:26:46 ROUTER 84
> > Mar 21 11:26:46 ROUTER c0
> > Mar 21 11:26:46 ROUTER 74
> > Mar 21 11:26:46 ROUTER 07
> > Mar 21 11:26:46 ROUTER 89
> > Mar 21 11:26:46 ROUTER d0
> > Mar 21 11:26:46 ROUTER e8
> > Mar 21 11:26:46 ROUTER df
> > Mar 21 11:26:46 ROUTER 02
> > Mar 21 11:26:46 ROUTER 02
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 83
> > Mar 21 11:26:46 ROUTER 7d
> > Mar 21 11:26:46 ROUTER 80
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 0f
> > Mar 21 11:26:46 ROUTER 84
> > Mar 21 11:26:46 ROUTER e2
> > Mar 21 11:26:46 ROUTER 03
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 8b
> > Mar 21 11:26:46 ROUTER 55
> > Mar 21 11:26:46 ROUTER d8
> > Mar 21 11:26:46 ROUTER 85
> > Mar 21 11:26:46 ROUTER d2
> > Mar 21 11:26:46 ROUTER 74
> > Mar 21 11:26:46 ROUTER 12
> > Mar 21 11:26:46 ROUTER unparseable log message: "<f0> "
> > Mar 21 11:26:46 ROUTER ff
> > Mar 21 11:26:46 ROUTER 4a
> > Mar 21 11:26:46 ROUTER 18
> > Mar 21 11:26:46 ROUTER 0f
> > Mar 21 11:26:46 ROUTER 94
> > Mar 21 11:26:46 ROUTER c0
> > Mar 21 11:26:46 ROUTER 84
> > Mar 21 11:26:46 ROUTER c0
> > Mar 21 11:26:46 ROUTER 74
> > Mar 21 11:26:46 ROUTER 07
> > Mar 21 11:26:46 ROUTER 89
> > Mar 21 11:26:46 ROUTER d0
> > Mar 21 11:26:46 ROUTER e8
> > Mar 21 11:26:46 ROUTER cf
> > Mar 21 11:26:46 ROUTER 7c
> > Mar 21 11:26:46 ROUTER 02
> > Mar 21 11:26:46 ROUTER 00
> > Mar 21 11:26:46 ROUTER 8b
> > Mar 21 11:26:46 ROUTER 55
> > Mar 21 11:26:46 ROUTER dc
> > Mar 21 11:26:46 ROUTER
> > Mar 21 11:26:46 ROUTER [   12.125181] EIP: [<c0285798>]
> > Mar 21 11:26:46 ROUTER ip_route_input+0xa70/0xe56
> > Mar 21 11:26:46 ROUTER SS:ESP 0068:c099fe94
> > Mar 21 11:26:46 ROUTER [   12.125181] Kernel panic - not syncing: Fatal 
> > exception in interrupt
> > Mar 21 11:26:46 ROUTER [   12.125181] Rebooting in 1 seconds..
> > 
> > 
> > 
> > --
> > Denys Fedoryshchenko
> > Technical Manager
> > Virtual ISP S.A.L.
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

