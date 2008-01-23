From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 16:32:20 +0530
Message-ID: <OFADDD4CF1.583863C7-ON652573D9.003CD405-652573D9.003CA37C@in.ibm.com>
References: <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:32951 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751546AbYAWLEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 06:04:01 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0NB3tf1018370
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 16:33:55 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NB3tMn1093744
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 16:33:55 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0NB3thN019672
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 11:03:55 GMT
In-Reply-To: <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running with this patch, I got these errors (pasted at the end
of this mail).

The list of unique errors are:

net/ipv4/tcp_input.c:1767
net/ipv4/tcp_input.c:2169
net/ipv4/tcp_input.c:2855
net/ipv4/tcp_input.c:3184
net/ipv4/tcp_input.c:3248
net/ipv4/tcp_output.c:1467
net/ipv4/tcp_output.c:1977

Thanks,

- KK

Jan 23 02:50:59 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:50:59 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 23 02:50:59 elm3b39 kernel: NIP: c00000000039ec58 LR: c00000000039ecd0 CTR: c0000000003d8680
Jan 23 02:50:59 elm3b39 kernel: REGS: c0000000cbffe700 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:50:59 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24044424  XER: 00000020
Jan 23 02:50:59 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:50:59 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffe980 c0000000005fa880 c0000000ce520180
Jan 23 02:50:59 elm3b39 kernel: GPR04: c0000000c77f2380 0000000000000001 c0000000003d8680 0001271dd0770000
Jan 23 02:50:59 elm3b39 kernel: GPR08: c00000000061ff78 0000000000000008 0000000000000100 0000000000000005
Jan 23 02:50:59 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 0000000000012723
Jan 23 02:50:59 elm3b39 kernel: GPR16: 0000000000000005 c0000000ce520248 00000000745afc5e 0000000000000001
Jan 23 02:50:59 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:50:59 elm3b39 kernel: GPR24: 0000000000000000 0000000000000001 0000000000000001 c0000000ce520248
Jan 23 02:50:59 elm3b39 kernel: GPR28: 0000000000000000 c0000000ce520180 c0000000005c2e68 c0000000c7084700
Jan 23 02:50:59 elm3b39 kernel: NIP [c00000000039ec58] .tcp_mark_head_lost+0x128/0x1e0
Jan 23 02:50:59 elm3b39 kernel: LR [c00000000039ecd0] .tcp_mark_head_lost+0x1a0/0x1e0
Jan 23 02:50:59 elm3b39 kernel: Call Trace:
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffe980] [c0000000005c2e68] 0xc0000000005c2e68 (unreliable)
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffea30] [c0000000003a18a0] .tcp_ack+0x1a70/0x20d0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:50:59 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:00 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:00 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:00 elm3b39 kernel: Instruction dump:
Jan 23 02:51:00 elm3b39 kernel: 7fbfd800 419e0010 e81d01d8 7fa0f800 409eff78 801d055c 813d0558 817d046c
Jan 23 02:51:00 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fa3eb78 48010391 60000000
Jan 23 02:51:00 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:00 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1977
Jan 23 02:51:00 elm3b39 kernel: NIP: c0000000003a9628 LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:00 elm3b39 kernel: REGS: c0000000cbffe710 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:00 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:00 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:00 elm3b39 kernel: GPR00: fffffffffffffffd c0000000cbffe990 c0000000005fa880 c0000000ce520180
Jan 23 02:51:00 elm3b39 kernel: GPR04: 0000000000000000 0000000000000003 0000000000000005 0000000000000005
Jan 23 02:51:00 elm3b39 kernel: GPR08: 0000000000000004 0000000000000001 0000000000000005 0000000000000003
Jan 23 02:51:00 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 0000000000012723
Jan 23 02:51:00 elm3b39 kernel: GPR16: 0000000000000005 c0000000ce520248 00000000745afc5e 0000000000000001
Jan 23 02:51:00 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:00 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000ce520180 c0000000ce520248
Jan 23 02:51:00 elm3b39 kernel: GPR28: 0000000000000000 c0000000ce520180 c0000000005c2ff0 c0000000cb45eb00
Jan 23 02:51:00 elm3b39 kernel: NIP [c0000000003a9628] .tcp_xmit_retransmit_queue+0x408/0x500
Jan 23 02:51:00 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:00 elm3b39 kernel: Call Trace:
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffe990] [c0000000cbffea30] 0xc0000000cbffea30 (unreliable)
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:00 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:00 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:00 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:01 elm3b39 kernel: Instruction dump:
Jan 23 02:51:01 elm3b39 kernel: 80bd055c 4bfffeac e80300c8 3b6300c8 3b800000 7fbb0000 419efc4c 7c1f0378
Jan 23 02:51:01 elm3b39 kernel: 4bfffc44 7f8a4840 7d200026 5529effe <0b090000> 7fa3eb78 480059c1 60000000
Jan 23 02:51:01 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:01 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3248
Jan 23 02:51:01 elm3b39 kernel: NIP: c0000000003a0eec LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:01 elm3b39 kernel: REGS: c0000000cbffe7b0 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:01 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:01 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:01 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea30 c0000000005fa880 c0000000ce520180
Jan 23 02:51:01 elm3b39 kernel: GPR04: 0000000000000005 c00000000060e400 0000000000000005 0000000000000005
Jan 23 02:51:01 elm3b39 kernel: GPR08: 0000000000000004 0000000000000008 0000000000000000 0000000000000005
Jan 23 02:51:01 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012723
Jan 23 02:51:01 elm3b39 kernel: GPR16: 0000000000000005 c0000000ce520248 00000000745afc5e 0000000000000001
Jan 23 02:51:01 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:01 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000ce520180 0000000024042428
Jan 23 02:51:01 elm3b39 kernel: GPR28: 0000000000000000 0000000000000005 c0000000005c2e68 0000000000000000
Jan 23 02:51:01 elm3b39 kernel: NIP [c0000000003a0eec] .tcp_ack+0x10bc/0x20d0
Jan 23 02:51:01 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:01 elm3b39 kernel: Call Trace:
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0 (unreliable)
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:01 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:01 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:01 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:02 elm3b39 kernel: Instruction dump:
Jan 23 02:51:02 elm3b39 kernel: 2fa90000 419e0010 e8be8020 e8050000 f8090028 801a055c 813a0558 817a046c
Jan 23 02:51:02 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7f43d378 4800e0fd 60000000
Jan 23 02:51:02 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:02 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1467
Jan 23 02:51:02 elm3b39 kernel: NIP: c0000000003a99e0 LR: c0000000003a5d80 CTR: c0000000003d8680
Jan 23 02:51:02 elm3b39 kernel: REGS: c0000000cbffe810 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:02 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042444  XER: 20000020
Jan 23 02:51:02 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:02 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea90 c0000000005fa880 c0000000ce520180
Jan 23 02:51:02 elm3b39 kernel: GPR04: 00000000000005a8 0000000000000001 0000000000000005 0000000000000005
Jan 23 02:51:02 elm3b39 kernel: GPR08: 0000000000000003 0000000000000008 0000000000000005 c0000000ce520180
Jan 23 02:51:02 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000038 d000000000106000
Jan 23 02:51:02 elm3b39 kernel: GPR16: 00000000000006c0 0000000000000008 c0000000ccb95000 c0000000cc198cc0
Jan 23 02:51:02 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:02 elm3b39 kernel: GPR24: 0000000000000001 0000000000000020 0000000000000000 00000000000005a8
Jan 23 02:51:02 elm3b39 kernel: GPR28: c0000000cb883780 c0000000ce520180 c0000000005c2ff0 c0000000ce520180
Jan 23 02:51:02 elm3b39 kernel: NIP [c0000000003a99e0] .__tcp_push_pending_frames+0xa0/0xa20
Jan 23 02:51:02 elm3b39 kernel: LR [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:02 elm3b39 kernel: Call Trace:
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbffea90] [c0000000003a9b08] .__tcp_push_pending_frames+0x1c8/0xa20 (unreliable)
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:02 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:03 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:03 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:03 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:03 elm3b39 kernel: Instruction dump:
Jan 23 02:51:03 elm3b39 kernel: 419e0484 80030390 2f800000 409e0394 80fd046c 811d055c 815d0558 3b400000
Jan 23 02:51:03 elm3b39 kernel: 7d2a4214 7f893840 7c000026 5400f7fe <0b000000> 7fa3eb78 48005609 60000000
Jan 23 02:51:03 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:03 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 23 02:51:03 elm3b39 kernel: NIP: c00000000039ec58 LR: c00000000039ecd0 CTR: c0000000003d8680
Jan 23 02:51:03 elm3b39 kernel: REGS: c0000000cbffe700 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:03 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24044424  XER: 00000020
Jan 23 02:51:03 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:03 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffe980 c0000000005fa880 c0000000cca44700
Jan 23 02:51:03 elm3b39 kernel: GPR04: c0000000cbbe0a80 0000000000000001 c0000000003d8680 0001271dd0770000
Jan 23 02:51:04 elm3b39 kernel: GPR08: c00000000061ff78 0000000000000008 0000000000000100 0000000000000005
Jan 23 02:51:04 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 0000000000012724
Jan 23 02:51:04 elm3b39 kernel: GPR16: 0000000000000005 c0000000cca447c8 0000000074cf85f7 0000000000000001
Jan 23 02:51:04 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:04 elm3b39 kernel: GPR24: 0000000000000000 0000000000000001 0000000000000001 c0000000cca447c8
Jan 23 02:51:04 elm3b39 kernel: GPR28: 0000000000000000 c0000000cca44700 c0000000005c2e68 c0000000c7120080
Jan 23 02:51:04 elm3b39 kernel: NIP [c00000000039ec58] .tcp_mark_head_lost+0x128/0x1e0
Jan 23 02:51:04 elm3b39 kernel: LR [c00000000039ecd0] .tcp_mark_head_lost+0x1a0/0x1e0
Jan 23 02:51:04 elm3b39 kernel: Call Trace:
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffe980] [c0000000005c2e68] 0xc0000000005c2e68 (unreliable)
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffea30] [c0000000003a18a0] .tcp_ack+0x1a70/0x20d0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:04 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:04 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:04 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:05 elm3b39 kernel: Instruction dump:
Jan 23 02:51:05 elm3b39 kernel: 7fbfd800 419e0010 e81d01d8 7fa0f800 409eff78 801d055c 813d0558 817d046c
Jan 23 02:51:05 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fa3eb78 48010391 60000000
Jan 23 02:51:05 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:05 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1977
Jan 23 02:51:05 elm3b39 kernel: NIP: c0000000003a9628 LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:05 elm3b39 kernel: REGS: c0000000cbffe710 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:05 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:05 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:05 elm3b39 kernel: GPR00: fffffffffffffffd c0000000cbffe990 c0000000005fa880 c0000000cca44700
Jan 23 02:51:05 elm3b39 kernel: GPR04: 0000000000000000 0000000000000003 0000000000000005 0000000000000005
Jan 23 02:51:05 elm3b39 kernel: GPR08: 0000000000000004 0000000000000001 0000000000000005 0000000000000003
Jan 23 02:51:05 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 0000000000012724
Jan 23 02:51:05 elm3b39 kernel: GPR16: 0000000000000005 c0000000cca447c8 0000000074cf85f7 0000000000000001
Jan 23 02:51:05 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:05 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000cca44700 c0000000cca447c8
Jan 23 02:51:05 elm3b39 kernel: GPR28: 0000000000000000 c0000000cca44700 c0000000005c2ff0 c0000000c73b3d00
Jan 23 02:51:05 elm3b39 kernel: NIP [c0000000003a9628] .tcp_xmit_retransmit_queue+0x408/0x500
Jan 23 02:51:05 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:05 elm3b39 kernel: Call Trace:
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbffe990] [c0000000cbffea30] 0xc0000000cbffea30 (unreliable)
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:05 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:06 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:06 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:06 elm3b39 kernel: Instruction dump:
Jan 23 02:51:06 elm3b39 kernel: 80bd055c 4bfffeac e80300c8 3b6300c8 3b800000 7fbb0000 419efc4c 7c1f0378
Jan 23 02:51:06 elm3b39 kernel: 4bfffc44 7f8a4840 7d200026 5529effe <0b090000> 7fa3eb78 480059c1 60000000
Jan 23 02:51:06 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:06 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3248
Jan 23 02:51:06 elm3b39 kernel: NIP: c0000000003a0eec LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:06 elm3b39 kernel: REGS: c0000000cbffe7b0 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:06 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:06 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:06 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea30 c0000000005fa880 c0000000cca44700
Jan 23 02:51:06 elm3b39 kernel: GPR04: 0000000000000005 c00000000060e400 0000000000000005 0000000000000005
Jan 23 02:51:06 elm3b39 kernel: GPR08: 0000000000000004 0000000000000008 0000000000000000 0000000000000005
Jan 23 02:51:06 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012724
Jan 23 02:51:06 elm3b39 kernel: GPR16: 0000000000000005 c0000000cca447c8 0000000074cf85f7 0000000000000001
Jan 23 02:51:06 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:06 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000cca44700 0000000024042428
Jan 23 02:51:06 elm3b39 kernel: GPR28: 0000000000000000 0000000000000005 c0000000005c2e68 0000000000000000
Jan 23 02:51:06 elm3b39 kernel: NIP [c0000000003a0eec] .tcp_ack+0x10bc/0x20d0
Jan 23 02:51:06 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:06 elm3b39 kernel: Call Trace:
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0 (unreliable)
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:06 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:07 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:07 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:07 elm3b39 kernel: Instruction dump:
Jan 23 02:51:07 elm3b39 kernel: 2fa90000 419e0010 e8be8020 e8050000 f8090028 801a055c 813a0558 817a046c
Jan 23 02:51:07 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7f43d378 4800e0fd 60000000
Jan 23 02:51:07 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:07 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1467
Jan 23 02:51:07 elm3b39 kernel: NIP: c0000000003a99e0 LR: c0000000003a5d80 CTR: c0000000003d8680
Jan 23 02:51:07 elm3b39 kernel: REGS: c0000000cbffe810 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:07 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042444  XER: 20000020
Jan 23 02:51:07 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:07 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea90 c0000000005fa880 c0000000cca44700
Jan 23 02:51:07 elm3b39 kernel: GPR04: 00000000000005a8 0000000000000001 0000000000000005 0000000000000005
Jan 23 02:51:07 elm3b39 kernel: GPR08: 0000000000000003 0000000000000008 0000000000000005 c0000000cca44700
Jan 23 02:51:07 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000023 d000000000106000
Jan 23 02:51:07 elm3b39 kernel: GPR16: 0000000000000c20 0000000000000003 c0000000ccb95000 c0000000cc198cc0
Jan 23 02:51:07 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:07 elm3b39 kernel: GPR24: 0000000000000001 0000000000000020 0000000000000000 00000000000005a8
Jan 23 02:51:07 elm3b39 kernel: GPR28: c0000000cb241180 c0000000cca44700 c0000000005c2ff0 c0000000cca44700
Jan 23 02:51:07 elm3b39 kernel: NIP [c0000000003a99e0] .__tcp_push_pending_frames+0xa0/0xa20
Jan 23 02:51:07 elm3b39 kernel: LR [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:07 elm3b39 kernel: Call Trace:
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffea90] [c00000000039877c] .tcp_done+0x8c/0x110 (unreliable)
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:07 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:07 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:07 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:08 elm3b39 kernel: Instruction dump:
Jan 23 02:51:08 elm3b39 kernel: 419e0484 80030390 2f800000 409e0394 80fd046c 811d055c 815d0558 3b400000
Jan 23 02:51:08 elm3b39 kernel: 7d2a4214 7f893840 7c000026 5400f7fe <0b000000> 7fa3eb78 48005609 60000000
Jan 23 02:51:08 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:08 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 23 02:51:08 elm3b39 kernel: NIP: c00000000039ec58 LR: c00000000039ecd0 CTR: c0000000003d8680
Jan 23 02:51:08 elm3b39 kernel: REGS: c0000000cbffe700 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:08 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24044424  XER: 00000020
Jan 23 02:51:08 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:08 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffe980 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:08 elm3b39 kernel: GPR04: c0000000cbf94300 0000000000000001 c0000000003d8680 0001271dd0770000
Jan 23 02:51:08 elm3b39 kernel: GPR08: c00000000061ff78 0000000000000008 0000000000000100 0000000000000005
Jan 23 02:51:08 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 000000000001272b
Jan 23 02:51:08 elm3b39 kernel: GPR16: 0000000000000005 c0000000ccd479c8 0000000074399665 0000000000000001
Jan 23 02:51:08 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:08 elm3b39 kernel: GPR24: 0000000000000000 0000000000000001 0000000000000001 c0000000ccd479c8
Jan 23 02:51:08 elm3b39 kernel: GPR28: 0000000000000000 c0000000ccd47900 c0000000005c2e68 c0000000cbb50580
Jan 23 02:51:08 elm3b39 kernel: NIP [c00000000039ec58] .tcp_mark_head_lost+0x128/0x1e0
Jan 23 02:51:08 elm3b39 kernel: LR [c00000000039ecd0] .tcp_mark_head_lost+0x1a0/0x1e0
Jan 23 02:51:08 elm3b39 kernel: Call Trace:
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffe980] [c0000000005c2e68] 0xc0000000005c2e68 (unreliable)
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffea30] [c0000000003a18a0] .tcp_ack+0x1a70/0x20d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:08 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:08 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:08 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:08 elm3b39 kernel: Instruction dump:
Jan 23 02:51:08 elm3b39 kernel: 7fbfd800 419e0010 e81d01d8 7fa0f800 409eff78 801d055c 813d0558 817d046c
Jan 23 02:51:08 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fa3eb78 48010391 60000000
Jan 23 02:51:08 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:09 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1977
Jan 23 02:51:09 elm3b39 kernel: NIP: c0000000003a9628 LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:09 elm3b39 kernel: REGS: c0000000cbffe710 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:09 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:09 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:09 elm3b39 kernel: GPR00: fffffffffffffffd c0000000cbffe990 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:09 elm3b39 kernel: GPR04: 0000000000000000 0000000000000003 0000000000000005 0000000000000005
Jan 23 02:51:09 elm3b39 kernel: GPR08: 0000000000000004 0000000000000001 0000000000000005 0000000000000003
Jan 23 02:51:09 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000000 000000000001272b
Jan 23 02:51:09 elm3b39 kernel: GPR16: 0000000000000005 c0000000ccd479c8 0000000074399665 0000000000000001
Jan 23 02:51:09 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:09 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000ccd47900 c0000000ccd479c8
Jan 23 02:51:09 elm3b39 kernel: GPR28: 0000000000000000 c0000000ccd47900 c0000000005c2ff0 c0000000c73b3900
Jan 23 02:51:09 elm3b39 kernel: NIP [c0000000003a9628] .tcp_xmit_retransmit_queue+0x408/0x500
Jan 23 02:51:09 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:09 elm3b39 kernel: Call Trace:
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffe990] [c0000000cbffea30] 0xc0000000cbffea30 (unreliable)
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:09 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:09 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:09 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:09 elm3b39 kernel: Instruction dump:
Jan 23 02:51:09 elm3b39 kernel: 80bd055c 4bfffeac e80300c8 3b6300c8 3b800000 7fbb0000 419efc4c 7c1f0378
Jan 23 02:51:09 elm3b39 kernel: 4bfffc44 7f8a4840 7d200026 5529effe <0b090000> 7fa3eb78 480059c1 60000000
Jan 23 02:51:09 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:09 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3248
Jan 23 02:51:09 elm3b39 kernel: NIP: c0000000003a0eec LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:09 elm3b39 kernel: REGS: c0000000cbffe7b0 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:09 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042424  XER: 00000020
Jan 23 02:51:09 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:09 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea30 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:09 elm3b39 kernel: GPR04: 0000000000000005 c00000000060e400 0000000000000005 0000000000000005
Jan 23 02:51:09 elm3b39 kernel: GPR08: 0000000000000004 0000000000000008 0000000000000000 0000000000000005
Jan 23 02:51:09 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 000000000001272b
Jan 23 02:51:09 elm3b39 kernel: GPR16: 0000000000000005 c0000000ccd479c8 0000000074399665 0000000000000001
Jan 23 02:51:09 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:09 elm3b39 kernel: GPR24: 0000000000000000 0000000024048422 c0000000ccd47900 0000000024042428
Jan 23 02:51:09 elm3b39 kernel: GPR28: 0000000000000000 0000000000000005 c0000000005c2e68 0000000000000000
Jan 23 02:51:09 elm3b39 kernel: NIP [c0000000003a0eec] .tcp_ack+0x10bc/0x20d0
Jan 23 02:51:09 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:10 elm3b39 kernel: Call Trace:
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffea30] [c0000000003a155c] .tcp_ack+0x172c/0x20d0 (unreliable)
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:10 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:10 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:10 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:10 elm3b39 kernel: Instruction dump:
Jan 23 02:51:10 elm3b39 kernel: 2fa90000 419e0010 e8be8020 e8050000 f8090028 801a055c 813a0558 817a046c
Jan 23 02:51:10 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7f43d378 4800e0fd 60000000
Jan 23 02:51:10 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:10 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1467
Jan 23 02:51:10 elm3b39 kernel: NIP: c0000000003a99e0 LR: c0000000003a5d80 CTR: c0000000003d8680
Jan 23 02:51:11 elm3b39 kernel: REGS: c0000000cbffe810 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:11 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042444  XER: 20000020
Jan 23 02:51:11 elm3b39 kernel: TASK = c0000000ce1d3660[4821] 'iperf' THREAD: c0000000cbffc000 CPU: 0
Jan 23 02:51:11 elm3b39 kernel: GPR00: 0000000000000001 c0000000cbffea90 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:11 elm3b39 kernel: GPR04: 00000000000005a8 0000000000000001 0000000000000005 0000000000000005
Jan 23 02:51:11 elm3b39 kernel: GPR08: 0000000000000003 0000000000000008 0000000000000005 c0000000ccd47900
Jan 23 02:51:11 elm3b39 kernel: GPR12: 0000000024042422 c000000000556700 0000000000000027 d000000000106000
Jan 23 02:51:11 elm3b39 kernel: GPR16: 00000000000014a0 0000000000000007 c0000000ccb95000 c0000000cc198cc0
Jan 23 02:51:11 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:11 elm3b39 kernel: GPR24: 0000000000000001 0000000000000020 0000000000000000 00000000000005a8
Jan 23 02:51:11 elm3b39 kernel: GPR28: c0000000cb699080 c0000000ccd47900 c0000000005c2ff0 c0000000ccd47900
Jan 23 02:51:11 elm3b39 kernel: NIP [c0000000003a99e0] .__tcp_push_pending_frames+0xa0/0xa20
Jan 23 02:51:11 elm3b39 kernel: LR [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:11 elm3b39 kernel: Call Trace:
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffea90] [c0000000003a9b08] .__tcp_push_pending_frames+0x1c8/0xa20 (unreliable)
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffeb90] [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffec40] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffed00] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffedc0] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffee50] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbffef20] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff000] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff110] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff1c0] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff280] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff340] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff3c0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff440] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff4c0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:11 elm3b39 kernel: --- Exception: 501 at .__alloc_skb+0x108/0x190
Jan 23 02:51:11 elm3b39 kernel:     LR = .__alloc_skb+0xa4/0x190
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff7b0] [c000000000352118] .__alloc_skb+0x88/0x190 (unreliable)
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff850] [c000000000399248] .sk_stream_alloc_skb+0x48/0x170
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfff8e0] [c00000000039a914] .tcp_sendmsg+0x454/0xe90
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfffa10] [c0000000003475f4] .sock_aio_write+0x164/0x180
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfffb40] [c0000000000cf3b4] .do_sync_write+0xd4/0x170
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfffcf0] [c0000000000cfe34] .vfs_write+0x1c4/0x1d0
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfffd90] [c0000000000d07ec] .sys_write+0x4c/0x90
Jan 23 02:51:11 elm3b39 kernel: [c0000000cbfffe30] [c0000000000086ac] syscall_exit+0x0/0x40
Jan 23 02:51:11 elm3b39 kernel: Instruction dump:
Jan 23 02:51:11 elm3b39 kernel: 419e0484 80030390 2f800000 409e0394 80fd046c <0>------------[ cut here ]------------
Jan 23 02:51:11 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 23 02:51:11 elm3b39 kernel: NIP: c0000000003a4918 LR: c0000000003ac640 CTR: c0000000003ac210
Jan 23 02:51:11 elm3b39 kernel: REGS: c0000000ce0f7400 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:11 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 28000024  XER: 20000020
Jan 23 02:51:11 elm3b39 kernel: TASK = c0000000ce0f10e0[0] 'swapper' THREAD: c0000000ce0f4000 CPU: 2
Jan 23 02:51:11 elm3b39 kernel: GPR00: 0000000000000001 c0000000ce0f7680 c0000000005fa880 c0000000ce520180
Jan 23 02:51:11 elm3b39 kernel: GPR04: c00000000076bae8 0000000100012758 0000000000000000 0000000000000000
Jan 23 02:51:11 elm3b39 kernel: GPR08: 0000000000000000 0000000000000008 c0000000cb45eb38 0000000000000005
Jan 23 02:51:11 elm3b39 kernel: GPR12: 0000000088000028 c000000000556c00 0000000000000000 0000000000c00020
Jan 23 02:51:11 elm3b39 kernel: GPR16: 0000000000000002 0000000000000000 0000000000000000 0000000000000000
Jan 23 02:51:11 elm3b39 kernel: GPR20: 0000000000000000 0000000000000000 0000000000000000 c00000000060e400
Jan 23 02:51:11 elm3b39 kernel: GPR24: c0000000ce0f4000 0000000000000000 c0000000ce520248 c00000000060e400
Jan 23 02:51:11 elm3b39 kernel: GPR28: 000000000000000f c0000000ce0f7830 c0000000005c2e68 c0000000ce520180
Jan 23 02:51:12 elm3b39 kernel: NIP [c0000000003a4918] .tcp_enter_frto+0x118/0x390
Jan 23 02:51:12 elm3b39 kernel: LR [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:12 elm3b39 kernel: Call Trace:
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7680] [c0000000ce0f7710] 0xc0000000ce0f7710 (unreliable)
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7710] [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f77c0] [c0000000000614f4] .run_timer_softirq+0x1c4/0x2a0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7890] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7950] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f79d0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7a50] [c0000000000261b4] .timer_interrupt+0x134/0x150
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7ae0] [c000000000003600] decrementer_common+0x100/0x180
Jan 23 02:51:12 elm3b39 kernel: --- Exception: 901 at .ppc64_runlatch_off+0x20/0x60
Jan 23 02:51:12 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7dd0] [0000000000000000] .__start+0x4000000000000000/0x8 (unreliable)
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7e70] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7f00] [c00000000002bd5c] .start_secondary+0x14c/0x190
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7f90] [c000000000008364] .start_secondary_prolog+0xc/0x10
Jan 23 02:51:12 elm3b39 kernel: Instruction dump:
Jan 23 02:51:12 elm3b39 kernel: e92b00a8 7d295214 a1690008 7c0b0050 901f0470 801f055c 813f0558 817f046c
Jan 23 02:51:12 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fe3fb78 4800a6d1 60000000
Jan 23 02:51:12 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 23 02:51:12 elm3b39 kernel: NIP: c0000000003a4918 LR: c0000000003ac640 CTR: c0000000003ac210
Jan 23 02:51:12 elm3b39 kernel: REGS: c0000000ce0f7400 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:12 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 22000024  XER: 20000020
Jan 23 02:51:12 elm3b39 kernel: TASK = c0000000ce0f10e0[0] 'swapper' THREAD: c0000000ce0f4000 CPU: 2
Jan 23 02:51:12 elm3b39 kernel: GPR00: 0000000000000001 c0000000ce0f7680 c0000000005fa880 c0000000cca44700
Jan 23 02:51:12 elm3b39 kernel: GPR04: 0000000000000001 0000000100012758 0000000000000100 c000000000431928
Jan 23 02:51:12 elm3b39 kernel: GPR08: 0000000000000000 0000000000000008 c0000000c73b3d38 0000000000000005
Jan 23 02:51:12 elm3b39 kernel: GPR12: 0000000048000028 c000000000556c00 0000000000000000 0000000000c00020
Jan 23 02:51:12 elm3b39 kernel: GPR16: 0000000000000002 0000000000000000 0000000000000000 0000000000000000
Jan 23 02:51:12 elm3b39 kernel: GPR20: 0000000000000000 0000000000000000 0000000000000000 c00000000060e400
Jan 23 02:51:12 elm3b39 kernel: GPR24: c0000000ce0f4000 0000000000000000 c0000000cca447c8 c00000000060e400
Jan 23 02:51:12 elm3b39 kernel: GPR28: 000000000000000f c0000000ce0f7830 c0000000005c2e68 c0000000cca44700
Jan 23 02:51:12 elm3b39 kernel: NIP [c0000000003a4918] .tcp_enter_frto+0x118/0x390
Jan 23 02:51:12 elm3b39 kernel: LR [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:12 elm3b39 kernel: Call Trace:
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7680] [c0000000ce0f7710] 0xc0000000ce0f7710 (unreliable)
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7710] [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f77c0] [c0000000000614f4] .run_timer_softirq+0x1c4/0x2a0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7890] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7950] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f79d0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7a50] [c0000000000261b4] .timer_interrupt+0x134/0x150
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7ae0] [c000000000003600] decrementer_common+0x100/0x180
Jan 23 02:51:12 elm3b39 kernel: --- Exception: 901 at .ppc64_runlatch_off+0x20/0x60
Jan 23 02:51:12 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7dd0] [0000000000000000] .__start+0x4000000000000000/0x8 (unreliable)
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7e70] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7f00] [c00000000002bd5c] .start_secondary+0x14c/0x190
Jan 23 02:51:12 elm3b39 kernel: [c0000000ce0f7f90] [c000000000008364] .start_secondary_prolog+0xc/0x10
Jan 23 02:51:12 elm3b39 kernel: Instruction dump:
Jan 23 02:51:12 elm3b39 kernel: e92b00a8 7d295214 a1690008 7c0b0050 901f0470 801f055c 813f0558 817f046c
Jan 23 02:51:12 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fe3fb78 4800a6d1 60000000
Jan 23 02:51:12 elm3b39 kernel: 811d055c 815d0558 3b400000
Jan 23 02:51:12 elm3b39 kernel: 7d2a4214 7f893840 7c000026 5400f7fe <0b000000> 7fa3eb78 48005609 60000000
Jan 23 02:51:12 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 23 02:51:12 elm3b39 kernel: NIP: c0000000003a4918 LR: c0000000003ac640 CTR: c0000000003ac210
Jan 23 02:51:12 elm3b39 kernel: REGS: c0000000ce0f7400 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:13 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 22000024  XER: 20000020
Jan 23 02:51:13 elm3b39 kernel: TASK = c0000000ce0f10e0[0] 'swapper' THREAD: c0000000ce0f4000 CPU: 2
Jan 23 02:51:13 elm3b39 kernel: GPR00: 0000000000000001 c0000000ce0f7680 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:13 elm3b39 kernel: GPR04: 0000000000000001 0000000100012758 0000000000000100 c000000000431928
Jan 23 02:51:13 elm3b39 kernel: GPR08: 0000000000000000 0000000000000008 c0000000c73b3938 0000000000000005
Jan 23 02:51:13 elm3b39 kernel: GPR12: 0000000042000028 c000000000556c00 0000000000000000 0000000000c00020
Jan 23 02:51:13 elm3b39 kernel: GPR16: 0000000000000002 0000000000000000 0000000000000000 0000000000000000
Jan 23 02:51:13 elm3b39 kernel: GPR20: 0000000000000000 0000000000000000 0000000000000000 c00000000060e400
Jan 23 02:51:13 elm3b39 kernel: GPR24: c0000000ce0f4000 0000000000000000 c0000000ccd479c8 c00000000060e400
Jan 23 02:51:13 elm3b39 kernel: GPR28: 000000000000000f c0000000ce0f7830 c0000000005c2e68 c0000000ccd47900
Jan 23 02:51:13 elm3b39 kernel: NIP [c0000000003a4918] .tcp_enter_frto+0x118/0x390
Jan 23 02:51:13 elm3b39 kernel: LR [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:13 elm3b39 kernel: Call Trace:
Jan 23 02:51:13 elm3b39 kernel: [c0000000ce0f7680] [c0000000ce0f7710] 0xc0000000ce0f7710 (unreliable)
Jan 23 02:51:13 elm3b39 kernel: [c0000000ce0f7710] [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:13 elm3b39 kernel: [c0000000ce0f77c0] [c0000000000614f4] .run_timer_softirq+0x1c4/0x2a0
Jan 23 02:51:13 elm3b39 kernel: [c0000000ce0f7890] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:13 elm3b39 kernel: [c0000000ce0f7950] [c00000000000c4a4] <0>------------[ cut here ]------------
Jan 23 02:51:13 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3184
Jan 23 02:51:13 elm3b39 kernel: NIP: c0000000003a0010 LR: c0000000003a5d54 CTR: c00000000021f110
Jan 23 02:51:13 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:13 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 44004024  XER: 20000020
Jan 23 02:51:13 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:13 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fefb0 c0000000005fa880 c0000000ce520180
Jan 23 02:51:13 elm3b39 kernel: GPR04: c0000000cb3fad80 0000000000000001 0000000000000003 000000000000b59e
Jan 23 02:51:13 elm3b39 kernel: GPR08: 0000000000000005 0000000000000008 0000000000000000 0000000000000001
Jan 23 02:51:13 elm3b39 kernel: GPR12: 0000000024002022 c000000000556700 0000000000000000 d000000000106000
Jan 23 02:51:13 elm3b39 kernel: GPR16: 0000000000000ac0 0000000000000000 00000000745b1316 c0000000cc198cc0
Jan 23 02:51:13 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:13 elm3b39 kernel: GPR24: c0000000cc2a208e c0000000cb3fad80 c0000000ce520180 00000000745afc5e
Jan 23 02:51:13 elm3b39 kernel: GPR28: 00000000867fa105 0000000000000400 c0000000005c2e68 c0000000cb3fadb8
Jan 23 02:51:13 elm3b39 kernel: NIP [c0000000003a0010] .tcp_ack+0x1e0/0x20d0
Jan 23 02:51:13 elm3b39 kernel: LR [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:13 elm3b39 kernel: Call Trace:
Jan 23 02:51:13 elm3b39 kernel: [c0000000005fefb0] [c00000000061e980] 0xc00000000061e980 (unreliable)
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:13 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:13 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:13 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:13 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:13 elm3b39 kernel: Instruction dump:
Jan 23 02:51:13 elm3b39 kernel: 813a046c f92100a0 7d283214 60000000 815a0560 e80100a0 f94100c0 7f890040
Jan 23 02:51:13 elm3b39 kernel: 7c000026 5400f7fe 817a0470 f96100a8 <0b000000> 7f43d378 4800efd9 60000000
Jan 23 02:51:13 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:14 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2855
Jan 23 02:51:14 elm3b39 kernel: NIP: c0000000003a0464 LR: c0000000003a0410 CTR: c00000000021f110
Jan 23 02:51:14 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:14 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24048088  XER: 20000020
Jan 23 02:51:14 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:14 elm3b39 kernel: GPR00: 0000000000000003 c0000000005fefb0 c0000000005fa880 0000000000000001
Jan 23 02:51:14 elm3b39 kernel: GPR04: c0000000c77f2380 0000000000000002 00000000745b1316 0000000000000000
Jan 23 02:51:14 elm3b39 kernel: GPR08: c000000000556700 0000000000000001 c0000000c77f2100 0000000000000017
Jan 23 02:51:14 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012771
Jan 23 02:51:14 elm3b39 kernel: GPR16: 0000000000000001 c0000000ce520248 00000000745b1316 0000000000000001
Jan 23 02:51:14 elm3b39 kernel: GPR20: 000000000000004f 000000000000004f 0000000000000005 000000000000000c
Jan 23 02:51:14 elm3b39 kernel: GPR24: 00000000745b1316 0000000000000004 c0000000ce520180 c0000000c77f23b8
Jan 23 02:51:14 elm3b39 kernel: GPR28: 0000000000000001 0000000000000005 c0000000005c2e68 c0000000c7084700
Jan 23 02:51:14 elm3b39 kernel: NIP [c0000000003a0464] .tcp_ack+0x634/0x20d0
Jan 23 02:51:14 elm3b39 kernel: LR [c0000000003a0410] .tcp_ack+0x5e0/0x20d0
Jan 23 02:51:14 elm3b39 kernel: Call Trace:
Jan 23 02:51:14 elm3b39 kernel: [c0000000005fefb0] [c0000000003a0410] .tcp_ack+0x5e0/0x20d0 (unreliable)
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:14 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:14 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:14 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:14 elm3b39 kernel: Instruction dump:
Jan 23 02:51:14 elm3b39 kernel: 41920010 e81a01d8 7fbf0000 409efdb0 80fa046c 7eddb378 813a055c 801a0558
Jan 23 02:51:14 elm3b39 kernel: 7c004a14 7f870040 7d200026 5529effe <0b090000> 7f43d378 4800eb85 60000000
Jan 23 02:51:14 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:14 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3184
Jan 23 02:51:14 elm3b39 kernel: NIP: c0000000003a0010 LR: c0000000003a5d54 CTR: c00000000021f110
Jan 23 02:51:14 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:14 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 44004024  XER: 20000020
Jan 23 02:51:14 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:14 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fefb0 c0000000005fa880 c0000000cca44700
Jan 23 02:51:14 elm3b39 kernel: GPR04: c0000000cb3fad80 0000000000000001 0000000000000003 000000000000b5a0
Jan 23 02:51:14 elm3b39 kernel: GPR08: 0000000000000005 0000000000000008 0000000000000000 0000000000000001
Jan 23 02:51:14 elm3b39 kernel: GPR12: 0000000024002022 c000000000556700 0000000000000001 d000000000106000
Jan 23 02:51:14 elm3b39 kernel: GPR16: 0000000000000ae0 0000000000000001 0000000074cf9caf c0000000cc198cc0
Jan 23 02:51:14 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:14 elm3b39 kernel: GPR24: c0000000cc2a208e c0000000cb3fad80 c0000000cca44700 0000000074cf85f7
Jan 23 02:51:14 elm3b39 kernel: GPR28: 000000008680b8c1 0000000000000400 c0000000005c2e68 c0000000cb3fadb8
Jan 23 02:51:14 elm3b39 kernel: NIP [c0000000003a0010] .tcp_ack+0x1e0/0x20d0
Jan 23 02:51:14 elm3b39 kernel: LR [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:14 elm3b39 kernel: Call Trace:
Jan 23 02:51:14 elm3b39 kernel: [c0000000005fefb0] [c00000000061e980] 0xc00000000061e980 (unreliable)
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:14 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:15 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:15 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:15 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:15 elm3b39 kernel: Instruction dump:
Jan 23 02:51:15 elm3b39 kernel: 813a046c f92100a0 7d283214 60000000 815a0560 e80100a0 f94100c0 7f890040
Jan 23 02:51:15 elm3b39 kernel: 7c000026 5400f7fe 817a0470 f96100a8 <0b000000> 7f43d378 4800efd9 60000000
Jan 23 02:51:15 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:15 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2855
Jan 23 02:51:15 elm3b39 kernel: NIP: c0000000003a0464 LR: c0000000003a0410 CTR: c00000000021f110
Jan 23 02:51:15 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:15 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24048088  XER: 20000020
Jan 23 02:51:15 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:15 elm3b39 kernel: GPR00: 0000000000000003 c0000000005fefb0 c0000000005fa880 0000000000000001
Jan 23 02:51:15 elm3b39 kernel: GPR04: c0000000cbbe0a80 0000000000000002 0000000074cf9caf 0000000000000000
Jan 23 02:51:15 elm3b39 kernel: GPR08: c000000000556700 0000000000000001 c0000000cbbe0000 000000000000001b
Jan 23 02:51:15 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012771
Jan 23 02:51:15 elm3b39 kernel: GPR16: 0000000000000001 c0000000cca447c8 0000000074cf9caf 0000000000000001
Jan 23 02:51:15 elm3b39 kernel: GPR20: 000000000000004f 000000000000004f 0000000000000005 000000000000000c
Jan 23 02:51:15 elm3b39 kernel: GPR24: 0000000074cf9caf 0000000000000004 c0000000cca44700 c0000000cbbe0ab8
Jan 23 02:51:15 elm3b39 kernel: GPR28: 0000000000000001 0000000000000005 c0000000005c2e68 c0000000c7120080
Jan 23 02:51:15 elm3b39 kernel: NIP [c0000000003a0464] .tcp_ack+0x634/0x20d0
Jan 23 02:51:15 elm3b39 kernel: LR [c0000000003a0410] .tcp_ack+0x5e0/0x20d0
Jan 23 02:51:15 elm3b39 kernel: Call Trace:
Jan 23 02:51:15 elm3b39 kernel: [c0000000005fefb0] [c0000000003a0410] .tcp_ack+0x5e0/0x20d0 (unreliable)
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:15 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:15 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:15 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:15 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:16 elm3b39 kernel: Instruction dump:
Jan 23 02:51:16 elm3b39 kernel: 41920010 e81a01d8 7fbf0000 409efdb0 80fa046c 7eddb378 813a055c 801a0558
Jan 23 02:51:16 elm3b39 kernel: 7c004a14 7f870040 7d200026 5529effe <0b090000> 7f43d378 4800eb85 60000000
Jan 23 02:51:16 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:16 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 23 02:51:16 elm3b39 kernel: NIP: c00000000039ec58 LR: c00000000039ecd0 CTR: c0000000003d8680
Jan 23 02:51:16 elm3b39 kernel: REGS: c0000000005fec80 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:16 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24044024  XER: 00000020
Jan 23 02:51:16 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:16 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fef00 c0000000005fa880 c0000000c725f900
Jan 23 02:51:16 elm3b39 kernel: GPR04: c0000000cb8e7100 0000000000000001 c0000000003d8680 0001271dd0770000
Jan 23 02:51:16 elm3b39 kernel: GPR08: c00000000061ff78 0000000000000008 0000000000000100 0000000000000005
Jan 23 02:51:16 elm3b39 kernel: GPR12: 0000000024042022 c000000000556700 0000000000000000 0000000000012773
Jan 23 02:51:16 elm3b39 kernel: GPR16: 0000000000000005 c0000000c725f9c8 0000000074ce5b1e 0000000000000001
Jan 23 02:51:16 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:16 elm3b39 kernel: GPR24: 0000000000000000 0000000000000001 0000000000000001 c0000000c725f9c8
Jan 23 02:51:16 elm3b39 kernel: GPR28: 0000000000000000 c0000000c725f900 c0000000005c2e68 c0000000cb9acb80
Jan 23 02:51:16 elm3b39 kernel: NIP [c00000000039ec58] .tcp_mark_head_lost+0x128/0x1e0
Jan 23 02:51:16 elm3b39 kernel: LR [c00000000039ecd0] .tcp_mark_head_lost+0x1a0/0x1e0
Jan 23 02:51:16 elm3b39 kernel: Call Trace:
Jan 23 02:51:16 elm3b39 kernel: [c0000000005fef00] [c0000000005c2e68] 0xc0000000005c2e68 (unreliable)
Jan 23 02:51:16 elm3b39 kernel: [c0000000005fefb0] [c0000000003a18a0] .tcp_ack+0x1a70/0x20d0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:16 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:16 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:16 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:16 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:16 elm3b39 kernel: Instruction dump:
Jan 23 02:51:16 elm3b39 kernel: 7fbfd800 419e0010 e81d01d8 7fa0f800 409eff78 801d055c 813d0558 817d046c
Jan 23 02:51:16 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fa3eb78 48010391 60000000
Jan 23 02:51:16 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:16 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1977
Jan 23 02:51:16 elm3b39 kernel: NIP: c0000000003a9628 LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:16 elm3b39 kernel: REGS: c0000000005fec90 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:16 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042024  XER: 00000020
Jan 23 02:51:16 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:16 elm3b39 kernel: GPR00: fffffffffffffffd c0000000005fef10 c0000000005fa880 c0000000c725f900
Jan 23 02:51:16 elm3b39 kernel: GPR04: 0000000000000000 0000000000000003 0000000000000005 0000000000000005
Jan 23 02:51:16 elm3b39 kernel: GPR08: 0000000000000004 0000000000000001 0000000000000005 0000000000000003
Jan 23 02:51:16 elm3b39 kernel: GPR12: 0000000024042022 c000000000556700 0000000000000000 0000000000012773
Jan 23 02:51:16 elm3b39 kernel: GPR16: 0000000000000005 c0000000c725f9c8 0000000074ce5b1e 0000000000000001
Jan 23 02:51:16 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:16 elm3b39 kernel: GPR24: 0000000000000000 0000000024008022 c0000000c725f900 c0000000c725f9c8
Jan 23 02:51:16 elm3b39 kernel: GPR28: 0000000000000000 c0000000c725f900 c0000000005c2ff0 c0000000c756db00
Jan 23 02:51:16 elm3b39 kernel: NIP [c0000000003a9628] .tcp_xmit_retransmit_queue+0x408/0x500
Jan 23 02:51:16 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:17 elm3b39 kernel: Call Trace:
Jan 23 02:51:17 elm3b39 kernel: [c0000000005fef10] [c0000000005fefb0] 0xc0000000005fefb0 (unreliable)
Jan 23 02:51:17 elm3b39 kernel: [c0000000005fefb0] [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:17 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:17 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:17 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:17 elm3b39 kernel: Instruction dump:
Jan 23 02:51:17 elm3b39 kernel: 80bd055c 4bfffeac e80300c8 3b6300c8 3b800000 7fbb0000 419efc4c 7c1f0378
Jan 23 02:51:17 elm3b39 kernel: 4bfffc44 7f8a4840 7d200026 5529effe <0b090000> 7fa3eb78 480059c1 60000000
Jan 23 02:51:17 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:17 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3248
Jan 23 02:51:17 elm3b39 kernel: NIP: c0000000003a0eec LR: c0000000003a155c CTR: c0000000003d8680
Jan 23 02:51:17 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:17 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24042024  XER: 00000020
Jan 23 02:51:17 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:17 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fefb0 c0000000005fa880 c0000000c725f900
Jan 23 02:51:17 elm3b39 kernel: GPR04: 0000000000000005 c00000000060e400 0000000000000005 0000000000000005
Jan 23 02:51:17 elm3b39 kernel: GPR08: 0000000000000004 0000000000000008 0000000000000000 0000000000000005
Jan 23 02:51:17 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012773
Jan 23 02:51:17 elm3b39 kernel: GPR16: 0000000000000005 c0000000c725f9c8 0000000074ce5b1e 0000000000000001
Jan 23 02:51:17 elm3b39 kernel: GPR20: ffffffffffffffff ffffffffffffffff 0000000000000000 0000000000000001
Jan 23 02:51:17 elm3b39 kernel: GPR24: 0000000000000000 0000000024008022 c0000000c725f900 0000000024002028
Jan 23 02:51:17 elm3b39 kernel: GPR28: 0000000000000000 0000000000000005 c0000000005c2e68 0000000000000000
Jan 23 02:51:17 elm3b39 kernel: NIP [c0000000003a0eec] .tcp_ack+0x10bc/0x20d0
Jan 23 02:51:17 elm3b39 kernel: LR [c0000000003a155c] .tcp_ack+0x172c/0x20d0
Jan 23 02:51:17 elm3b39 kernel: Call Trace:
Jan 23 02:51:17 elm3b39 kernel: [c0000000005fefb0] [c0000000003a155c] .tcp_ack+0x172c/0x20d0 (unreliable)
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:17 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:17 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:17 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:18 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:18 elm3b39 kernel: Instruction dump:
Jan 23 02:51:18 elm3b39 kernel: 2fa90000 419e0010 e8be8020 e8050000 f8090028 801a055c 813a0558 817a046c
Jan 23 02:51:18 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7f43d378 4800e0fd 60000000
Jan 23 02:51:18 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:18 elm3b39 kernel: Badness at net/ipv4/tcp_output.c:1467
Jan 23 02:51:18 elm3b39 kernel: NIP: c0000000003a99e0 LR: c0000000003a5d80 CTR: c0000000003d8680
Jan 23 02:51:18 elm3b39 kernel: REGS: c0000000005fed90 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:18 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24002044  XER: 20000020
Jan 23 02:51:18 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:18 elm3b39 kernel: GPR00: 0000000000000001 c0000000005ff010 c0000000005fa880 c0000000c725f900
Jan 23 02:51:18 elm3b39 kernel: GPR04: 00000000000005a8 0000000000000001 0000000000000005 0000000000000005
Jan 23 02:51:18 elm3b39 kernel: GPR08: 0000000000000003 0000000000000008 0000000000000005 c0000000c725f900
Jan 23 02:51:18 elm3b39 kernel: GPR12: 0000000024002022 c000000000556700 000000000000001f d000000000106000
Jan 23 02:51:18 elm3b39 kernel: GPR16: 0000000000001ea0 000000000000000f c0000000ccb95000 c0000000cc198cc0
Jan 23 02:51:18 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:18 elm3b39 kernel: GPR24: 0000000000000001 0000000000000020 0000000000000000 00000000000005a8
Jan 23 02:51:18 elm3b39 kernel: GPR28: c0000000cb699280 c0000000c725f900 c0000000005c2ff0 c0000000c725f900
Jan 23 02:51:18 elm3b39 kernel: NIP [c0000000003a99e0] .__tcp_push_pending_frames+0xa0/0xa20
Jan 23 02:51:18 elm3b39 kernel: LR [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:18 elm3b39 kernel: Call Trace:
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff010] [c0000000003a9b08] .__tcp_push_pending_frames+0x1c8/0xa20 (unreliable)
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d80] .tcp_rcv_established+0x350/0x8f0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:18 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xec/0x1c0
Jan 23 02:51:18 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:18 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:18 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:18 elm3b39 kernel: Instruction dump:
Jan 23 02:51:18 elm3b39 kernel: 419e0484 80030390 2f800000 409e0394 80fd046c 811d055c 815d0558 3b400000
Jan 23 02:51:18 elm3b39 kernel: 7d2a4214 7f893840 7c000026 5400f7fe <0b000000> 7fa3eb78 48005609 60000000
Jan 23 02:51:18 elm3b39 kernel: .do_softirq+0x64/0xa0
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f79d0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7a50] [c0000000000261b4] .timer_interrupt+0x134/0x150
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7ae0] [c000000000003600] decrementer_common+0x100/0x180
Jan 23 02:51:18 elm3b39 kernel: --- Exception: 901 at .ppc64_runlatch_off+0x20/0x60
Jan 23 02:51:18 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7dd0] [0000000000000000] .__start+0x4000000000000000/0x8 (unreliable)
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7e70] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7f00] [c00000000002bd5c] .start_secondary+0x14c/0x190
Jan 23 02:51:18 elm3b39 kernel: [c0000000ce0f7f90] [c000000000008364] .start_secondary_prolog+0xc/0x10
Jan 23 02:51:18 elm3b39 kernel: Instruction dump:
Jan 23 02:51:18 elm3b39 kernel: e92b00a8 7d295214 a1690008 7c0b0050 901f0470 801f055c 813f0558 817f046c
Jan 23 02:51:19 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fe3fb78 4800a6d1 60000000
Jan 23 02:51:19 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 23 02:51:19 elm3b39 kernel: NIP: c0000000003a4918 LR: c0000000003ac640 CTR: c0000000003ac210
Jan 23 02:51:19 elm3b39 kernel: REGS: c0000000ce0f7400 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:19 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 22000024  XER: 20000020
Jan 23 02:51:19 elm3b39 kernel: TASK = c0000000ce0f10e0[0] 'swapper' THREAD: c0000000ce0f4000 CPU: 2
Jan 23 02:51:19 elm3b39 kernel: GPR00: 0000000000000001 c0000000ce0f7680 c0000000005fa880 c0000000c725f900
Jan 23 02:51:19 elm3b39 kernel: GPR04: 0000000000000001 0000000100012758 0000000000000100 c000000000431928
Jan 23 02:51:19 elm3b39 kernel: GPR08: 0000000000000000 0000000000000008 c0000000c756db38 0000000000000005
Jan 23 02:51:19 elm3b39 kernel: GPR12: 0000000042000028 c000000000556c00 0000000000000000 0000000000c00020
Jan 23 02:51:19 elm3b39 kernel: GPR16: 0000000000000002 0000000000000000 0000000000000000 0000000000000000
Jan 23 02:51:19 elm3b39 kernel: GPR20: 0000000000000000 0000000000000000 0000000000000000 c00000000060e400
Jan 23 02:51:19 elm3b39 kernel: GPR24: c0000000ce0f4000 0000000000000000 c0000000c725f9c8 c00000000060e400
Jan 23 02:51:19 elm3b39 kernel: GPR28: 000000000000000f c0000000ce0f7830 c0000000005c2e68 c0000000c725f900
Jan 23 02:51:19 elm3b39 kernel: NIP [c0000000003a4918] .tcp_enter_frto+0x118/0x390
Jan 23 02:51:19 elm3b39 kernel: LR [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:19 elm3b39 kernel: Call Trace:
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7680] [c0000000ce0f7710] 0xc0000000ce0f7710 (unreliable)
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7710] [c0000000003ac640] .tcp_write_timer+0x430/0x810
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f77c0] [c0000000000614f4] .run_timer_softirq+0x1c4/0x2a0
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7890] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7950] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f79d0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7a50] [c0000000000261b4] .timer_interrupt+0x134/0x150
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7ae0] [c000000000003600] decrementer_common+0x100/0x180
Jan 23 02:51:19 elm3b39 kernel: --- Exception: 901 at .ppc64_runlatch_off+0x20/0x60
Jan 23 02:51:19 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7dd0] [0000000000000000] .__start+0x4000000000000000/0x8 (unreliable)
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7e70] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7f00] [c00000000002bd5c] .start_secondary+0x14c/0x190
Jan 23 02:51:19 elm3b39 kernel: [c0000000ce0f7f90] [c000000000008364] <0>------------[ cut here ]------------
Jan 23 02:51:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3184
Jan 23 02:51:19 elm3b39 kernel: NIP: c0000000003a0010 LR: c0000000003a5d54 CTR: c00000000021f110
Jan 23 02:51:19 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:19 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 44004024  XER: 20000020
Jan 23 02:51:19 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:19 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fefb0 c0000000005fa880 c0000000ccd47900
Jan 23 02:51:19 elm3b39 kernel: GPR04: c0000000cb463080 0000000000000001 0000000000000003 000000000000b5a2
Jan 23 02:51:19 elm3b39 kernel: GPR08: 0000000000000005 0000000000000008 0000000000000000 0000000000000001
Jan 23 02:51:19 elm3b39 kernel: GPR12: 0000000024002022 c000000000556700 0000000000000000 d000000000106000
Jan 23 02:51:19 elm3b39 kernel: GPR16: 0000000000000ce0 0000000000000000 000000007439ad1d c0000000cc198cc0
Jan 23 02:51:19 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:19 elm3b39 kernel: GPR24: c0000000cb7dec8e c0000000cb463080 c0000000ccd47900 0000000074399665
Jan 23 02:51:19 elm3b39 kernel: GPR28: 000000008638548c 0000000000000400 c0000000005c2e68 c0000000cb4630b8
Jan 23 02:51:19 elm3b39 kernel: NIP [c0000000003a0010] .tcp_ack+0x1e0/0x20d0
Jan 23 02:51:19 elm3b39 kernel: LR [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:19 elm3b39 kernel: Call Trace:
Jan 23 02:51:19 elm3b39 kernel: [c0000000005fefb0] [c00000000061e980] 0xc00000000061e980 (unreliable)
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:19 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:20 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xf0/0x1c0
Jan 23 02:51:20 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:20 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:20 elm3b39 kernel: Instruction dump:
Jan 23 02:51:20 elm3b39 kernel: 813a046c f92100a0 7d283214 60000000 815a0560 e80100a0 f94100c0 7f890040
Jan 23 02:51:20 elm3b39 kernel: 7c000026 5400f7fe 817a0470 f96100a8 <0b000000> 7f43d378 4800efd9 60000000
Jan 23 02:51:20 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:20 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2855
Jan 23 02:51:20 elm3b39 kernel: NIP: c0000000003a0464 LR: c0000000003a0410 CTR: c00000000021f110
Jan 23 02:51:20 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:20 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24048088  XER: 20000020
Jan 23 02:51:20 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:20 elm3b39 kernel: GPR00: 0000000000000003 c0000000005fefb0 c0000000005fa880 0000000000000001
Jan 23 02:51:20 elm3b39 kernel: GPR04: c0000000cbf94300 0000000000000002 000000007439ad1d 0000000000000000
Jan 23 02:51:20 elm3b39 kernel: GPR08: c000000000556700 0000000000000001 c0000000cbf94080 0000000000000031
Jan 23 02:51:20 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 00000000000127d9
Jan 23 02:51:20 elm3b39 kernel: GPR16: 0000000000000001 c0000000ccd479c8 000000007439ad1d 0000000000000001
Jan 23 02:51:20 elm3b39 kernel: GPR20: 00000000000000b7 00000000000000b6 0000000000000005 000000000000000c
Jan 23 02:51:20 elm3b39 kernel: GPR24: 000000007439ad1d 0000000000000004 c0000000ccd47900 c0000000cbf94338
Jan 23 02:51:20 elm3b39 kernel: GPR28: 0000000000000001 0000000000000005 c0000000005c2e68 c0000000cbb50580
Jan 23 02:51:20 elm3b39 kernel: NIP [c0000000003a0464] .tcp_ack+0x634/0x20d0
Jan 23 02:51:20 elm3b39 kernel: LR [c0000000003a0410] .tcp_ack+0x5e0/0x20d0
Jan 23 02:51:20 elm3b39 kernel: Call Trace:
Jan 23 02:51:20 elm3b39 kernel: [c0000000005fefb0] [c0000000003a0410] .tcp_ack+0x5e0/0x20d0 (unreliable)
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:20 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xf0/0x1c0
Jan 23 02:51:20 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:20 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:20 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:20 elm3b39 kernel: Instruction dump:
Jan 23 02:51:20 elm3b39 kernel: 41920010 e81a01d8 7fbf0000 409efdb0 80fa046c 7eddb378 813a055c 801a0558
Jan 23 02:51:20 elm3b39 kernel: 7c004a14 7f870040 7d200026 5529effe <0b090000> 7f43d378 4800eb85 60000000
Jan 23 02:51:20 elm3b39 kernel: .start_secondary_prolog+0xc/0x10
Jan 23 02:51:20 elm3b39 kernel: Instruction dump:
Jan 23 02:51:20 elm3b39 kernel: e92b00a8 7d295214 a1690008 7c0b0050 901f0470 801f055c 813f0558 817f046c
Jan 23 02:51:20 elm3b39 kernel: 7d290214 7f895840 7c000026 5400f7fe <0b000000> 7fe3fb78 4800a6d1 60000000
Jan 23 02:51:20 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:20 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:3184
Jan 23 02:51:20 elm3b39 kernel: NIP: c0000000003a0010 LR: c0000000003a5d54 CTR: c00000000021f110
Jan 23 02:51:21 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:21 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 44004024  XER: 20000020
Jan 23 02:51:21 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:21 elm3b39 kernel: GPR00: 0000000000000001 c0000000005fefb0 c0000000005fa880 c0000000c725f900
Jan 23 02:51:21 elm3b39 kernel: GPR04: c0000000cb463d80 0000000000000001 0000000000000003 000000000000b5b2
Jan 23 02:51:21 elm3b39 kernel: GPR08: 0000000000000005 0000000000000008 0000000000000000 0000000000000001
Jan 23 02:51:21 elm3b39 kernel: GPR12: 0000000024002022 c000000000556700 0000000000000000 d000000000106000
Jan 23 02:51:21 elm3b39 kernel: GPR16: 0000000000001ba0 0000000000000000 0000000074ce71d6 c0000000cc198cc0
Jan 23 02:51:21 elm3b39 kernel: GPR20: c0000000ccb95700 c0000000ce176800 c00000000061e980 c00000000061fdd8
Jan 23 02:51:21 elm3b39 kernel: GPR24: c0000000c7687c8e c0000000cb463d80 c0000000c725f900 0000000074ce5b1e
Jan 23 02:51:21 elm3b39 kernel: GPR28: 00000000868ec881 0000000000000400 c0000000005c2e68 c0000000cb463db8
Jan 23 02:51:21 elm3b39 kernel: NIP [c0000000003a0010] .tcp_ack+0x1e0/0x20d0
Jan 23 02:51:21 elm3b39 kernel: LR [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:21 elm3b39 kernel: Call Trace:
Jan 23 02:51:21 elm3b39 kernel: [c0000000005fefb0] [c00000000061e980] 0xc00000000061e980 (unreliable)
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:21 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xf0/0x1c0
Jan 23 02:51:21 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:21 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:21 elm3b39 kernel: Instruction dump:
Jan 23 02:51:21 elm3b39 kernel: 813a046c f92100a0 7d283214 60000000 815a0560 e80100a0 f94100c0 7f890040
Jan 23 02:51:21 elm3b39 kernel: 7c000026 5400f7fe 817a0470 f96100a8 <0b000000> 7f43d378 4800efd9 60000000
Jan 23 02:51:21 elm3b39 kernel: ------------[ cut here ]------------
Jan 23 02:51:21 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2855
Jan 23 02:51:21 elm3b39 kernel: NIP: c0000000003a0464 LR: c0000000003a0410 CTR: c00000000021f110
Jan 23 02:51:21 elm3b39 kernel: REGS: c0000000005fed30 TRAP: 0700   Not tainted  (2.6.24-rc7)
Jan 23 02:51:21 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24048088  XER: 20000020
Jan 23 02:51:21 elm3b39 kernel: TASK = c000000000555e50[0] 'swapper' THREAD: c0000000005fc000 CPU: 0
Jan 23 02:51:21 elm3b39 kernel: GPR00: 0000000000000003 c0000000005fefb0 c0000000005fa880 0000000000000001
Jan 23 02:51:21 elm3b39 kernel: GPR04: c0000000cb8e7100 0000000000000002 0000000074ce71d6 0000000000000000
Jan 23 02:51:21 elm3b39 kernel: GPR08: c000000000556700 0000000000000001 c0000000cb8e7080 000000000000002b
Jan 23 02:51:21 elm3b39 kernel: GPR12: 0000000000000000 c000000000556700 0000000000000000 0000000000012801
Jan 23 02:51:21 elm3b39 kernel: GPR16: 0000000000000001 c0000000c725f9c8 0000000074ce71d6 0000000000000001
Jan 23 02:51:21 elm3b39 kernel: GPR20: 00000000000000df 0000000000000090 0000000000000005 000000000000000c
Jan 23 02:51:21 elm3b39 kernel: GPR24: 0000000074ce71d6 0000000000000004 c0000000c725f900 c0000000cb8e7138
Jan 23 02:51:21 elm3b39 kernel: GPR28: 0000000000000001 0000000000000005 c0000000005c2e68 c0000000cb9acb80
Jan 23 02:51:21 elm3b39 kernel: NIP [c0000000003a0464] .tcp_ack+0x634/0x20d0
Jan 23 02:51:21 elm3b39 kernel: LR [c0000000003a0410] .tcp_ack+0x5e0/0x20d0
Jan 23 02:51:21 elm3b39 kernel: Call Trace:
Jan 23 02:51:21 elm3b39 kernel: [c0000000005fefb0] [c0000000003a0410] .tcp_ack+0x5e0/0x20d0 (unreliable)
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff110] [c0000000003a5d54] .tcp_rcv_established+0x324/0x8f0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff1c0] [c0000000003ae204] .tcp_v4_do_rcv+0x134/0x2a0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff280] [c0000000003b0c48] .tcp_v4_rcv+0x8a8/0x8d0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff340] [c00000000038a870] .ip_local_deliver+0xf0/0x2d0
Jan 23 02:51:21 elm3b39 kernel: [c0000000005ff3d0] [c00000000038ad84] .ip_rcv+0x334/0x6d0
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff4a0] [c000000000359e7c] .netif_receive_skb+0x32c/0x630
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff580] [d00000000020d540] .e1000_clean_rx_irq+0x250/0x6c0 [e1000]
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff690] [d0000000002086c4] .e1000_clean+0x74/0x310 [e1000]
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff740] [c00000000035d670] .net_rx_action+0x1f0/0x300
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff800] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff8c0] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff940] [c00000000005b134] .irq_exit+0x74/0x90
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ff9c0] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ffa40] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 23 02:51:22 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xf0/0x1c0
Jan 23 02:51:22 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ffd30] [000000000211e3d8] 0x211e3d8 (unreliable)
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ffdd0] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ffe60] [c000000000009b08] .rest_init+0x78/0x90
Jan 23 02:51:22 elm3b39 kernel: [c0000000005ffee0] [c0000000004e8a24] .start_kernel+0x354/0x400
Jan 23 02:51:22 elm3b39 kernel: [c0000000005fff90] [c000000000008524] .start_here_common+0x54/0xb0
Jan 23 02:51:22 elm3b39 kernel: Instruction dump:
Jan 23 02:51:22 elm3b39 kernel: 41920010 e81a01d8 7fbf0000 409efdb0 80fa046c 7eddb378 813a055c 801a0558
Jan 23 02:51:22 elm3b39 kernel: 7c004a14 7f870040 7d200026 5529effe <0b090000> 7f43d378 4800eb85 60000000

