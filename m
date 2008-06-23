From: "Clem Taylor" <clem.taylor@gmail.com>
Subject: 2.6.25: WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
Date: Mon, 23 Jun 2008 18:53:44 -0400
Message-ID: <ecb4efd10806231553w8758655xcf861e5e191809ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:24515 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbYFWWxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 18:53:46 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2506708fkq.5
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 15:53:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My kernel is tainted with both the vmware and nvidia drivers, but I
thought someone might still care about this.

The system is 2.6.25 x86_64 SMP (with preeempt and tickless).

[841839.294985] ------------[ cut here ]------------
[841839.294985] WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
[841839.294985] Modules linked in: nls_iso8859_1 vfat fat vmnet(P)
vmmon(P) nvidia(P)
[841839.294985] Pid: 0, comm: swapper Tainted: P         2.6.25 #2
[841839.294985] Call Trace:
[841839.294985]  <IRQ>  [<ffffffff80235c2f>] warn_on_slowpath+0x5f/0x90
[841839.294985]  [<ffffffff80541024>] ? ip_local_out+0x64/0x70
[841839.294985]  [<ffffffff80240cc6>] ? lock_timer_base+0x36/0x70
[841839.294985]  [<ffffffff80240fbe>] ? __mod_timer+0xbe/0xe0
[841839.294985]  [<ffffffff802410ab>] ? mod_timer+0x4b/0x60
[841839.294985]  [<ffffffff80550c17>] tcp_ack+0xdd7/0x22f0
[841839.294985]  [<ffffffff80555546>] tcp_rcv_established+0x2e6/0xc50
[841839.294985]  [<ffffffff8055cedd>] tcp_v4_do_rcv+0xdd/0x210
[841839.294985]  [<ffffffff8055d6fb>] tcp_v4_rcv+0x6eb/0x740
[841839.294985]  [<ffffffff8051d2ba>] ? __kfree_skb+0x3a/0xa0
[841839.294985]  [<ffffffff8053e425>] ip_local_deliver+0xa5/0x180
[841839.294985]  [<ffffffff8053e102>] ip_rcv+0x372/0x5f0
[841839.294985]  [<ffffffff88987540>] ?
:vmnet:VNetBridgeReceiveFromDev+0x1b0/0x240
[841839.294985]  [<ffffffff80412214>] ? e1000_alloc_rx_buffers+0xc4/0x390
[841839.294985]  [<ffffffff80523946>] netif_receive_skb+0x236/0x2c0
[841839.294985]  [<ffffffff80523a48>] process_backlog+0x78/0x100
[841839.294985]  [<ffffffff80522069>] net_rx_action+0x99/0x170
[841839.294985]  [<ffffffff8023c22a>] __do_softirq+0x8a/0x100
[841839.294985]  [<ffffffff8020c89c>] call_softirq+0x1c/0x30
[841839.294985]  [<ffffffff8020e835>] do_softirq+0x45/0x80
[841839.294985]  [<ffffffff8023bfb5>] irq_exit+0xa5/0xb0
[841839.294985]  [<ffffffff8020e926>] do_IRQ+0x86/0x100
[841839.294985]  [<ffffffff80209390>] ? mwait_idle+0x0/0x50
[841839.294985]  [<ffffffff8020a660>] ? default_idle+0x0/0x70
[841839.294985]  [<ffffffff8020bbf1>] ret_from_intr+0x0/0xa
[841839.294985]  <EOI>  [<ffffffff802093d0>] ? mwait_idle+0x40/0x50
[841839.294985]  [<ffffffff8020a582>] ? enter_idle+0x22/0x30
[841839.294985]  [<ffffffff8020a5f8>] ? cpu_idle+0x68/0xd0
[841839.294985]  [<ffffffff805988bf>] ? rest_init+0x7f/0x90
[841839.294985] ---[ end trace 5d7725fb0a0a8833 ]---

Happened again, ~17 hours later:

[906188.085803] ------------[ cut here ]------------
[906188.085803] WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
[906188.085803] Modules linked in: nls_iso8859_1 vfat fat vmnet(P)
vmmon(P) nvidia(P)
[906188.085803] Pid: 0, comm: swapper Tainted: P         2.6.25 #2
[906188.085803] Call Trace:
[906188.085803]  <IRQ>  [<ffffffff80235c2f>] warn_on_slowpath+0x5f/0x90
[906188.085803]  [<ffffffff8028b9e1>] ? add_partial+0x51/0x80
[906188.085803]  [<ffffffff80550c17>] tcp_ack+0xdd7/0x22f0
[906188.085803]  [<ffffffff8055586b>] tcp_rcv_established+0x60b/0xc50
[906188.085803]  [<ffffffff8055cedd>] tcp_v4_do_rcv+0xdd/0x210
[906188.085803]  [<ffffffff8055d6fb>] tcp_v4_rcv+0x6eb/0x740
[906188.085803]  [<ffffffff8051d2ba>] ? __kfree_skb+0x3a/0xa0
[906188.085803]  [<ffffffff8053e425>] ip_local_deliver+0xa5/0x180
[906188.085803]  [<ffffffff8053e102>] ip_rcv+0x372/0x5f0
[906188.085803]  [<ffffffff88987540>] ?
:vmnet:VNetBridgeReceiveFromDev+0x1b0/0x240
[906188.085803]  [<ffffffff80412214>] ? e1000_alloc_rx_buffers+0xc4/0x390
[906188.085803]  [<ffffffff80523946>] netif_receive_skb+0x236/0x2c0
[906188.085803]  [<ffffffff80523a48>] process_backlog+0x78/0x100
[906188.085803]  [<ffffffff80522069>] net_rx_action+0x99/0x170
[906188.085803]  [<ffffffff8023c22a>] __do_softirq+0x8a/0x100
[906188.085803]  [<ffffffff8020c89c>] call_softirq+0x1c/0x30
[906188.085803]  [<ffffffff8020e835>] do_softirq+0x45/0x80
[906188.085803]  [<ffffffff8023bfb5>] irq_exit+0xa5/0xb0
[906188.085803]  [<ffffffff8020e926>] do_IRQ+0x86/0x100
[906188.085803]  [<ffffffff80209390>] ? mwait_idle+0x0/0x50
[906188.085803]  [<ffffffff8020a660>] ? default_idle+0x0/0x70
[906188.085803]  [<ffffffff8020bbf1>] ret_from_intr+0x0/0xa
[906188.085803]  <EOI>  [<ffffffff802093d0>] ? mwait_idle+0x40/0x50
[906188.085803]  [<ffffffff8020a582>] ? enter_idle+0x22/0x30
[906188.085803]  [<ffffffff8020a5f8>] ? cpu_idle+0x68/0xd0
[906188.085803]  [<ffffffff805988bf>] ? rest_init+0x7f/0x90
[906188.085803] ---[ end trace 5d7725fb0a0a8833 ]---
