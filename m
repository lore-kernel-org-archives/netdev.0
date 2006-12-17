From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: Deadlock in MD5 Signature support
Date: Sun, 17 Dec 2006 18:13:06 -0000 (GMT)
Message-ID: <53701.81.105.127.245.1166379186.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:2626 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283AbWLQSNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 13:13:08 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was all going so well, and then it deadlocked.  What can be done
about this?

SysRq : Show Regs

Pid: 2330, comm:              torture
EIP: 0060:[<c02a6240>] CPU: 0
EIP is at _spin_lock+0x5/0xf
 EFLAGS: 00000282    Not tainted  (2.6.19.1 #2)
EAX: c03187e4 EBX: 00000000 ECX: fa01a8c0 EDX: c52f81e0
ESI: df983240 EDI: c51f6800 EBP: dfc44a20 DS: 007b ES: 007b
CR0: 8005003b CR2: 08124008 CR3: 1ff72a80 CR4: 000006f0
 [<c026e4e4>] __tcp_get_md5sig_pool+0xd/0x3f
 [<c027a563>] tcp_v4_do_calc_md5_hash+0x20/0x1a7
 [<c011a142>] __activate_task+0x1c/0x29
 [<c011a946>] try_to_wake_up+0x27a/0x285
 [<c027a830>] tcp_v4_inbound_md5_hash+0xe1/0x1b2
 [<c027b2dc>] tcp_v4_do_rcv+0xd/0xd3
 [<c027b8ba>] tcp_v4_rcv+0x518/0x81b
 [<c026212e>] ip_local_deliver+0x17d/0x235
 [<c0262619>] ip_rcv+0x433/0x475
 [<c01c7988>] __next_cpu+0x12/0x1f
 [<c011b3a7>] find_busiest_group+0x184/0x475
 [<c024511b>] netif_receive_skb+0x303/0x322
 [<f8872be6>] tg3_rx+0x278/0x385 [tg3]
 [<f8872dbe>] tg3_poll+0xcb/0x17c [tg3]
 [<c02452ca>] net_rx_action+0x98/0x198
 [<c0125a7a>] __do_softirq+0x5e/0xbd
 [<c0125b07>] do_softirq+0x2e/0x32
 [<c010500e>] do_IRQ+0x82/0xa2
 [<c010371e>] common_interrupt+0x1a/0x20
 [<c02a623e>] _spin_lock+0x3/0xf
 [<c026e441>] tcp_alloc_md5sig_pool+0xc/0xa2
 [<c027a27b>] tcp_v4_md5_do_add+0x6a/0x11a
 [<c027a536>] tcp_v4_parse_md5_keys+0xeb/0xf8
 [<c02a61b8>] _spin_lock_bh+0x8/0x18
 [<c026dc26>] do_tcp_setsockopt+0x2f1/0x314
 [<c023ebd1>] sock_common_setsockopt+0x1c/0x21
 [<c023c72e>] sys_setsockopt+0x8d/0xac
 [<c023cd86>] sys_socketcall+0x1e7/0x242
 [<c0102d2d>] sysenter_past_esp+0x56/0x79
 =======================

