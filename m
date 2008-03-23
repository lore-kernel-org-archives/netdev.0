From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel panic, ip_route_input, 2.6.25-rc6-git2
Date: Sun, 23 Mar 2008 21:59:26 +0200
Message-ID: <20080323194556.M22324@visp.net.lb>
References: <20080323073638.M89709@visp.net.lb> <20080323.031139.17629653.davem@davemloft.net> <20080323171730.M39052@visp.net.lb> <20080323123021.1826ab73@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:53254 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227AbYCWT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 15:59:54 -0400
In-Reply-To: <20080323123021.1826ab73@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are both enabled.
There is nothing similar in kerneloops.

CONFIG_DEBUG_RODATA, 4K stacks, Frame pointers, CONFIG_DEBUG_STACKOVERFLOW - 
enabled.

It reboots recently after bringing up networking. Sometimes even not reaching 
place where i am loading netconsole.

Always in ip_route_input. This is 2.6.25-rc6-git6, 2 panic's. They are easy 
to reproduce, but i cannot do bisect, cause this machine dont have power 
switch and in difficult to reach area.

Mar 23 21:53:08 ROUTER [    6.986563] BUG: unable to handle kernel
Mar 23 21:53:08 ROUTER paging request
Mar 23 21:53:08 ROUTER at c0106010
Mar 23 21:53:08 ROUTER [    6.986660] IP:
Mar 23 21:53:08 ROUTER [<c027706a>] ip_route_input+0x872/0xbd9
Mar 23 21:53:08 ROUTER [    6.986726] Oops: 0003 [#1]
Mar 23 21:53:08 ROUTER SMP
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986814] Modules linked in:
Mar 23 21:53:08 ROUTER nf_conntrack_proto_gre
Mar 23 21:53:08 ROUTER nf_nat_proto_gre
Mar 23 21:53:08 ROUTER netconsole
Mar 23 21:53:08 ROUTER configfs
Mar 23 21:53:08 ROUTER hangcheck_timer
Mar 23 21:53:08 ROUTER xt_tcpudp
Mar 23 21:53:08 ROUTER ipt_TTL
Mar 23 21:53:08 ROUTER ipt_ttl
Mar 23 21:53:08 ROUTER xt_NOTRACK
Mar 23 21:53:08 ROUTER iptable_raw
Mar 23 21:53:08 ROUTER iptable_mangle
Mar 23 21:53:08 ROUTER ifb
Mar 23 21:53:08 ROUTER e1000e
Mar 23 21:53:08 ROUTER em_nbyte
Mar 23 21:53:08 ROUTER cls_tcindex
Mar 23 21:53:08 ROUTER act_gact
Mar 23 21:53:08 ROUTER cls_rsvp
Mar 23 21:53:08 ROUTER sch_htb
Mar 23 21:53:08 ROUTER cls_fw
Mar 23 21:53:08 ROUTER act_mirred
Mar 23 21:53:08 ROUTER em_u32
Mar 23 21:53:08 ROUTER sch_red
Mar 23 21:53:08 ROUTER sch_sfq
Mar 23 21:53:08 ROUTER sch_tbf
Mar 23 21:53:08 ROUTER sch_teql
Mar 23 21:53:08 ROUTER cls_basic
Mar 23 21:53:08 ROUTER act_police
Mar 23 21:53:08 ROUTER sch_gred
Mar 23 21:53:08 ROUTER act_pedit
Mar 23 21:53:08 ROUTER sch_hfsc
Mar 23 21:53:08 ROUTER cls_rsvp6
Mar 23 21:53:08 ROUTER sch_ingress
Mar 23 21:53:08 ROUTER em_meta
Mar 23 21:53:08 ROUTER em_text
Mar 23 21:53:08 ROUTER act_ipt
Mar 23 21:53:08 ROUTER sch_dsmark
Mar 23 21:53:08 ROUTER sch_prio
Mar 23 21:53:08 ROUTER sch_netem
Mar 23 21:53:08 ROUTER act_simple
Mar 23 21:53:08 ROUTER cls_u32
Mar 23 21:53:08 ROUTER em_cmp
Mar 23 21:53:08 ROUTER sch_cbq
Mar 23 21:53:08 ROUTER cls_route
Mar 23 21:53:08 ROUTER xt_TCPMSS
Mar 23 21:53:08 ROUTER iptable_nat
Mar 23 21:53:08 ROUTER nf_conntrack_ipv4
Mar 23 21:53:08 ROUTER ipt_LOG
Mar 23 21:53:08 ROUTER ipt_MASQUERADE
Mar 23 21:53:08 ROUTER ipt_REDIRECT
Mar 23 21:53:08 ROUTER nf_nat
Mar 23 21:53:08 ROUTER nf_conntrack
Mar 23 21:53:08 ROUTER nfnetlink
Mar 23 21:53:08 ROUTER iptable_filter
Mar 23 21:53:08 ROUTER ip_tables
Mar 23 21:53:08 ROUTER x_tables
Mar 23 21:53:08 ROUTER 8021q
Mar 23 21:53:08 ROUTER tun
Mar 23 21:53:08 ROUTER tulip
Mar 23 21:53:08 ROUTER r8169
Mar 23 21:53:08 ROUTER sky2
Mar 23 21:53:08 ROUTER via_velocity
Mar 23 21:53:08 ROUTER via_rhine
Mar 23 21:53:08 ROUTER sis900
Mar 23 21:53:08 ROUTER ne2k_pci
Mar 23 21:53:08 ROUTER 8390
Mar 23 21:53:08 ROUTER skge
Mar 23 21:53:08 ROUTER tg3
Mar 23 21:53:08 ROUTER 8139too
Mar 23 21:53:08 ROUTER e1000
Mar 23 21:53:08 ROUTER e100
Mar 23 21:53:08 ROUTER usb_storage
Mar 23 21:53:08 ROUTER mtdblock
Mar 23 21:53:08 ROUTER mtd_blkdevs
Mar 23 21:53:08 ROUTER usbhid
Mar 23 21:53:08 ROUTER uhci_hcd
Mar 23 21:53:08 ROUTER ehci_hcd
Mar 23 21:53:08 ROUTER ohci_hcd
Mar 23 21:53:08 ROUTER usbcore
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957]
Mar 23 21:53:08 ROUTER [    6.986957] Pid: 0, comm: swapper Not tainted 
(2.6.25-rc6-git6-build-0024 #2)
Mar 23 21:53:08 ROUTER [    6.986957] EIP: 0060:[<c027706a>] EFLAGS: 00010282 
CPU: 0
Mar 23 21:53:08 ROUTER [    6.986957] EIP is at ip_route_input+0x872/0xbd9
Mar 23 21:53:08 ROUTER [    6.986957] EAX: c0928100 EBX: 000000c2 ECX: 
c092ee78 EDX: c0105ff8
Mar 23 21:53:08 ROUTER [    6.986957] ESI: ffffff8f EDI: c092ef08 EBP: 
c092ef34 ESP: c092ee98
Mar 23 21:53:08 ROUTER [    6.986957]  DS: 007b ES: 007b FS: 00d8 GS: 0000 
SS: 0068
Mar 23 21:53:08 ROUTER [    6.986957] Process swapper (pid: 0, ti=c092e000 
task=c03763a0 task.ti=c039c000)
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957] Stack:
Mar 23 21:53:08 ROUTER c092eecc
Mar 23 21:53:08 ROUTER 459b92c2
Mar 23 21:53:08 ROUTER ff00a8c0
Mar 23 21:53:08 ROUTER f755b300
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER c092eed8
Mar 23 21:53:08 ROUTER f898e3bf
Mar 23 21:53:08 ROUTER f755b300
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957]
Mar 23 21:53:08 ROUTER 00000001
Mar 23 21:53:08 ROUTER 00000002
Mar 23 21:53:08 ROUTER f7c58800
Mar 23 21:53:08 ROUTER c096e800
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000003
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957]
Mar 23 21:53:08 ROUTER ff00a8c0
Mar 23 21:53:08 ROUTER 459b92c2
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER 00000000
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957] Call Trace:
Mar 23 21:53:08 ROUTER [    6.986957]  [<f898e3bf>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER nf_nat_fn+0x15b/0x16b [iptable_nat]
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0105ff8>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER do_IRQ+0xba/0xd2
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0278898>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER ip_rcv_finish+0x2c/0x29a
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0278ef8>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER ip_rcv+0x202/0x22c
Mar 23 21:53:08 ROUTER [    6.986957]  [<c025ee4e>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER netif_receive_skb+0x33e/0x3a9
Mar 23 21:53:08 ROUTER [    6.986957]  [<c02612c2>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER process_backlog+0x62/0xb5
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0260d27>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER net_rx_action+0x8f/0x191
Mar 23 21:53:08 ROUTER [    6.986957]  [<c01240a7>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER __do_softirq+0x64/0xcd
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0105f0a>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER do_softirq+0x55/0x89
Mar 23 21:53:08 ROUTER [    6.986957]  [<c013f49e>]
Mar 23 21:53:08 ROUTER handle_fasteoi_irq+0x0/0xaa
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0124010>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER irq_exit+0x38/0x6b
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0105ff8>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER do_IRQ+0xba/0xd2
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0104287>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER common_interrupt+0x23/0x28
Mar 23 21:53:08 ROUTER [    6.986957]  [<c01021ba>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER mwait_idle_with_hints+0x3a/0x3e
Mar 23 21:53:08 ROUTER [    6.986957]  [<c01021be>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER mwait_idle+0x0/0xf
Mar 23 21:53:08 ROUTER [    6.986957]  [<c01021cb>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER mwait_idle+0xd/0xf
Mar 23 21:53:08 ROUTER [    6.986957]  [<c0102668>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER cpu_idle+0x8a/0xa6
Mar 23 21:53:08 ROUTER [    6.986957]  [<c02a8b0d>]
Mar 23 21:53:08 ROUTER ?
Mar 23 21:53:08 ROUTER rest_init+0x49/0x4b
Mar 23 21:53:08 ROUTER [    6.986957]  =======================
Mar 23 21:53:08 ROUTER [    6.986957] Code:
Mar 23 21:53:08 ROUTER 84
Mar 23 21:53:08 ROUTER 01
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 8b
Mar 23 21:53:08 ROUTER 55
Mar 23 21:53:08 ROUTER 8c
Mar 23 21:53:08 ROUTER f0
Mar 23 21:53:08 ROUTER ff
Mar 23 21:53:08 ROUTER 4a
Mar 23 21:53:08 ROUTER 04
Mar 23 21:53:08 ROUTER 0f
Mar 23 21:53:08 ROUTER 94
Mar 23 21:53:08 ROUTER c0
Mar 23 21:53:08 ROUTER 84
Mar 23 21:53:08 ROUTER c0
Mar 23 21:53:08 ROUTER 74
Mar 23 21:53:08 ROUTER 07
Mar 23 21:53:08 ROUTER 89
Mar 23 21:53:08 ROUTER d0
Mar 23 21:53:08 ROUTER e8
Mar 23 21:53:08 ROUTER e9
Mar 23 21:53:08 ROUTER f8
Mar 23 21:53:08 ROUTER 01
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 83
Mar 23 21:53:08 ROUTER 7d
Mar 23 21:53:08 ROUTER 84
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 0f
Mar 23 21:53:08 ROUTER 84
Mar 23 21:53:08 ROUTER 64
Mar 23 21:53:08 ROUTER 03
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 8b
Mar 23 21:53:08 ROUTER 55
Mar 23 21:53:08 ROUTER d8
Mar 23 21:53:08 ROUTER 85
Mar 23 21:53:08 ROUTER d2
Mar 23 21:53:08 ROUTER 74
Mar 23 21:53:08 ROUTER 12
Mar 23 21:53:08 ROUTER unparseable log message: "<f0> "
Mar 23 21:53:08 ROUTER ff
Mar 23 21:53:08 ROUTER 4a
Mar 23 21:53:08 ROUTER 18
Mar 23 21:53:08 ROUTER 0f
Mar 23 21:53:08 ROUTER 94
Mar 23 21:53:08 ROUTER c0
Mar 23 21:53:08 ROUTER 84
Mar 23 21:53:08 ROUTER c0
Mar 23 21:53:08 ROUTER 74
Mar 23 21:53:08 ROUTER 07
Mar 23 21:53:08 ROUTER 89
Mar 23 21:53:08 ROUTER d0
Mar 23 21:53:08 ROUTER e8
Mar 23 21:53:08 ROUTER c9
Mar 23 21:53:08 ROUTER 6c
Mar 23 21:53:08 ROUTER 02
Mar 23 21:53:08 ROUTER 00
Mar 23 21:53:08 ROUTER 8b
Mar 23 21:53:08 ROUTER 55
Mar 23 21:53:08 ROUTER dc
Mar 23 21:53:08 ROUTER
Mar 23 21:53:08 ROUTER [    6.986957] EIP: [<c027706a>]
Mar 23 21:53:08 ROUTER ip_route_input+0x872/0xbd9
Mar 23 21:53:08 ROUTER SS:ESP 0068:c092ee98
Mar 23 21:53:08 ROUTER [    6.986957] Kernel panic - not syncing: Fatal 
exception in interrupt
Mar 23 21:53:08 ROUTER [    6.986957] Rebooting in 10 seconds..

One more 

Mar 23 21:56:26 ROUTER [   14.492999] BUG: unable to handle kernel
Mar 23 21:56:26 ROUTER paging request
Mar 23 21:56:26 ROUTER at 00112e2e
Mar 23 21:56:26 ROUTER [   14.493118] IP:
Mar 23 21:56:26 ROUTER [<c029d7d4>] fib_validate_source+0x20a/0x26e
Mar 23 21:56:26 ROUTER [   14.493203] Oops: 0002 [#1]
Mar 23 21:56:26 ROUTER SMP
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493308] Modules linked in:
Mar 23 21:56:26 ROUTER softdog
Mar 23 21:56:26 ROUTER nf_nat_pptp
Mar 23 21:56:26 ROUTER nf_conntrack_pptp
Mar 23 21:56:26 ROUTER nf_conntrack_proto_gre
Mar 23 21:56:26 ROUTER nf_nat_proto_gre
Mar 23 21:56:26 ROUTER netconsole
Mar 23 21:56:26 ROUTER configfs
Mar 23 21:56:26 ROUTER hangcheck_timer
Mar 23 21:56:26 ROUTER xt_tcpudp
Mar 23 21:56:26 ROUTER ipt_TTL
Mar 23 21:56:26 ROUTER ipt_ttl
Mar 23 21:56:26 ROUTER xt_NOTRACK
Mar 23 21:56:26 ROUTER iptable_raw
Mar 23 21:56:26 ROUTER iptable_mangle
Mar 23 21:56:26 ROUTER ifb
Mar 23 21:56:26 ROUTER e1000e
Mar 23 21:56:26 ROUTER em_nbyte
Mar 23 21:56:26 ROUTER cls_tcindex
Mar 23 21:56:26 ROUTER act_gact
Mar 23 21:56:26 ROUTER cls_rsvp
Mar 23 21:56:26 ROUTER sch_htb
Mar 23 21:56:26 ROUTER cls_fw
Mar 23 21:56:26 ROUTER act_mirred
Mar 23 21:56:26 ROUTER em_u32
Mar 23 21:56:26 ROUTER sch_red
Mar 23 21:56:26 ROUTER sch_sfq
Mar 23 21:56:26 ROUTER sch_tbf
Mar 23 21:56:26 ROUTER sch_teql
Mar 23 21:56:26 ROUTER cls_basic
Mar 23 21:56:26 ROUTER act_police
Mar 23 21:56:26 ROUTER sch_gred
Mar 23 21:56:26 ROUTER act_pedit
Mar 23 21:56:26 ROUTER sch_hfsc
Mar 23 21:56:26 ROUTER cls_rsvp6
Mar 23 21:56:26 ROUTER sch_ingress
Mar 23 21:56:26 ROUTER em_meta
Mar 23 21:56:26 ROUTER em_text
Mar 23 21:56:26 ROUTER act_ipt
Mar 23 21:56:26 ROUTER sch_dsmark
Mar 23 21:56:26 ROUTER sch_prio
Mar 23 21:56:26 ROUTER sch_netem
Mar 23 21:56:26 ROUTER act_simple
Mar 23 21:56:26 ROUTER cls_u32
Mar 23 21:56:26 ROUTER em_cmp
Mar 23 21:56:26 ROUTER sch_cbq
Mar 23 21:56:26 ROUTER cls_route
Mar 23 21:56:26 ROUTER xt_TCPMSS
Mar 23 21:56:26 ROUTER iptable_nat
Mar 23 21:56:26 ROUTER nf_conntrack_ipv4
Mar 23 21:56:26 ROUTER ipt_LOG
Mar 23 21:56:26 ROUTER ipt_MASQUERADE
Mar 23 21:56:26 ROUTER ipt_REDIRECT
Mar 23 21:56:26 ROUTER nf_nat
Mar 23 21:56:26 ROUTER nf_conntrack
Mar 23 21:56:26 ROUTER nfnetlink
Mar 23 21:56:26 ROUTER iptable_filter
Mar 23 21:56:26 ROUTER ip_tables
Mar 23 21:56:26 ROUTER x_tables
Mar 23 21:56:26 ROUTER 8021q
Mar 23 21:56:26 ROUTER tun
Mar 23 21:56:26 ROUTER tulip
Mar 23 21:56:26 ROUTER r8169
Mar 23 21:56:26 ROUTER sky2
Mar 23 21:56:26 ROUTER via_velocity
Mar 23 21:56:26 ROUTER via_rhine
Mar 23 21:56:26 ROUTER sis900
Mar 23 21:56:26 ROUTER ne2k_pci
Mar 23 21:56:26 ROUTER 8390
Mar 23 21:56:26 ROUTER skge
Mar 23 21:56:26 ROUTER tg3
Mar 23 21:56:26 ROUTER 8139too
Mar 23 21:56:26 ROUTER e1000
Mar 23 21:56:26 ROUTER e100
Mar 23 21:56:26 ROUTER usb_storage
Mar 23 21:56:26 ROUTER mtdblock
Mar 23 21:56:26 ROUTER mtd_blkdevs
Mar 23 21:56:26 ROUTER usbhid
Mar 23 21:56:26 ROUTER uhci_hcd
Mar 23 21:56:26 ROUTER ehci_hcd
Mar 23 21:56:26 ROUTER ohci_hcd
Mar 23 21:56:26 ROUTER usbcore
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821]
Mar 23 21:56:26 ROUTER [   14.493821] Pid: 0, comm: swapper Not tainted 
(2.6.25-rc6-git6-build-0024 #2)
Mar 23 21:56:26 ROUTER [   14.493821] EIP: 0060:[<c029d7d4>] EFLAGS: 00010202 
CPU: 1
Mar 23 21:56:26 ROUTER [   14.493821] EIP is at fib_validate_source+0x20a/
0x26e
Mar 23 21:56:26 ROUTER [   14.493821] EAX: 00000000 EBX: c092fe4c ECX: 
c092fde0 EDX: 00112e16
Mar 23 21:56:26 ROUTER [   14.493821] ESI: 00000000 EDI: c096e800 EBP: 
c092fe68 ESP: c092fe00
Mar 23 21:56:26 ROUTER [   14.493821]  DS: 007b ES: 007b FS: 00d8 GS: 0000 
SS: 0068
Mar 23 21:56:26 ROUTER [   14.493821] Process swapper (pid: 0, ti=c092f000 
task=f7c28b00 task.ti=f7c1f000)
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821] Stack:
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 6f00000a
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER f71a2680
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 6f00000a
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821]
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821]
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00000000
Mar 23 21:56:26 ROUTER 00112e16
Mar 23 21:56:26 ROUTER f7cad880
Mar 23 21:56:26 ROUTER f7ffbd00
Mar 23 21:56:26 ROUTER 0000000a
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821] Call Trace:
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0277103>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER ip_route_input+0x90b/0xbd9
Mar 23 21:56:26 ROUTER [   14.493821]  [<f898e3bf>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER nf_nat_fn+0x15b/0x16b [iptable_nat]
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0278898>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER ip_rcv_finish+0x2c/0x29a
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0278ef8>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER ip_rcv+0x202/0x22c
Mar 23 21:56:26 ROUTER [   14.493821]  [<c025ee4e>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER netif_receive_skb+0x33e/0x3a9
Mar 23 21:56:26 ROUTER [   14.493821]  [<f88d3a3e>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER e100_poll+0x17e/0x2de [e100]
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01316a3>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER run_hrtimer_pending+0xd/0x84
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0260d27>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER net_rx_action+0x8f/0x191
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01240a7>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER __do_softirq+0x64/0xcd
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0105f0a>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER do_softirq+0x55/0x89
Mar 23 21:56:26 ROUTER [   14.493821]  [<c013f49e>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER handle_fasteoi_irq+0x0/0xaa
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0124010>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER irq_exit+0x38/0x6b
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0105ff8>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER do_IRQ+0xba/0xd2
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0104287>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER common_interrupt+0x23/0x28
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01300d8>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER posix_cpu_timer_set+0x11d/0x35c
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01021ba>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER mwait_idle_with_hints+0x3a/0x3e
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01021be>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER mwait_idle+0x0/0xf
Mar 23 21:56:26 ROUTER [   14.493821]  [<c01021cb>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER mwait_idle+0xd/0xf
Mar 23 21:56:26 ROUTER [   14.493821]  [<c0102668>]
Mar 23 21:56:26 ROUTER ?
Mar 23 21:56:26 ROUTER cpu_idle+0x8a/0xa6
Mar 23 21:56:26 ROUTER [   14.493821]  =======================
Mar 23 21:56:26 ROUTER [   14.493821] Code:
Mar 23 21:56:26 ROUTER e9
Mar 23 21:56:26 ROUTER 80
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 85
Mar 23 21:56:26 ROUTER f6
Mar 23 21:56:26 ROUTER 75
Mar 23 21:56:26 ROUTER 53
Mar 23 21:56:26 ROUTER 8b
Mar 23 21:56:26 ROUTER 45
Mar 23 21:56:26 ROUTER 0c
Mar 23 21:56:26 ROUTER 31
Mar 23 21:56:26 ROUTER c9
Mar 23 21:56:26 ROUTER 31
Mar 23 21:56:26 ROUTER d2
Mar 23 21:56:26 ROUTER e8
Mar 23 21:56:26 ROUTER d4
Mar 23 21:56:26 ROUTER 9f
Mar 23 21:56:26 ROUTER ff
Mar 23 21:56:26 ROUTER ff
Mar 23 21:56:26 ROUTER 8b
Mar 23 21:56:26 ROUTER 4d
Mar 23 21:56:26 ROUTER 10
Mar 23 21:56:26 ROUTER 89
Mar 23 21:56:26 ROUTER 01
Mar 23 21:56:26 ROUTER 8b
Mar 23 21:56:26 ROUTER 5d
Mar 23 21:56:26 ROUTER 14
Mar 23 21:56:26 ROUTER c7
Mar 23 21:56:26 ROUTER 03
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 31
Mar 23 21:56:26 ROUTER db
Mar 23 21:56:26 ROUTER eb
Mar 23 21:56:26 ROUTER 5e
Mar 23 21:56:26 ROUTER 85
Mar 23 21:56:26 ROUTER d2
Mar 23 21:56:26 ROUTER 74
Mar 23 21:56:26 ROUTER 12
Mar 23 21:56:26 ROUTER unparseable log message: "<f0> "
Mar 23 21:56:26 ROUTER ff
Mar 23 21:56:26 ROUTER 4a
Mar 23 21:56:26 ROUTER 18
Mar 23 21:56:26 ROUTER 0f
Mar 23 21:56:26 ROUTER 94
Mar 23 21:56:26 ROUTER c0
Mar 23 21:56:26 ROUTER 84
Mar 23 21:56:26 ROUTER c0
Mar 23 21:56:26 ROUTER 74
Mar 23 21:56:26 ROUTER 07
Mar 23 21:56:26 ROUTER 89
Mar 23 21:56:26 ROUTER d0
Mar 23 21:56:26 ROUTER e8
Mar 23 21:56:26 ROUTER 5f
Mar 23 21:56:26 ROUTER 05
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 00
Mar 23 21:56:26 ROUTER 8b
Mar 23 21:56:26 ROUTER 55
Mar 23 21:56:26 ROUTER ec
Mar 23 21:56:26 ROUTER
Mar 23 21:56:26 ROUTER [   14.493821] EIP: [<c029d7d4>]
Mar 23 21:56:26 ROUTER fib_validate_source+0x20a/0x26e
Mar 23 21:56:26 ROUTER SS:ESP 0068:c092fe00
Mar 23 21:56:26 ROUTER [   14.493822] Kernel panic - not syncing: Fatal 
exception in interrupt








On Sun, 23 Mar 2008 12:30:21 -0700, Arjan van de Ven wrote
> On Sun, 23 Mar 2008 19:17:55 +0200
> "Denys Fedoryshchenko" <denys@visp.net.lb> wrote:
> 
> > What can i do to increase usability?
> >
> 
> Enabling CONFIG_FRAME_POINTER tends to make backtraces more reliable.
> Making sure that (on 32 bit x86) you use CONFIG_4KSTACKS is enabled 
> also tends to improve backtrace reliability (less noise from 
> interrupts)
> 
> Another good option is to go to www.kerneloops.org and try to see if 
> others saw similar backtraces but with less noise
> 
> -- 
> If you want to reach me at my work email, use arjan@linux.intel.com
> For development, discussion and tips for power savings, 
> visit http://www.lesswatts.org
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

