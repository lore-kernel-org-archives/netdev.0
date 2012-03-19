From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 09:10:51 +0100
Message-ID: <4F66EA0B.1080705@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:58334 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179Ab2CSIRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 04:17:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

today i've seen the following error / backtrace several times on a
machine running vanilla stable 3.0.23.

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
Hardware name: empty
Modules linked in: xt_tcpudp ipt_REJECT iptable_filter ip_tables
x_tables k8temp ipv6 md_mod dm_snapshot dm_mod
Pid: 0, comm: swapper Tainted: G        W   2.6.40.23intel #1
Call Trace:
 [<c05de162>] ? tcp_ack+0x1d62/0x2030
 [<c013d56c>] warn_slowpath_common+0x6c/0xa0
 [<c05de162>] ? tcp_ack+0x1d62/0x2030
 [<c0605e20>] ? bictcp_undo_cwnd+0x20/0x20
 [<c013d5bd>] warn_slowpath_null+0x1d/0x20
 [<c05de162>] tcp_ack+0x1d62/0x2030
 [<c05daa09>] ? tcp_validate_incoming+0x269/0x330
 [<c05de6d6>] tcp_rcv_established+0x2a6/0x5a0
 [<c05e72d1>] tcp_v4_do_rcv+0xf1/0x250
 [<c05e7a7a>] tcp_v4_rcv+0x64a/0x7b0
 [<f874c0ab>] ? iptable_filter_hook+0x3b/0x74 [iptable_filter]
 [<c05c809f>] ip_local_deliver_finish+0xef/0x260
 [<c05c829f>] ip_local_deliver+0x8f/0xa0
 [<c05c7fb0>] ? ip_call_ra_chain+0x110/0x110
 [<c05c7973>] ip_rcv_finish+0x143/0x350
 [<c05c7e1d>] ip_rcv+0x29d/0x320
 [<c05e484e>] ? tcp4_gro_receive+0x4e/0xd0
 [<c05a74cc>] __netif_receive_skb+0x37c/0x3f0
 [<c05a8177>] netif_receive_skb+0x47/0x70
 [<c05a829f>] napi_skb_finish+0x3f/0x50
 [<c05a8f91>] napi_gro_receive+0x111/0x140
 [<c04e61e7>] e1000_receive_skb+0x47/0x60
 [<c04e7e56>] e1000_clean_rx_irq+0x1f6/0x370
 [<c04e69f3>] e1000_clean+0x63/0x2b0
 [<c05a874d>] net_rx_action+0xdd/0x230
 [<c0143369>] __do_softirq+0xa9/0x180
 [<c01432c0>] ? irq_enter+0x60/0x60
 [<c01432c0>] ? irq_enter+0x60/0x60
 <IRQ>  [<c01431bd>] ? irq_exit+0x6d/0x90
 [<c0104375>] ? do_IRQ+0x45/0xb0
 [<c01431bd>] ? irq_exit+0x6d/0x90
 [<c011bf09>] ? smp_apic_timer_interrupt+0x59/0x90
 [<c065e9b0>] ? common_interrupt+0x30/0x38
 [<c010aaee>] ? mwait_idle+0xee/0x100
 [<c0101ee6>] ? cpu_idle+0x96/0xb0
 [<c0638188>] ? rest_init+0x58/0x70
 [<c08a08a5>] ? start_kernel+0x344/0x3a7
 [<c08a0325>] ? kernel_init+0x13e/0x13e
 [<c08a0079>] ? i386_start_kernel+0x79/0xb5
---[ end trace b310ee8f88560c3c ]---

Stefan
