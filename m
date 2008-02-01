From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: kernel panic on 2.6.24 with esfq patch applied
Date: Fri, 1 Feb 2008 15:25:47 +0200
Message-ID: <20080201131509.M52958@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37304 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763340AbYBAN0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:26:11 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 6ECAFBD3D5
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2008 15:25:47 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Probably bug related to ESFQ, now i will unload module and will test more. 
But probably not related, so if not difficult, please take a look.

Feb  1 09:08:50 SERVER [12380.067104] BUG: unable to handle kernel NULL 
pointer dereference
Feb  1 09:08:50 SERVER at virtual address 00000008
Feb  1 09:08:50 SERVER [12380.067140] printing eip: c01f10ed
Feb  1 09:08:50 SERVER *pde = 00000000
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067162] Oops: 0000 [#1]
Feb  1 09:08:50 SERVER SMP
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067181] Modules linked in:
Feb  1 09:08:50 SERVER netconsole
Feb  1 09:08:50 SERVER configfs
Feb  1 09:08:50 SERVER iTCO_wdt
Feb  1 09:08:50 SERVER nf_nat_pptp
Feb  1 09:08:50 SERVER nf_conntrack_pptp
Feb  1 09:08:50 SERVER nf_conntrack_proto_gre
Feb  1 09:08:50 SERVER nf_nat_proto_gre
Feb  1 09:08:50 SERVER sch_esfq
Feb  1 09:08:50 SERVER xt_tcpudp
Feb  1 09:08:50 SERVER ipt_TTL
Feb  1 09:08:50 SERVER ipt_ttl
Feb  1 09:08:50 SERVER xt_NOTRACK
Feb  1 09:08:50 SERVER iptable_raw
Feb  1 09:08:50 SERVER iptable_mangle
Feb  1 09:08:50 SERVER ifb
Feb  1 09:08:50 SERVER e1000e
Feb  1 09:08:50 SERVER em_nbyte
Feb  1 09:08:50 SERVER cls_tcindex
Feb  1 09:08:50 SERVER act_gact
Feb  1 09:08:50 SERVER cls_rsvp
Feb  1 09:08:50 SERVER sch_htb
Feb  1 09:08:50 SERVER cls_fw
Feb  1 09:08:50 SERVER act_mirred
Feb  1 09:08:50 SERVER em_u32
Feb  1 09:08:50 SERVER sch_red
Feb  1 09:08:50 SERVER sch_sfq
Feb  1 09:08:50 SERVER sch_tbf
Feb  1 09:08:50 SERVER sch_teql
Feb  1 09:08:50 SERVER cls_basic
Feb  1 09:08:50 SERVER act_police
Feb  1 09:08:50 SERVER sch_gred
Feb  1 09:08:50 SERVER act_pedit
Feb  1 09:08:50 SERVER sch_hfsc
Feb  1 09:08:50 SERVER cls_rsvp6
Feb  1 09:08:50 SERVER sch_ingress
Feb  1 09:08:50 SERVER em_meta
Feb  1 09:08:50 SERVER em_text
Feb  1 09:08:50 SERVER act_ipt
Feb  1 09:08:50 SERVER sch_dsmark
Feb  1 09:08:50 SERVER sch_prio
Feb  1 09:08:50 SERVER sch_netem
Feb  1 09:08:50 SERVER act_simple
Feb  1 09:08:50 SERVER cls_u32
Feb  1 09:08:50 SERVER em_cmp
Feb  1 09:08:50 SERVER sch_cbq
Feb  1 09:08:50 SERVER cls_route
Feb  1 09:08:50 SERVER xt_TCPMSS
Feb  1 09:08:50 SERVER iptable_nat
Feb  1 09:08:50 SERVER nf_conntrack_ipv4
Feb  1 09:08:50 SERVER ipt_LOG
Feb  1 09:08:50 SERVER ipt_MASQUERADE
Feb  1 09:08:50 SERVER ipt_REDIRECT
Feb  1 09:08:50 SERVER nf_nat
Feb  1 09:08:50 SERVER nf_conntrack
Feb  1 09:08:50 SERVER nfnetlink
Feb  1 09:08:50 SERVER iptable_filter
Feb  1 09:08:50 SERVER ip_tables
Feb  1 09:08:50 SERVER x_tables
Feb  1 09:08:50 SERVER 8021q
Feb  1 09:08:50 SERVER tun
Feb  1 09:08:50 SERVER tulip
Feb  1 09:08:50 SERVER r8169
Feb  1 09:08:50 SERVER sky2
Feb  1 09:08:50 SERVER via_velocity
Feb  1 09:08:50 SERVER via_rhine
Feb  1 09:08:50 SERVER sis900
Feb  1 09:08:50 SERVER ne2k_pci
Feb  1 09:08:50 SERVER 8390
Feb  1 09:08:50 SERVER skge
Feb  1 09:08:50 SERVER tg3
Feb  1 09:08:50 SERVER 8139too
Feb  1 09:08:50 SERVER e1000
Feb  1 09:08:50 SERVER e100
Feb  1 09:08:50 SERVER usb_storage
Feb  1 09:08:50 SERVER mtdblock
Feb  1 09:08:50 SERVER mtd_blkdevs
Feb  1 09:08:50 SERVER usbhid
Feb  1 09:08:50 SERVER uhci_hcd
Feb  1 09:08:50 SERVER ehci_hcd
Feb  1 09:08:50 SERVER ohci_hcd
Feb  1 09:08:50 SERVER usbcore
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067515]
Feb  1 09:08:50 SERVER [12380.067530] Pid: 0, comm: swapper Not tainted 
(2.6.24-build-0021 #26)
Feb  1 09:08:50 SERVER [12380.067550] EIP: 0060:[<c01f10ed>] EFLAGS: 00010086 
CPU: 0
Feb  1 09:08:50 SERVER [12380.067571] EIP is at rb_erase+0x110/0x22f
Feb  1 09:08:50 SERVER [12380.067589] EAX: f52bbea0 EBX: 00000000 ECX: 
00000000 EDX: f52bbea0
Feb  1 09:08:50 SERVER [12380.067608] ESI: f717df50 EDI: c1fed000 EBP: 
c1fecf80 ESP: c037fda8
Feb  1 09:08:50 SERVER [12380.067628]  DS: 007b ES: 007b FS: 00d8 GS: 0000 
SS: 0068
Feb  1 09:08:50 SERVER [12380.067647] Process swapper (pid: 0, ti=c037e000 
task=c03533a0 task.ti=c037e000)
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067668] Stack:
Feb  1 09:08:50 SERVER 00000001
Feb  1 09:08:50 SERVER c1fed000
Feb  1 09:08:50 SERVER c1fecf78
Feb  1 09:08:50 SERVER 00000002
Feb  1 09:08:50 SERVER 00000001
Feb  1 09:08:50 SERVER c0134663
Feb  1 09:08:50 SERVER c1fed000
Feb  1 09:08:50 SERVER c1fecf78
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067714]
Feb  1 09:08:50 SERVER c1fecf40
Feb  1 09:08:50 SERVER c013515b
Feb  1 09:08:50 SERVER 00000000
Feb  1 09:08:50 SERVER 4f3f473e
Feb  1 09:08:50 SERVER 000002d0
Feb  1 09:08:50 SERVER ffffffff
Feb  1 09:08:50 SERVER 7fffffff
Feb  1 09:08:50 SERVER 4f3f473e
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067760]
Feb  1 09:08:50 SERVER 000002d0
Feb  1 09:08:50 SERVER 00000000
Feb  1 09:08:50 SERVER c1fec120
Feb  1 09:08:50 SERVER c037ff84
Feb  1 09:08:50 SERVER c037fe70
Feb  1 09:08:50 SERVER f76ae880
Feb  1 09:08:50 SERVER c0113963
Feb  1 09:08:50 SERVER c1ff5f78
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.067806] Call Trace:
Feb  1 09:08:50 SERVER [12380.067839]  [<c0134663>]
Feb  1 09:08:50 SERVER __remove_hrtimer+0x5d/0x64
Feb  1 09:08:50 SERVER [12380.067861]  [<c013515b>]
Feb  1 09:08:50 SERVER hrtimer_interrupt+0x10c/0x19a
Feb  1 09:08:50 SERVER [12380.067883]  [<c0113963>]
Feb  1 09:08:50 SERVER smp_apic_timer_interrupt+0x6f/0x80
Feb  1 09:08:50 SERVER [12380.067905]  [<c0105838>]
Feb  1 09:08:50 SERVER apic_timer_interrupt+0x28/0x30
Feb  1 09:08:50 SERVER [12380.067928]  [<c02be6d7>]
Feb  1 09:08:50 SERVER _spin_lock_irqsave+0x13/0x27
Feb  1 09:08:50 SERVER [12380.067949]  [<c0134bc7>]
Feb  1 09:08:50 SERVER lock_hrtimer_base+0x15/0x2f
Feb  1 09:08:50 SERVER [12380.067970]  [<c0134ca0>]
Feb  1 09:08:50 SERVER hrtimer_start+0x16/0xf4
Feb  1 09:08:50 SERVER [12380.067991]  [<c027ec43>]
Feb  1 09:08:50 SERVER qdisc_watchdog_schedule+0x1e/0x21
Feb  1 09:08:50 SERVER [12380.068013]  [<f89f8fe6>]
Feb  1 09:08:50 SERVER htb_dequeue+0x6ef/0x6fb [sch_htb]
Feb  1 09:08:50 SERVER [12380.068036]  [<c028ac4d>]
Feb  1 09:08:50 SERVER ip_rcv+0x1fc/0x237
Feb  1 09:08:50 SERVER [12380.068057]  [<c0135297>]
Feb  1 09:08:50 SERVER hrtimer_get_next_event+0xae/0xbb
Feb  1 09:08:50 SERVER [12380.068078]  [<c0135297>]
Feb  1 09:08:50 SERVER hrtimer_get_next_event+0xae/0xbb
Feb  1 09:08:50 SERVER [12380.068099]  [<c0136e26>]
Feb  1 09:08:50 SERVER getnstimeofday+0x2b/0xb5
Feb  1 09:08:50 SERVER [12380.068118]  [<c0138d70>]
Feb  1 09:08:50 SERVER clockevents_program_event+0xe0/0xee
Feb  1 09:08:50 SERVER [12380.068140]  [<c027da0e>]
Feb  1 09:08:50 SERVER __qdisc_run+0x2a/0x163
Feb  1 09:08:50 SERVER [12380.068161]  [<c02722d8>]
Feb  1 09:08:50 SERVER net_tx_action+0xa8/0xcc
Feb  1 09:08:50 SERVER [12380.068180]  [<c027ec65>]
Feb  1 09:08:50 SERVER qdisc_watchdog+0x0/0x1b
Feb  1 09:08:50 SERVER [12380.068199]  [<c027ec7d>]
Feb  1 09:08:50 SERVER qdisc_watchdog+0x18/0x1b
Feb  1 09:08:50 SERVER [12380.068218]  [<c0135007>]
Feb  1 09:08:50 SERVER run_hrtimer_softirq+0x4e/0x96
Feb  1 09:08:50 SERVER [12380.068241]  [<c0126a82>]
Feb  1 09:08:50 SERVER __do_softirq+0x5d/0xc1
Feb  1 09:08:50 SERVER [12380.068260]  [<c0126b18>]
Feb  1 09:08:50 SERVER do_softirq+0x32/0x36
Feb  1 09:08:50 SERVER [12380.068279]  [<c0126d6a>]
Feb  1 09:08:50 SERVER irq_exit+0x38/0x6b
Feb  1 09:08:50 SERVER [12380.068298]  [<c0113968>]
Feb  1 09:08:50 SERVER smp_apic_timer_interrupt+0x74/0x80
Feb  1 09:08:50 SERVER [12380.068319]  [<c0105838>]
Feb  1 09:08:50 SERVER apic_timer_interrupt+0x28/0x30
Feb  1 09:08:50 SERVER [12380.068343]  [<c0103243>]
Feb  1 09:08:50 SERVER mwait_idle_with_hints+0x3c/0x40
Feb  1 09:08:50 SERVER [12380.068365]  [<c0103247>]
Feb  1 09:08:50 SERVER mwait_idle+0x0/0xa
Feb  1 09:08:50 SERVER [12380.068384]  [<c010357e>]
Feb  1 09:08:50 SERVER cpu_idle+0x98/0xb9
Feb  1 09:08:50 SERVER [12380.068403]  [<c03848c2>]
Feb  1 09:08:50 SERVER start_kernel+0x2d7/0x2df
Feb  1 09:08:50 SERVER [12380.068422]  [<c03840e0>]
Feb  1 09:08:50 SERVER unknown_bootoption+0x0/0x195
Feb  1 09:08:50 SERVER [12380.068444]  =======================
Feb  1 09:08:50 SERVER [12380.068460] Code:
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER 00
Feb  1 09:08:50 SERVER 00
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 4e
Feb  1 09:08:50 SERVER 08
Feb  1 09:08:50 SERVER 39
Feb  1 09:08:50 SERVER d9
Feb  1 09:08:50 SERVER 0f
Feb  1 09:08:50 SERVER 85
Feb  1 09:08:50 SERVER 85
Feb  1 09:08:50 SERVER 00
Feb  1 09:08:50 SERVER 00
Feb  1 09:08:50 SERVER 00
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 4e
Feb  1 09:08:50 SERVER 04
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER a8
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER 75
Feb  1 09:08:50 SERVER 14
Feb  1 09:08:50 SERVER 83
Feb  1 09:08:50 SERVER c8
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER 89
Feb  1 09:08:50 SERVER ea
Feb  1 09:08:50 SERVER 89
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER 89
Feb  1 09:08:50 SERVER f0
Feb  1 09:08:50 SERVER 83
Feb  1 09:08:50 SERVER 26
Feb  1 09:08:50 SERVER fe
Feb  1 09:08:50 SERVER e8
Feb  1 09:08:50 SERVER 1e
Feb  1 09:08:50 SERVER fd
Feb  1 09:08:50 SERVER ff
Feb  1 09:08:50 SERVER ff
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 4e
Feb  1 09:08:50 SERVER 04
Feb  1 07:08:49 SERVER unparseable log message: "<8b> "
Feb  1 09:08:50 SERVER 59
Feb  1 09:08:50 SERVER 08
Feb  1 09:08:50 SERVER 85
Feb  1 09:08:50 SERVER db
Feb  1 09:08:50 SERVER 74
Feb  1 09:08:50 SERVER 06
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 03
Feb  1 09:08:50 SERVER a8
Feb  1 09:08:50 SERVER 01
Feb  1 09:08:50 SERVER 74
Feb  1 09:08:50 SERVER 15
Feb  1 09:08:50 SERVER 8b
Feb  1 09:08:50 SERVER 41
Feb  1 09:08:50 SERVER 04
Feb  1 09:08:50 SERVER 85
Feb  1 09:08:50 SERVER c0
Feb  1 09:08:50 SERVER 0f
Feb  1 09:08:50 SERVER 84
Feb  1 09:08:50 SERVER c6
Feb  1 09:08:50 SERVER
Feb  1 09:08:50 SERVER [12380.068753] EIP: [<c01f10ed>]
Feb  1 09:08:50 SERVER rb_erase+0x110/0x22f
Feb  1 09:08:50 SERVER SS:ESP 0068:c037fda8
Feb  1 09:08:50 SERVER [12380.068978] Kernel panic - not syncing: Fatal 
exception in interrupt


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

