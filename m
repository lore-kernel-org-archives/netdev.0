From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Thu, 24 Jul 2008 08:39:48 +0200
Message-ID: <BAY103-DAV1DBA31C9BCB4C6FFB3DE0B2870@phx.gbl>
Cc: <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s17.bay0.hotmail.com ([65.54.246.153]:30051 "EHLO
	bay0-omc2-s17.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbYGXGlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 02:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc'ed netdev maybe this is a networking problem]

I got another error at the same time on another
system. These two boxes implement an ipsec tunnel.


Jul 23 12:40:02 Electra kernel: crond: page allocation failure. order:5,
mode:0x4020
Jul 23 12:40:02 Electra kernel: Pid: 586, comm: crond Not tainted 2.6.26
#1
Jul 23 12:40:02 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 12:40:02 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 12:40:02 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 12:40:03 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 12:40:03 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 12:40:03 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 12:40:03 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 12:40:03 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 12:40:03 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 12:40:03 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 12:40:03 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 12:40:03 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 12:40:03 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 12:40:03 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 12:40:03 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 12:40:03 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 12:40:03 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 12:40:03 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 12:40:03 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 12:40:03 Electra kernel:  [<c015007b>] shift_arg_pages+0x22/0x128
Jul 23 12:40:03 Electra kernel:  [<c015287d>]
exec_permission_lite+0x8/0xb3
Jul 23 12:40:03 Electra kernel:  [<c0152c83>]
__link_path_walk+0x51/0xa0e
Jul 23 12:40:03 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 12:40:03 Electra kernel:  [<d08a5d96>]
boomerang_interrupt+0xd4/0x3cf [3c59x]
Jul 23 12:40:03 Electra kernel:  [<c0252d7d>] net_tx_action+0x35/0xab
Jul 23 12:40:03 Electra kernel:  [<c0153674>] path_walk+0x34/0x6e
Jul 23 12:40:03 Electra kernel:  [<c0153880>] do_path_lookup+0xc1/0x124
Jul 23 12:40:03 Electra kernel:  [<c0153967>]
__path_lookup_intent_open+0x3f/0x71
Jul 23 12:40:03 Electra kernel:  [<c01539a8>] path_lookup_open+0xf/0x13
Jul 23 12:40:03 Electra kernel:  [<c0154116>] do_filp_open+0xa0/0x5d2
Jul 23 12:40:03 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 12:40:03 Electra kernel:  [<c0110921>]
dequeue_task_fair+0x12/0x14
Jul 23 12:40:03 Electra kernel:  [<c01247fa>] hrtimer_cancel+0xa/0x14
Jul 23 12:40:03 Electra kernel:  [<c02b83e9>] do_nanosleep+0x4c/0x79
Jul 23 12:40:03 Electra kernel:  [<c014c759>] do_sys_open+0x3e/0xb5
Jul 23 12:40:03 Electra kernel:  [<c014c7ee>] sys_open+0x1e/0x23
Jul 23 12:40:03 Electra kernel:  [<c0102afe>] syscall_call+0x7/0xb
Jul 23 12:40:03 Electra kernel:  [<c02b0000>] packet_mmap+0x2a/0xf1
Jul 23 12:40:03 Electra kernel:  =======================
Jul 23 12:40:03 Electra kernel: DMA per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 12:40:03 Electra kernel: Normal per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  76
Jul 23 12:40:03 Electra kernel: Active:25973 inactive:26106 dirty:254
writeback:0 unstable:0
Jul 23 12:40:03 Electra kernel:  free:567 slab:10544 mapped:911
pagetables:136 bounce:0
Jul 23 12:40:03 Electra kernel: DMA free:1104kB min:124kB low:152kB
high:184kB active:4608kB inactive:4924kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 12:40:03 Electra kernel: Normal free:1164kB min:1908kB low:2384kB
high:2860kB active:99284kB inactive:99500kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 12:40:03 Electra kernel: DMA: 8*4kB 0*8kB 1*16kB 1*32kB 0*64kB
0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1104kB
Jul 23 12:40:03 Electra kernel: Normal: 185*4kB 15*8kB 1*16kB 1*32kB
0*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1164kB
Jul 23 12:40:03 Electra kernel: 36991 total pagecache pages
Jul 23 12:40:03 Electra kernel: Swap cache: add 91, delete 37, find
27/34
Jul 23 12:40:03 Electra kernel: Free swap  = 209408kB
Jul 23 12:40:03 Electra kernel: Total swap = 209624kB
Jul 23 12:40:03 Electra kernel: crond: page allocation failure. order:5,
mode:0x4020
Jul 23 12:40:03 Electra kernel: Pid: 586, comm: crond Not tainted 2.6.26
#1
Jul 23 12:40:03 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 12:40:03 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 12:40:03 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 12:40:03 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 12:40:03 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 12:40:03 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 12:40:03 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 12:40:03 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 12:40:03 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 12:40:03 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 12:40:03 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 12:40:03 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 12:40:03 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 12:40:03 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 12:40:03 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 12:40:03 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 12:40:03 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 12:40:03 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 12:40:03 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 12:40:03 Electra kernel:  [<c015007b>] shift_arg_pages+0x22/0x128
Jul 23 12:40:03 Electra kernel:  [<c015287d>]
exec_permission_lite+0x8/0xb3
Jul 23 12:40:03 Electra kernel:  [<c0152c83>]
__link_path_walk+0x51/0xa0e
Jul 23 12:40:03 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 12:40:03 Electra kernel:  [<d08a5d96>]
boomerang_interrupt+0xd4/0x3cf [3c59x]
Jul 23 12:40:03 Electra kernel:  [<c0252d7d>] net_tx_action+0x35/0xab
Jul 23 12:40:03 Electra kernel:  [<c0153674>] path_walk+0x34/0x6e
Jul 23 12:40:03 Electra kernel:  [<c0153880>] do_path_lookup+0xc1/0x124
Jul 23 12:40:03 Electra kernel:  [<c0153967>]
__path_lookup_intent_open+0x3f/0x71
Jul 23 12:40:03 Electra kernel:  [<c01539a8>] path_lookup_open+0xf/0x13
Jul 23 12:40:03 Electra kernel:  [<c0154116>] do_filp_open+0xa0/0x5d2
Jul 23 12:40:03 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 12:40:03 Electra kernel:  [<c0110921>]
dequeue_task_fair+0x12/0x14
Jul 23 12:40:03 Electra kernel:  [<c01247fa>] hrtimer_cancel+0xa/0x14
Jul 23 12:40:03 Electra kernel:  [<c02b83e9>] do_nanosleep+0x4c/0x79
Jul 23 12:40:03 Electra kernel:  [<c014c759>] do_sys_open+0x3e/0xb5
Jul 23 12:40:03 Electra kernel:  [<c014c7ee>] sys_open+0x1e/0x23
Jul 23 12:40:03 Electra kernel:  [<c0102afe>] syscall_call+0x7/0xb
Jul 23 12:40:03 Electra kernel:  [<c02b0000>] packet_mmap+0x2a/0xf1
Jul 23 12:40:03 Electra kernel:  =======================
Jul 23 12:40:03 Electra kernel: DMA per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 12:40:03 Electra kernel: Normal per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  75
Jul 23 12:40:03 Electra kernel: Active:25973 inactive:26106 dirty:254
writeback:0 unstable:0
Jul 23 12:40:03 Electra kernel:  free:555 slab:10557 mapped:911
pagetables:136 bounce:0
Jul 23 12:40:03 Electra kernel: DMA free:1104kB min:124kB low:152kB
high:184kB active:4608kB inactive:4924kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 12:40:03 Electra kernel: Normal free:1116kB min:1908kB low:2384kB
high:2860kB active:99284kB inactive:99500kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 12:40:03 Electra kernel: DMA: 8*4kB 0*8kB 1*16kB 1*32kB 0*64kB
0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1104kB
Jul 23 12:40:03 Electra kernel: Normal: 185*4kB 15*8kB 0*16kB 0*32kB
0*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1116kB
Jul 23 12:40:03 Electra kernel: 36991 total pagecache pages
Jul 23 12:40:03 Electra kernel: Swap cache: add 91, delete 37, find
27/34
Jul 23 12:40:03 Electra kernel: Free swap  = 209408kB
Jul 23 12:40:03 Electra kernel: Total swap = 209624kB
Jul 23 12:40:03 Electra kernel: klogd: page allocation failure. order:5,
mode:0x4020
Jul 23 12:40:03 Electra kernel: Pid: 390, comm: klogd Not tainted 2.6.26
#1
Jul 23 12:40:03 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 12:40:03 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 12:40:03 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 12:40:03 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 12:40:03 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 12:40:03 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 12:40:03 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 12:40:03 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 12:40:03 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 12:40:03 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 12:40:03 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 12:40:03 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 12:40:03 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 12:40:03 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 12:40:03 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 12:40:03 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 12:40:03 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 12:40:03 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 12:40:03 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 12:40:03 Electra kernel:  [<c02b0000>] packet_mmap+0x2a/0xf1
Jul 23 12:40:03 Electra kernel:  =======================
Jul 23 12:40:03 Electra kernel: DMA per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 12:40:03 Electra kernel: Normal per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  74
Jul 23 12:40:03 Electra kernel: Active:25973 inactive:26106 dirty:254
writeback:0 unstable:0
Jul 23 12:40:03 Electra kernel:  free:559 slab:10554 mapped:911
pagetables:136 bounce:0
Jul 23 12:40:03 Electra kernel: DMA free:1104kB min:124kB low:152kB
high:184kB active:4608kB inactive:4924kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 12:40:03 Electra kernel: Normal free:1132kB min:1908kB low:2384kB
high:2860kB active:99284kB inactive:99500kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 12:40:03 Electra kernel: DMA: 8*4kB 0*8kB 1*16kB 1*32kB 0*64kB
0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1104kB
Jul 23 12:40:03 Electra kernel: Normal: 185*4kB 15*8kB 3*16kB 1*32kB
1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1132kB
Jul 23 12:40:03 Electra kernel: 36991 total pagecache pages
Jul 23 12:40:03 Electra kernel: Swap cache: add 91, delete 37, find
27/34
Jul 23 12:40:03 Electra kernel: Free swap  = 209408kB
Jul 23 12:40:03 Electra kernel: Total swap = 209624kB
Jul 23 12:40:03 Electra kernel: klogd: page allocation failure. order:5,
mode:0x4020
Jul 23 12:40:03 Electra kernel: Pid: 390, comm: klogd Not tainted 2.6.26
#1
Jul 23 12:40:03 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 12:40:03 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 12:40:03 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 12:40:03 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 12:40:03 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 12:40:03 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 12:40:03 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 12:40:03 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 12:40:03 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 12:40:03 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 12:40:03 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 12:40:03 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 12:40:03 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 12:40:03 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 12:40:03 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 12:40:03 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 12:40:03 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 12:40:03 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 12:40:03 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 12:40:03 Electra kernel:  [<c02b0000>] packet_mmap+0x2a/0xf1
Jul 23 12:40:03 Electra kernel:  =======================
Jul 23 12:40:03 Electra kernel: DMA per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 12:40:03 Electra kernel: Normal per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  70
Jul 23 12:40:03 Electra kernel: Active:25973 inactive:26106 dirty:254
writeback:0 unstable:0
Jul 23 12:40:03 Electra kernel:  free:567 slab:10614 mapped:911
pagetables:136 bounce:0
Jul 23 12:40:03 Electra kernel: DMA free:1072kB min:124kB low:152kB
high:184kB active:4608kB inactive:4924kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 12:40:03 Electra kernel: Normal free:1196kB min:1908kB low:2384kB
high:2860kB active:99284kB inactive:99500kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 12:40:03 Electra kernel: DMA: 8*4kB 0*8kB 1*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1072kB
Jul 23 12:40:03 Electra kernel: Normal: 185*4kB 15*8kB 1*16kB 0*32kB
1*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1196kB
Jul 23 12:40:03 Electra kernel: 36991 total pagecache pages
Jul 23 12:40:03 Electra kernel: Swap cache: add 91, delete 37, find
27/34
Jul 23 12:40:03 Electra kernel: Free swap  = 209408kB
Jul 23 12:40:03 Electra kernel: Total swap = 209624kB
Jul 23 12:40:03 Electra kernel: ksoftirqd/0: page allocation failure.
order:5, mode:0x4020
Jul 23 12:40:03 Electra kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
2.6.26 #1
Jul 23 12:40:03 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 12:40:03 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 12:40:03 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 12:40:03 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 12:40:03 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 12:40:03 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 12:40:03 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 12:40:03 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 12:40:03 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 12:40:03 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 12:40:03 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 12:40:03 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 12:40:03 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 12:40:03 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 12:40:03 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 12:40:03 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 12:40:03 Electra kernel:  [<c0118379>] ksoftirqd+0x0/0x94
Jul 23 12:40:03 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 12:40:03 Electra kernel:  [<c01183b6>] ksoftirqd+0x3d/0x94
Jul 23 12:40:03 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 12:40:03 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 12:40:03 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 12:40:03 Electra kernel:  =======================
Jul 23 12:40:03 Electra kernel: DMA per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 12:40:03 Electra kernel: Normal per-cpu:
Jul 23 12:40:03 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  88
Jul 23 12:40:03 Electra kernel: Active:25933 inactive:26088 dirty:254
writeback:0 unstable:0
Jul 23 12:40:03 Electra kernel:  free:592 slab:10603 mapped:911
pagetables:136 bounce:0
Jul 23 12:40:03 Electra kernel: DMA free:1072kB min:124kB low:152kB
high:184kB active:4608kB inactive:4924kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 12:40:03 Electra kernel: Normal free:1296kB min:1908kB low:2384kB
high:2860kB active:99124kB inactive:99428kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 12:40:03 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 12:40:03 Electra kernel: DMA: 8*4kB 0*8kB 1*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1072kB
Jul 23 12:40:03 Electra kernel: Normal: 226*4kB 17*8kB 2*16kB 1*32kB
1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1296kB
Jul 23 12:40:03 Electra kernel: 36927 total pagecache pages
Jul 23 12:40:03 Electra kernel: Swap cache: add 91, delete 37, find
27/34
Jul 23 12:40:03 Electra kernel: Free swap  = 209408kB
Jul 23 12:40:03 Electra kernel: Total swap = 209624kB
Jul 23 13:31:58 Electra kernel:  [<c0272561>]
ip_forward_finish+0x19/0x24
Jul 23 13:31:58 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 13:31:58 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:58 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:58 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:58 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:58 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:58 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:58 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:58 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:58 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:58 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:58 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:58 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:58 Electra kernel:  [<c01c0000>] xfs_trans_binval+0x40/0x7f
Jul 23 13:31:58 Electra kernel:  [<c01aa2a8>] xfs_iunlock+0x41/0x75
Jul 23 13:31:58 Electra kernel:  [<c01c7a93>]
xfs_end_bio_delalloc+0xd/0x15
Jul 23 13:31:58 Electra kernel:  [<c011fbff>] run_workqueue+0x48/0xd6
Jul 23 13:31:58 Electra kernel:  [<c011fd14>] worker_thread+0x87/0x9a
Jul 23 13:31:58 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 13:31:58 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:58 Electra kernel:  [<c011083e>] set_next_entity+0x42/0x44
Jul 23 13:31:58 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:58 Electra kernel:  [<c02b799e>]
__sched_text_start+0x11e/0x1a9
Jul 23 13:31:58 Electra kernel:  [<c011fc8d>] worker_thread+0x0/0x9a
Jul 23 13:31:58 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:31:58 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:31:58 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  87
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:407
writeback:99 unstable:0
Jul 23 13:31:59 Electra kernel:  free:430 slab:9506 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:720kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 0*16kB 0*32kB
0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 720kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: xfsdatad/0: page allocation failure.
order:0, mode:0x20
Jul 23 13:31:59 Electra kernel: Pid: 121, comm: xfsdatad/0 Not tainted
2.6.26 #1
Jul 23 13:31:59 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:31:59 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:31:59 Electra kernel:  [<c0148ee7>] allocate_slab+0x93/0x9d
Jul 23 13:31:59 Electra kernel:  [<c0148f2d>] new_slab+0x1f/0x118
Jul 23 13:31:59 Electra kernel:  [<c0149382>] __slab_alloc+0xbe/0xe9
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c0149419>] kmem_cache_alloc+0x6c/0x72
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cc41>] dev_alloc_skb+0x11/0x25
Jul 23 13:31:59 Electra kernel:  [<d08a64dd>] boomerang_rx+0x14b/0x4bc
[3c59x]
Jul 23 13:31:59 Electra kernel:  [<c0136238>] show_free_areas+0xd8/0x218
Jul 23 13:31:59 Electra kernel:  [<d08a6015>]
boomerang_interrupt+0x353/0x3cf [3c59x]
Jul 23 13:31:59 Electra kernel:  [<c01261fe>] getnstimeofday+0x39/0x120
Jul 23 13:31:59 Electra kernel:  [<c012f95b>] handle_IRQ_event+0x1a/0x43
Jul 23 13:31:59 Electra kernel:  [<c01304e5>] handle_level_irq+0x51/0x9f
Jul 23 13:31:59 Electra kernel:  [<c0104a5c>] do_IRQ+0x32/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c012007b>]
__create_workqueue_key+0x35/0xfb
Jul 23 13:31:59 Electra kernel:  [<c012f957>] handle_IRQ_event+0x16/0x43
Jul 23 13:31:59 Electra kernel:  [<c01304e5>] handle_level_irq+0x51/0x9f
Jul 23 13:31:59 Electra kernel:  [<c0104a5c>] do_IRQ+0x32/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c014a41d>]
__kmalloc_track_caller+0x41/0xa4
Jul 23 13:31:59 Electra kernel:  [<c024cb4f>] __alloc_skb+0x47/0xfb
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c0275b7d>]
ip_finish_output2+0x0/0x19b
Jul 23 13:31:59 Electra kernel:  [<c0273da8>] ip_output+0x66/0x8d
Jul 23 13:31:59 Electra kernel:  [<c0272561>]
ip_forward_finish+0x19/0x24
Jul 23 13:31:59 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 13:31:59 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:59 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:59 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:59 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:59 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:59 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:59 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:59 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c01c0000>] xfs_trans_binval+0x40/0x7f
Jul 23 13:31:59 Electra kernel:  [<c01aa2a8>] xfs_iunlock+0x41/0x75
Jul 23 13:31:59 Electra kernel:  [<c01c7a93>]
xfs_end_bio_delalloc+0xd/0x15
Jul 23 13:31:59 Electra kernel:  [<c011fbff>] run_workqueue+0x48/0xd6
Jul 23 13:31:59 Electra kernel:  [<c011fd14>] worker_thread+0x87/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c011083e>] set_next_entity+0x42/0x44
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c02b799e>]
__sched_text_start+0x11e/0x1a9
Jul 23 13:31:59 Electra kernel:  [<c011fc8d>] worker_thread+0x0/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:31:59 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:31:59 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  87
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:407
writeback:99 unstable:0
Jul 23 13:31:59 Electra kernel:  free:430 slab:9506 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:720kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 0*16kB 0*32kB
0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 720kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: eth2: memory shortage
Jul 23 13:31:59 Electra kernel: xfsdatad/0: page allocation failure.
order:0, mode:0x20
Jul 23 13:31:59 Electra kernel: Pid: 121, comm: xfsdatad/0 Not tainted
2.6.26 #1
Jul 23 13:31:59 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:31:59 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:31:59 Electra kernel:  [<c0148ee7>] allocate_slab+0x93/0x9d
Jul 23 13:31:59 Electra kernel:  [<c0148f2d>] new_slab+0x1f/0x118
Jul 23 13:31:59 Electra kernel:  [<c0149382>] __slab_alloc+0xbe/0xe9
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c0149419>] kmem_cache_alloc+0x6c/0x72
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cc41>] dev_alloc_skb+0x11/0x25
Jul 23 13:31:59 Electra kernel:  [<d08a64dd>] boomerang_rx+0x14b/0x4bc
[3c59x]
Jul 23 13:31:59 Electra kernel:  [<c0136238>] show_free_areas+0xd8/0x218
Jul 23 13:31:59 Electra kernel:  [<d08a6015>]
boomerang_interrupt+0x353/0x3cf [3c59x]
Jul 23 13:31:59 Electra kernel:  [<c012f95b>] handle_IRQ_event+0x1a/0x43
Jul 23 13:31:59 Electra kernel:  [<c01304e5>] handle_level_irq+0x51/0x9f
Jul 23 13:31:59 Electra kernel:  [<c0104a5c>] do_IRQ+0x32/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c012007b>]
__create_workqueue_key+0x35/0xfb
Jul 23 13:31:59 Electra kernel:  [<c012f957>] handle_IRQ_event+0x16/0x43
Jul 23 13:31:59 Electra kernel:  [<c01304e5>] handle_level_irq+0x51/0x9f
Jul 23 13:31:59 Electra kernel:  [<c0104a5c>] do_IRQ+0x32/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c014a41d>]
__kmalloc_track_caller+0x41/0xa4
Jul 23 13:31:59 Electra kernel:  [<c024cb4f>] __alloc_skb+0x47/0xfb
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c0275b7d>]
ip_finish_output2+0x0/0x19b
Jul 23 13:31:59 Electra kernel:  [<c0273da8>] ip_output+0x66/0x8d
Jul 23 13:31:59 Electra kernel:  [<c0272561>]
ip_forward_finish+0x19/0x24
Jul 23 13:31:59 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 13:31:59 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:59 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:59 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:59 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:59 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:59 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:59 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:59 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c01c0000>] xfs_trans_binval+0x40/0x7f
Jul 23 13:31:59 Electra kernel:  [<c01aa2a8>] xfs_iunlock+0x41/0x75
Jul 23 13:31:59 Electra kernel:  [<c01c7a93>]
xfs_end_bio_delalloc+0xd/0x15
Jul 23 13:31:59 Electra kernel:  [<c011fbff>] run_workqueue+0x48/0xd6
Jul 23 13:31:59 Electra kernel:  [<c011fd14>] worker_thread+0x87/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c011083e>] set_next_entity+0x42/0x44
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c02b799e>]
__sched_text_start+0x11e/0x1a9
Jul 23 13:31:59 Electra kernel:  [<c011fc8d>] worker_thread+0x0/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:31:59 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:31:59 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  87
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:407
writeback:99 unstable:0
Jul 23 13:31:59 Electra kernel:  free:430 slab:9506 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:720kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 0*16kB 0*32kB
0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 720kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: xfsdatad/0: page allocation failure.
order:0, mode:0x20
Jul 23 13:31:59 Electra kernel: Pid: 121, comm: xfsdatad/0 Not tainted
2.6.26 #1
Jul 23 13:31:59 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:31:59 Electra kernel:  [<c0148ee7>] allocate_slab+0x93/0x9d
Jul 23 13:31:59 Electra kernel:  [<c0148f2d>] new_slab+0x1f/0x118
Jul 23 13:31:59 Electra kernel:  [<c0149382>] __slab_alloc+0xbe/0xe9
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c0149419>] kmem_cache_alloc+0x6c/0x72
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cb2e>] __alloc_skb+0x26/0xfb
Jul 23 13:31:59 Electra kernel:  [<c024cc41>] dev_alloc_skb+0x11/0x25
Jul 23 13:31:59 Electra kernel:  [<d08a64dd>] boomerang_rx+0x14b/0x4bc
[3c59x]
Jul 23 13:31:59 Electra kernel:  [<c012f95b>] handle_IRQ_event+0x1a/0x43
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<d08a6015>]
boomerang_interrupt+0x353/0x3cf [3c59x]
Jul 23 13:31:59 Electra kernel:  [<c012f95b>] handle_IRQ_event+0x1a/0x43
Jul 23 13:31:59 Electra kernel:  [<c01304e5>] handle_level_irq+0x51/0x9f
Jul 23 13:31:59 Electra kernel:  [<c0104a5c>] do_IRQ+0x32/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c014a41d>]
__kmalloc_track_caller+0x41/0xa4
Jul 23 13:31:59 Electra kernel:  [<c024cb4f>] __alloc_skb+0x47/0xfb
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c0275b7d>]
ip_finish_output2+0x0/0x19b
Jul 23 13:31:59 Electra kernel:  [<c0273da8>] ip_output+0x66/0x8d
Jul 23 13:31:59 Electra kernel:  [<c0272561>]
ip_forward_finish+0x19/0x24
Jul 23 13:31:59 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 13:31:59 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:59 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:59 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:59 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:59 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:59 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:59 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:59 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c01c0000>] xfs_trans_binval+0x40/0x7f
Jul 23 13:31:59 Electra kernel:  [<c01aa2a8>] xfs_iunlock+0x41/0x75
Jul 23 13:31:59 Electra kernel:  [<c01c7a93>]
xfs_end_bio_delalloc+0xd/0x15
Jul 23 13:31:59 Electra kernel:  [<c011fbff>] run_workqueue+0x48/0xd6
Jul 23 13:31:59 Electra kernel:  [<c011fd14>] worker_thread+0x87/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c011083e>] set_next_entity+0x42/0x44
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c02b799e>]
__sched_text_start+0x11e/0x1a9
Jul 23 13:31:59 Electra kernel:  [<c011fc8d>] worker_thread+0x0/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:31:59 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:31:59 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  87
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:407
writeback:99 unstable:0
Jul 23 13:31:59 Electra kernel:  free:430 slab:9506 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:720kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 0*16kB 0*32kB
0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 720kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: xfsdatad/0: page allocation failure.
order:0, mode:0x4020
Jul 23 13:31:59 Electra kernel: Pid: 121, comm: xfsdatad/0 Not tainted
2.6.26 #1
Jul 23 13:31:59 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:31:59 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:31:59 Electra kernel:  [<c0148ee7>] allocate_slab+0x93/0x9d
Jul 23 13:31:59 Electra kernel:  [<c0148f2d>] new_slab+0x1f/0x118
Jul 23 13:31:59 Electra kernel:  [<c0149382>] __slab_alloc+0xbe/0xe9
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c014a45d>]
__kmalloc_track_caller+0x81/0xa4
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c024cb4f>] __alloc_skb+0x47/0xfb
Jul 23 13:31:59 Electra kernel:  [<c02745b4>] ip_fragment+0x412/0x677
Jul 23 13:31:59 Electra kernel:  [<c0275b7d>]
ip_finish_output2+0x0/0x19b
Jul 23 13:31:59 Electra kernel:  [<c0273da8>] ip_output+0x66/0x8d
Jul 23 13:31:59 Electra kernel:  [<c0272561>]
ip_forward_finish+0x19/0x24
Jul 23 13:31:59 Electra kernel:  [<c027276e>] ip_forward+0x202/0x2e4
Jul 23 13:31:59 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:59 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:59 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:59 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:59 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:59 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:59 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:59 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c01c7a86>]
xfs_end_bio_delalloc+0x0/0x15
Jul 23 13:31:59 Electra kernel:  [<c01c0000>] xfs_trans_binval+0x40/0x7f
Jul 23 13:31:59 Electra kernel:  [<c01aa2a8>] xfs_iunlock+0x41/0x75
Jul 23 13:31:59 Electra kernel:  [<c01c7a93>]
xfs_end_bio_delalloc+0xd/0x15
Jul 23 13:31:59 Electra kernel:  [<c011fbff>] run_workqueue+0x48/0xd6
Jul 23 13:31:59 Electra kernel:  [<c011fd14>] worker_thread+0x87/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0112716>] context_switch+0xb0/0x15a
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c011083e>] set_next_entity+0x42/0x44
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c02b799e>]
__sched_text_start+0x11e/0x1a9
Jul 23 13:31:59 Electra kernel:  [<c011fc8d>] worker_thread+0x0/0x9a
Jul 23 13:31:59 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:31:59 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:31:59 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  87
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:407
writeback:99 unstable:0
Jul 23 13:31:59 Electra kernel:  free:430 slab:9506 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:720kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 0*16kB 0*32kB
0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 720kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: syslogd: page allocation failure.
order:5, mode:0x4020
Jul 23 13:31:59 Electra kernel: Pid: 387, comm: syslogd Not tainted
2.6.26 #1
Jul 23 13:31:59 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:31:59 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:31:59 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 13:31:59 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 13:31:59 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 13:31:59 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 13:31:59 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 13:31:59 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 13:31:59 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 13:31:59 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 13:31:59 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 13:31:59 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:31:59 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:31:59 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:31:59 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:31:59 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:31:59 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:31:59 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:31:59 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:31:59 Electra kernel:  [<c0104a61>] do_IRQ+0x37/0x5d
Jul 23 13:31:59 Electra kernel:  [<c0103487>] common_interrupt+0x23/0x28
Jul 23 13:31:59 Electra kernel:  [<c014d331>]
do_sync_readv_writev+0x82/0xfa
Jul 23 13:31:59 Electra kernel:  [<c01223c7>]
autoremove_wake_function+0x0/0x2d
Jul 23 13:31:59 Electra kernel:  [<c01027fc>] handle_signal+0xb6/0x12e
Jul 23 13:31:59 Electra kernel:  [<c01ef89c>] copy_from_user+0x31/0x51
Jul 23 13:31:59 Electra kernel:  [<c014d453>]
rw_copy_check_uvector+0x60/0xbc
Jul 23 13:31:59 Electra kernel:  [<c014d5cf>]
do_readv_writev+0x120/0x150
Jul 23 13:31:59 Electra kernel:  [<c01cb072>]
xfs_file_aio_write+0x0/0x64
Jul 23 13:31:59 Electra kernel:  [<c014d690>] vfs_writev+0x47/0x4d
Jul 23 13:31:59 Electra kernel:  [<c014d736>] sys_writev+0x3c/0x64
Jul 23 13:31:59 Electra kernel:  [<c0102afe>] syscall_call+0x7/0xb
Jul 23 13:31:59 Electra kernel:  =======================
Jul 23 13:31:59 Electra kernel: DMA per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:31:59 Electra kernel: Normal per-cpu:
Jul 23 13:31:59 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  89
Jul 23 13:31:59 Electra kernel: Active:25295 inactive:27894 dirty:409
writeback:0 unstable:0
Jul 23 13:31:59 Electra kernel:  free:434 slab:9500 mapped:910
pagetables:136 bounce:0
Jul 23 13:31:59 Electra kernel: DMA free:1000kB min:124kB low:152kB
high:184kB active:4304kB inactive:5188kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:31:59 Electra kernel: Normal free:736kB min:1908kB low:2384kB
high:2860kB active:96876kB inactive:106388kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:31:59 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:31:59 Electra kernel: DMA: 50*4kB 4*8kB 0*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1000kB
Jul 23 13:31:59 Electra kernel: Normal: 58*4kB 13*8kB 1*16kB 2*32kB
1*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 736kB
Jul 23 13:31:59 Electra kernel: 38298 total pagecache pages
Jul 23 13:31:59 Electra kernel: Swap cache: add 352, delete 149, find
91/113
Jul 23 13:31:59 Electra kernel: Free swap  = 208728kB
Jul 23 13:31:59 Electra kernel: Total swap = 209624kB
Jul 23 13:31:59 Electra kernel: Clocksource tsc unstable (delta =
252005251 ns)
Jul 23 13:32:07 Electra kernel: __ratelimit: 3 messages suppressed
Jul 23 13:32:07 Electra kernel: ksoftirqd/0: page allocation failure.
order:5, mode:0x4020
Jul 23 13:32:07 Electra kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
2.6.26 #1
Jul 23 13:32:07 Electra kernel:  [<c0135e93>]
__alloc_pages_internal+0x226/0x393
Jul 23 13:32:07 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
Jul 23 13:32:07 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
Jul 23 13:32:07 Electra kernel:  [<c024d2a5>]
pskb_expand_head+0x41/0x164
Jul 23 13:32:07 Electra kernel:  [<c029a6b4>]
ipcomp_decompress+0x60/0xa1
Jul 23 13:32:07 Electra kernel:  [<c029a781>] ipcomp_input+0x8c/0xa2
Jul 23 13:32:07 Electra kernel:  [<c02a7c25>] xfrm_input+0x119/0x2fc
Jul 23 13:32:07 Electra kernel:  [<c02a187a>] xfrm4_rcv_encap+0x17/0x19
Jul 23 13:32:07 Electra kernel:  [<c02a1ae7>] xfrm4_rcv+0x13/0x15
Jul 23 13:32:07 Electra kernel:  [<c02713f9>]
ip_local_deliver_finish+0xb7/0x15c
Jul 23 13:32:07 Electra kernel:  [<c02714db>] ip_local_deliver+0x3d/0x73
Jul 23 13:32:07 Electra kernel:  [<c02715d1>] ip_rcv_finish+0xc0/0x288
Jul 23 13:32:07 Electra kernel:  [<c0271511>] ip_rcv_finish+0x0/0x288
Jul 23 13:32:07 Electra kernel:  [<c02718f7>] ip_rcv+0x15e/0x22b
Jul 23 13:32:08 Electra kernel:  [<c0253075>]
netif_receive_skb+0x213/0x2bd
Jul 23 13:32:08 Electra kernel:  [<c025317e>] process_backlog+0x5f/0xb9
Jul 23 13:32:08 Electra kernel:  [<c025334d>] net_rx_action+0x152/0x16b
Jul 23 13:32:08 Electra kernel:  [<c01180f4>] __do_softirq+0x6e/0x7a
Jul 23 13:32:08 Electra kernel:  [<c0118379>] ksoftirqd+0x0/0x94
Jul 23 13:32:08 Electra kernel:  [<c0118126>] do_softirq+0x26/0x28
Jul 23 13:32:08 Electra kernel:  [<c01183b6>] ksoftirqd+0x3d/0x94
Jul 23 13:32:08 Electra kernel:  [<c0122072>] kthread+0x54/0x58
Jul 23 13:32:08 Electra kernel:  [<c012201e>] kthread+0x0/0x58
Jul 23 13:32:08 Electra kernel:  [<c01035f7>]
kernel_thread_helper+0x7/0x10
Jul 23 13:32:08 Electra kernel:  =======================
Jul 23 13:32:08 Electra kernel: DMA per-cpu:
Jul 23 13:32:08 Electra kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 23 13:32:08 Electra kernel: Normal per-cpu:
Jul 23 13:32:08 Electra kernel: CPU    0: hi:   90, btch:  15 usd:  76
Jul 23 13:32:08 Electra kernel: Active:25022 inactive:27891 dirty:467
writeback:0 unstable:0
Jul 23 13:32:08 Electra kernel:  free:988 slab:9295 mapped:897
pagetables:136 bounce:0
Jul 23 13:32:08 Electra kernel: DMA free:1104kB min:124kB low:152kB
high:184kB active:4244kB inactive:5248kB present:16256kB pages_scanned:0
all_unreclaimable? no
Jul 23 13:32:08 Electra kernel: lowmem_reserve[]: 0 238 238
Jul 23 13:32:08 Electra kernel: Normal free:2848kB min:1908kB low:2384kB
high:2860kB active:95844kB inactive:106316kB present:243840kB
pages_scanned:0 all_unreclaimable? no
Jul 23 13:32:08 Electra kernel: lowmem_reserve[]: 0 0 0
Jul 23 13:32:08 Electra kernel: DMA: 86*4kB 11*8kB 0*16kB 1*32kB 0*64kB
1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Jul 23 13:32:08 Electra kernel: Normal: 578*4kB 43*8kB 2*16kB 1*32kB
0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2848kB
Jul 23 13:32:08 Electra kernel: 38084 total pagecache pages
Jul 23 13:32:08 Electra kernel: Swap cache: add 505, delete 209, find
123/150
Jul 23 13:32:08 Electra kernel: Free swap  = 208248kB
Jul 23 13:32:08 Electra kernel: Total swap = 209624kB


Marco Berizzi wrote:

> Hi folks,
>
> I got these errors messages after 7 days uptime:
>
> Jul 16 07:48:32 Mimosa kernel: klogd 1.4.1, log source = /proc/kmsg
> started.
> Jul 16 07:48:32 Mimosa kernel: Linux version 2.6.26 (root@Mimosa) (gcc
> version 3.3.5) #1 Mon Jul 14 18:32:19 CEST 2008
> Jul 16 07:48:32 Mimosa kernel: BIOS-provided physical RAM map:
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 0000000000000000 -
> 000000000009f800 (usable)
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 000000000009f800 -
> 00000000000a0000 (reserved)
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 00000000000dc000 -
> 00000000000e0000 (reserved)
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 00000000000f0000 -
> 0000000000100000 (reserved)
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 0000000000100000 -
> 000000000a000000 (usable)
> Jul 16 07:48:32 Mimosa kernel:  BIOS-e820: 00000000ffff0000 -
> 0000000100000000 (reserved)
> Jul 16 07:48:32 Mimosa kernel: 160MB LOWMEM available.
> Jul 16 07:48:32 Mimosa kernel: Entering add_active_range(0, 0, 40960)
0
> entries of 256 used
> Jul 16 07:48:32 Mimosa kernel: Zone PFN ranges:
> Jul 16 07:48:32 Mimosa kernel:   DMA             0 ->     4096
> Jul 16 07:48:32 Mimosa kernel:   Normal       4096 ->    40960
> Jul 16 07:48:32 Mimosa kernel: Movable zone start PFN for each node
> Jul 16 07:48:32 Mimosa kernel: early_node_map[1] active PFN ranges
> Jul 16 07:48:32 Mimosa kernel:     0:        0 ->    40960
> Jul 16 07:48:32 Mimosa kernel: On node 0 totalpages: 40960
> Jul 16 07:48:32 Mimosa kernel:   DMA zone: 32 pages used for memmap
> Jul 16 07:48:32 Mimosa kernel:   DMA zone: 0 pages reserved
> Jul 16 07:48:32 Mimosa kernel:   DMA zone: 4064 pages, LIFO batch:0
> Jul 16 07:48:32 Mimosa kernel:   Normal zone: 288 pages used for
memmap
> Jul 16 07:48:32 Mimosa kernel:   Normal zone: 36576 pages, LIFO
batch:7
> Jul 16 07:48:32 Mimosa kernel:   Movable zone: 0 pages used for memmap
> Jul 16 07:48:32 Mimosa kernel: DMI 2.1 present.
> Jul 16 07:48:32 Mimosa kernel: ACPI Error (tbxfroot-0218): A valid
RSDP
> was not found [20080321]
> Jul 16 07:48:32 Mimosa kernel: ACPI: DMI detected: Hewlett-Packard
> Jul 16 07:48:32 Mimosa kernel: Allocating PCI resources starting at
> 10000000 (gap: 0a000000:f5ff0000)
> Jul 16 07:48:32 Mimosa kernel: Built 1 zonelists in Zone order,
mobility
> grouping on.  Total pages: 40640
> Jul 16 07:48:32 Mimosa kernel: Kernel command line: auto
> BOOT_IMAGE=Linux ro root=301 slub_debug
> Jul 16 07:48:32 Mimosa kernel: Local APIC disabled by BIOS -- you can
> enable it with "lapic"
> Jul 16 07:48:32 Mimosa kernel: mapped APIC to ffffb000 (01141000)
> Jul 16 07:48:32 Mimosa kernel: Enabling fast FPU save and restore...
> done.
> Jul 16 07:48:32 Mimosa kernel: Initializing CPU#0
> Jul 16 07:48:32 Mimosa kernel: PID hash table entries: 1024 (order:
10,
> 4096 bytes)
> Jul 16 07:48:32 Mimosa kernel: Detected 267.289 MHz processor.
> Jul 16 07:48:32 Mimosa kernel: Console: colour VGA+ 80x25
> Jul 16 07:48:32 Mimosa kernel: console [tty0] enabled
> Jul 16 07:48:32 Mimosa kernel: Dentry cache hash table entries: 32768
> (order: 5, 131072 bytes)
> Jul 16 07:48:32 Mimosa kernel: Inode-cache hash table entries: 16384
> (order: 4, 65536 bytes)
> Jul 16 07:48:32 Mimosa kernel: Memory: 159216k/163840k available
(1684k
> kernel code, 4188k reserved, 680k data, 152k init, 0k highmem)
> Jul 16 07:48:32 Mimosa kernel: virtual kernel memory layout:
> Jul 16 07:48:32 Mimosa kernel:     fixmap  : 0xfffb5000 - 0xfffff000
> ( 296 kB)
> Jul 16 07:48:32 Mimosa kernel:     vmalloc : 0xca800000 - 0xfffb3000
> ( 855 MB)
> Jul 16 07:48:32 Mimosa kernel:     lowmem  : 0xc0000000 - 0xca000000
> ( 160 MB)
> Jul 16 07:48:32 Mimosa kernel:       .init : 0xc0352000 - 0xc0378000
> ( 152 kB)
> Jul 16 07:48:32 Mimosa kernel:       .data : 0xc02a532e - 0xc034f43c
> ( 680 kB)
> Jul 16 07:48:32 Mimosa kernel:       .text : 0xc0100000 - 0xc02a532e
> (1684 kB)
> Jul 16 07:48:32 Mimosa kernel: Checking if this processor honours the
WP
> bit even in supervisor mode...Ok.
> Jul 16 07:48:32 Mimosa kernel: CPA: page pool initialized 1 of 1 pages
> preallocated
> Jul 16 07:48:32 Mimosa kernel: SLUB: Genslabs=12, HWalign=32,
Order=0-3,
> MinObjects=0, CPUs=1, Nodes=1
> Jul 16 07:48:32 Mimosa kernel: Calibrating delay using timer specific
> routine.. 535.62 BogoMIPS (lpj=1071240)
> Jul 16 07:48:32 Mimosa kernel: Mount-cache hash table entries: 512
> Jul 16 07:48:32 Mimosa kernel: CPU: L1 I cache: 16K, L1 D cache: 16K
> Jul 16 07:48:32 Mimosa kernel: CPU: Intel Celeron (Covington) stepping
> 00
> Jul 16 07:48:32 Mimosa kernel: Checking 'hlt' instruction... OK.
> Jul 16 07:48:32 Mimosa kernel: Freeing SMP alternatives: 0k freed
> Jul 16 07:48:32 Mimosa kernel: ACPI: Core revision 20080321
> Jul 16 07:48:32 Mimosa kernel: ACPI Exception (tbxface-0629):
> AE_NO_ACPI_TABLES, While loading namespace from ACPI tables [20080321]
> Jul 16 07:48:32 Mimosa kernel: ACPI: Unable to load the System
> Description Tables
> Jul 16 07:48:32 Mimosa kernel: net_namespace: 484 bytes
> Jul 16 07:48:32 Mimosa kernel: NET: Registered protocol family 16
> Jul 16 07:48:32 Mimosa kernel: PCI: PCI BIOS revision 2.10 entry at
> 0xfda61, last bus=1
> Jul 16 07:48:32 Mimosa kernel: PCI: Using configuration type 1 for
base
> access
> Jul 16 07:48:32 Mimosa kernel: Setting up standard PCI resources
> Jul 16 07:48:32 Mimosa kernel: ACPI: Interpreter disabled.
> Jul 16 07:48:32 Mimosa kernel: Linux Plug and Play Support v0.97 (c)
> Adam Belay
> Jul 16 07:48:32 Mimosa kernel: pnp: PnP ACPI: disabled
> Jul 16 07:48:32 Mimosa kernel: PCI: Probing PCI hardware
> Jul 16 07:48:32 Mimosa kernel: PCI: Probing PCI hardware (bus 00)
> Jul 16 07:48:32 Mimosa kernel: * Found PM-Timer Bug on the chipset.
Due
> to workarounds for a bug,
> Jul 16 07:48:32 Mimosa kernel: * this clock source is slow. Consider
> trying other clock sources
> Jul 16 07:48:32 Mimosa kernel: pci 0000:00:07.3: quirk: region
6100-613f
> claimed by PIIX4 ACPI
> Jul 16 07:48:32 Mimosa kernel: pci 0000:00:07.3: quirk: region
5f00-5f0f
> claimed by PIIX4 SMB
> Jul 16 07:48:32 Mimosa kernel: PCI: Using IRQ router PIIX/ICH
> [8086/7110] at 0000:00:07.0
> Jul 16 07:48:32 Mimosa kernel: PCI: Bridge: 0000:00:01.0
> Jul 16 07:48:32 Mimosa kernel:   IO window: b000-bfff
> Jul 16 07:48:32 Mimosa kernel:   MEM window: 0xefe00000-0xefefffff
> Jul 16 07:48:32 Mimosa kernel:   PREFETCH window:
> 0x00000000e5c00000-0x00000000e7cfffff
> Jul 16 07:48:32 Mimosa kernel: NET: Registered protocol family 2
> Jul 16 07:48:32 Mimosa kernel: IP route cache hash table entries: 2048
> (order: 1, 8192 bytes)
> Jul 16 07:48:32 Mimosa kernel: TCP established hash table entries:
8192
> (order: 4, 65536 bytes)
> Jul 16 07:48:32 Mimosa kernel: TCP bind hash table entries: 8192
(order:
> 3, 32768 bytes)
> Jul 16 07:48:32 Mimosa kernel: TCP: Hash tables configured
(established
> 8192 bind 8192)
> Jul 16 07:48:32 Mimosa kernel: TCP reno registered
> Jul 16 07:48:32 Mimosa kernel: NET: Registered protocol family 1
> Jul 16 07:48:32 Mimosa kernel: SGI XFS with security attributes, no
> debug enabled
> Jul 16 07:48:32 Mimosa kernel: msgmni has been set to 311
> Jul 16 07:48:32 Mimosa kernel: io scheduler noop registered (default)
> Jul 16 07:48:32 Mimosa kernel: pci 0000:00:00.0: Limiting direct
PCI/PCI
> transfers
> Jul 16 07:48:32 Mimosa kernel: pci 0000:01:00.0: Boot video device
> Jul 16 07:48:32 Mimosa kernel: Uniform Multi-Platform E-IDE driver
> Jul 16 07:48:32 Mimosa kernel: ide: Assuming 33MHz system bus speed
for
> PIO modes; override with idebus=xx
> Jul 16 07:48:32 Mimosa kernel: PIIX4: IDE controller (0x8086:0x7111
rev
> 0x01) at  PCI slot 0000:00:07.1
> Jul 16 07:48:32 Mimosa kernel: PIIX4: not 100%% native mode: will
probe
> irqs later
> Jul 16 07:48:32 Mimosa kernel:     ide0: BM-DMA at 0xffa0-0xffa7
> Jul 16 07:48:32 Mimosa kernel:     ide1: BM-DMA at 0xffa8-0xffaf
> Jul 16 07:48:32 Mimosa kernel: Probing IDE interface ide0...
> Jul 16 07:48:32 Mimosa kernel: hda: QUANTUM FIREBALL EX3.2A, ATA DISK
> drive
> Jul 16 07:48:32 Mimosa kernel: hda: host max PIO4 wanted
> PIO255(auto-tune) selected PIO4
> Jul 16 07:48:32 Mimosa kernel: hda: UDMA/33 mode selected
> Jul 16 07:48:32 Mimosa kernel: Probing IDE interface ide1...
> Jul 16 07:48:32 Mimosa kernel: hdc: CRD-8160B, ATAPI CD/DVD-ROM drive
> Jul 16 07:48:32 Mimosa kernel: hdc: host max PIO4 wanted
> PIO255(auto-tune) selected PIO4
> Jul 16 07:48:32 Mimosa kernel: hdc: MWDMA2 mode selected
> Jul 16 07:48:32 Mimosa kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> Jul 16 07:48:32 Mimosa kernel: ide1 at 0x170-0x177,0x376 on irq 15
> Jul 16 07:48:32 Mimosa kernel: hda: max request size: 128KiB
> Jul 16 07:48:32 Mimosa kernel: hda: 6306048 sectors (3228 MB) w/418KiB
> Cache, CHS=6256/16/63
> Jul 16 07:48:32 Mimosa kernel: hda: cache flushes not supported
> Jul 16 07:48:32 Mimosa kernel:  hda: hda1 hda2 < hda5 hda6 hda7 hda8
> hda9 >
> Jul 16 07:48:32 Mimosa kernel: PNP: No PS/2 controller found. Probing
> ports directly.
> Jul 16 07:48:32 Mimosa kernel: serio: i8042 KBD port at 0x60,0x64 irq
1
> Jul 16 07:48:32 Mimosa kernel: serio: i8042 AUX port at 0x60,0x64 irq
12
> Jul 16 07:48:32 Mimosa kernel: mice: PS/2 mouse device common for all
> mice
> Jul 16 07:48:32 Mimosa kernel: nf_conntrack version 0.5.0 (3072
buckets,
> 12288 max)
> Jul 16 07:48:32 Mimosa kernel: ip_tables: (C) 2000-2006 Netfilter Core
> Team
> Jul 16 07:48:32 Mimosa kernel: TCP cubic registered
> Jul 16 07:48:32 Mimosa kernel: Initializing XFRM netlink socket
> Jul 16 07:48:32 Mimosa kernel: NET: Registered protocol family 17
> Jul 16 07:48:32 Mimosa kernel: NET: Registered protocol family 15
> Jul 16 07:48:32 Mimosa kernel: Using IPI Shortcut mode
> Jul 16 07:48:32 Mimosa kernel: input: AT Translated Set 2 keyboard as
> /devices/platform/i8042/serio0/input/input0
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda1": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: XFS mounting filesystem hda1
> Jul 16 07:48:32 Mimosa kernel: Ending clean XFS mount for filesystem:
> hda1
> Jul 16 07:48:32 Mimosa kernel: VFS: Mounted root (xfs filesystem)
> readonly.
> Jul 16 07:48:32 Mimosa kernel: Freeing unused kernel memory: 152k
freed
> Jul 16 07:48:32 Mimosa kernel: Adding 330584k swap on /dev/hda9.
> Priority:-1 extents:1 across:330584k
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda1": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda1": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: PCI: setting IRQ 10 as level-triggered
> Jul 16 07:48:32 Mimosa kernel: PCI: Found IRQ 10 for device
0000:00:09.0
> Jul 16 07:48:32 Mimosa kernel: 3c59x: Donald Becker and others.
> Jul 16 07:48:32 Mimosa kernel: 0000:00:09.0: 3Com PCI 3c905 Boomerang
> 100baseTx at 0001dc00.
> Jul 16 07:48:32 Mimosa kernel: PCI: setting IRQ 11 as level-triggered
> Jul 16 07:48:32 Mimosa kernel: PCI: Found IRQ 11 for device
0000:00:0a.0
> Jul 16 07:48:32 Mimosa kernel: 0000:00:0a.0: 3Com PCI 3c905 Boomerang
> 100baseTx at 0001da00.
> Jul 16 07:48:32 Mimosa kernel: PCI: setting IRQ 9 as level-triggered
> Jul 16 07:48:32 Mimosa kernel: PCI: Found IRQ 9 for device
0000:00:0b.0
> Jul 16 07:48:32 Mimosa kernel: PCI: Sharing IRQ 9 with 0000:00:07.2
> Jul 16 07:48:32 Mimosa kernel: 0000:00:0b.0: 3Com PCI 3c905 Boomerang
> 100baseTx at 0001d800.
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda5": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: XFS mounting filesystem hda5
> Jul 16 07:48:32 Mimosa kernel: Ending clean XFS mount for filesystem:
> hda5
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda6": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: XFS mounting filesystem hda6
> Jul 16 07:48:32 Mimosa kernel: Ending clean XFS mount for filesystem:
> hda6
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda7": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: XFS mounting filesystem hda7
> Jul 16 07:48:32 Mimosa kernel: Ending clean XFS mount for filesystem:
> hda7
> Jul 16 07:48:32 Mimosa kernel: Filesystem "hda8": Disabling barriers,
> not supported by the underlying device
> Jul 16 07:48:32 Mimosa kernel: XFS mounting filesystem hda8
> Jul 16 07:48:32 Mimosa kernel: Ending clean XFS mount for filesystem:
> hda8
> Jul 16 07:48:33 Mimosa kernel: eth0:  setting full-duplex.
> Jul 16 07:48:33 Mimosa kernel: eth1:  setting full-duplex.
> Jul 16 07:48:33 Mimosa kernel: eth2:  setting full-duplex.
> Jul 22 21:19:07 Mimosa kernel: eth2: Too much work in interrupt,
status
> ec01.
> Jul 23 12:39:57 Mimosa kernel: 0
> Jul 23 12:39:57 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:57 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:57 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:57 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:57 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:57 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:57 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:57 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:57 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c024007b>] skb_split+0x131/0x206
> Jul 23 12:39:58 Mimosa kernel:  [<c01bad82>]
> xfs_free_eofblocks+0x50/0x250
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 12:39:58 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 12:39:58 Mimosa kernel:  [<c0150000>]
> __link_path_walk+0x87c/0x931
> Jul 23 12:39:58 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 12:39:58 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 12:39:58 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 12:39:58 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 12:39:58 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 12:39:58 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 12:39:58 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 12:39:58 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 12:39:58 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 12:39:58 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  25
> Jul 23 12:39:58 Mimosa kernel: Active:22270 inactive:11319 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:420 slab:4563 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6744kB inactive:4016kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1036kB min:1448kB
low:1808kB
> high:2172kB active:82336kB inactive:41260kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 9*4kB 0*8kB 0*16kB 1*32kB 1*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 101*4kB 27*8kB 12*16kB 3*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
> Jul 23 12:39:58 Mimosa kernel: 16621 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 369, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:58 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c024007b>] skb_split+0x131/0x206
> Jul 23 12:39:58 Mimosa kernel:  [<c01bad82>]
> xfs_free_eofblocks+0x50/0x250
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 12:39:58 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 12:39:58 Mimosa kernel:  [<c0150000>]
> __link_path_walk+0x87c/0x931
> Jul 23 12:39:58 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 12:39:58 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 12:39:58 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 12:39:58 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 12:39:58 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 12:39:58 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 12:39:58 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 12:39:58 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 12:39:58 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 12:39:58 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  25
> Jul 23 12:39:58 Mimosa kernel: Active:22270 inactive:11319 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:420 slab:4563 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6744kB inactive:4016kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1036kB min:1448kB
low:1808kB
> high:2172kB active:82336kB inactive:41260kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 9*4kB 0*8kB 0*16kB 1*32kB 1*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 101*4kB 27*8kB 12*16kB 3*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
> Jul 23 12:39:58 Mimosa kernel: 16621 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 369, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:58 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c024007b>] skb_split+0x131/0x206
> Jul 23 12:39:58 Mimosa kernel:  [<c01bad82>]
> xfs_free_eofblocks+0x50/0x250
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 12:39:58 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 12:39:58 Mimosa kernel:  [<c0150000>]
> __link_path_walk+0x87c/0x931
> Jul 23 12:39:58 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 12:39:58 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 12:39:58 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 12:39:58 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 12:39:58 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 12:39:58 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 12:39:58 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 12:39:58 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 12:39:58 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 12:39:58 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  25
> Jul 23 12:39:58 Mimosa kernel: Active:22270 inactive:11319 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:420 slab:4563 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6744kB inactive:4016kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1036kB min:1448kB
low:1808kB
> high:2172kB active:82336kB inactive:41260kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 9*4kB 0*8kB 0*16kB 1*32kB 1*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 101*4kB 27*8kB 12*16kB 3*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
> Jul 23 12:39:58 Mimosa kernel: 16621 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 369, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:58 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c024007b>] skb_split+0x131/0x206
> Jul 23 12:39:58 Mimosa kernel:  [<c01bad82>]
> xfs_free_eofblocks+0x50/0x250
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 12:39:58 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 12:39:58 Mimosa kernel:  [<c0150000>]
> __link_path_walk+0x87c/0x931
> Jul 23 12:39:58 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 12:39:58 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 12:39:58 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 12:39:58 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 12:39:58 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 12:39:58 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 12:39:58 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 12:39:58 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 12:39:58 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 12:39:58 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  25
> Jul 23 12:39:58 Mimosa kernel: Active:22270 inactive:11319 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:420 slab:4563 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6744kB inactive:4016kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1036kB min:1448kB
low:1808kB
> high:2172kB active:82336kB inactive:41260kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 9*4kB 0*8kB 0*16kB 1*32kB 1*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 101*4kB 27*8kB 12*16kB 3*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
> Jul 23 12:39:58 Mimosa kernel: 16621 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 369, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:58 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c024007b>] skb_split+0x131/0x206
> Jul 23 12:39:58 Mimosa kernel:  [<c01bad82>]
> xfs_free_eofblocks+0x50/0x250
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 12:39:58 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 12:39:58 Mimosa kernel:  [<c0150000>]
> __link_path_walk+0x87c/0x931
> Jul 23 12:39:58 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 12:39:58 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 12:39:58 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 12:39:58 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 12:39:58 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 12:39:58 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 12:39:58 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 12:39:58 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 12:39:58 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 12:39:58 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 12:39:58 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 12:39:58 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  25
> Jul 23 12:39:58 Mimosa kernel: Active:22270 inactive:11319 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:420 slab:4563 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6744kB inactive:4016kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1036kB min:1448kB
low:1808kB
> high:2172kB active:82336kB inactive:41260kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 9*4kB 0*8kB 0*16kB 1*32kB 1*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 101*4kB 27*8kB 12*16kB 3*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
> Jul 23 12:39:58 Mimosa kernel: 16621 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 369, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14830 pages shared
> Jul 23 12:39:58 Mimosa kernel: 358 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4563 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 12:39:58 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 12:39:58 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 12:39:58 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 12:39:58 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 12:39:58 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 12:39:58 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 12:39:58 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 12:39:58 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 12:39:58 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 12:39:58 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 12:39:58 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 12:39:58 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 12:39:58 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 12:39:58 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 12:39:58 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 12:39:58 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 12:39:58 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 12:39:58 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 12:39:58 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 12:39:58 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 12:39:58 Mimosa kernel:  [<c01455ac>] init_object+0x21/0x62
> Jul 23 12:39:58 Mimosa kernel:  [<c0145c00>]
> setup_object_debug+0x17/0x25
> Jul 23 12:39:58 Mimosa kernel:  [<c0145f0c>] setup_object+0xb/0x1b
> Jul 23 12:39:58 Mimosa kernel:  [<c0145fd9>] new_slab+0xbd/0x10b
> Jul 23 12:39:58 Mimosa kernel:  [<c014633f>] __slab_alloc+0x86/0xec
> Jul 23 12:39:58 Mimosa kernel:  [<c01473f5>]
> __kmalloc_track_caller+0x64/0xad
> Jul 23 12:39:58 Mimosa kernel:  [<c023d207>]
> sock_alloc_send_pskb+0x88/0x1bb
> Jul 23 12:39:58 Mimosa kernel:  [<c023d207>]
> sock_alloc_send_pskb+0x88/0x1bb
> Jul 23 12:39:58 Mimosa kernel:  [<c023e2d6>] __alloc_skb+0x46/0xef
> Jul 23 12:39:58 Mimosa kernel:  [<c023d207>]
> sock_alloc_send_pskb+0x88/0x1bb
> Jul 23 12:39:58 Mimosa kernel:  [<c023d346>]
sock_alloc_send_skb+0xc/0xf
> Jul 23 12:39:58 Mimosa kernel:  [<c0298ebe>]
> unix_dgram_sendmsg+0x163/0x3ee
> Jul 23 12:39:58 Mimosa kernel:  [<c023acd5>] do_sock_write+0x8d/0x94
> Jul 23 12:39:58 Mimosa kernel:  [<c023ad1d>] sock_aio_write+0x41/0x4f
> Jul 23 12:39:58 Mimosa kernel:  [<c010ff6f>]
update_avg_stats+0x26/0x39
> Jul 23 12:39:58 Mimosa kernel:  [<c010fb8d>]
__dequeue_entity+0x21/0x79
> Jul 23 12:39:58 Mimosa kernel:  [<c0149e10>] do_sync_write+0xb6/0xf7
> Jul 23 12:39:58 Mimosa kernel:  [<c01464de>] kmem_cache_free+0x50/0x58
> Jul 23 12:39:58 Mimosa kernel:  [<c0131f8e>] mempool_free+0x47/0x4a
> Jul 23 12:39:58 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 12:39:58 Mimosa kernel:  [<c0110017>] set_next_entity+0x1d/0x42
> Jul 23 12:39:58 Mimosa kernel:  [<c0149ee5>] vfs_write+0x94/0xe9
> Jul 23 12:39:58 Mimosa kernel:  [<c0149fd8>] sys_write+0x3c/0x62
> Jul 23 12:39:58 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 12:39:58 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 12:39:58 Mimosa kernel:  =======================
> Jul 23 12:39:58 Mimosa kernel: Mem-info:
> Jul 23 12:39:58 Mimosa kernel: DMA per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Normal per-cpu:
> Jul 23 12:39:58 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:   0
> Jul 23 12:39:58 Mimosa kernel: Active:22195 inactive:11334 dirty:11
> writeback:0 unstable:0
> Jul 23 12:39:58 Mimosa kernel:  free:527 slab:4637 mapped:1098
> pagetables:221 bounce:0
> Jul 23 12:39:58 Mimosa kernel: DMA free:736kB min:160kB low:200kB
> high:240kB active:6704kB inactive:4056kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 12:39:58 Mimosa kernel: Normal free:1372kB min:1448kB
low:1808kB
> high:2172kB active:82076kB inactive:41280kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 12:39:58 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 12:39:58 Mimosa kernel: DMA: 8*4kB 0*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 736kB
> Jul 23 12:39:58 Mimosa kernel: Normal: 151*4kB 44*8kB 12*16kB 1*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1372kB
> Jul 23 12:39:58 Mimosa kernel: 16561 total pagecache pages
> Jul 23 12:39:58 Mimosa kernel: Swap cache: add 727, delete 390, find
> 184/240
> Jul 23 12:39:58 Mimosa kernel: Free swap  = 328920kB
> Jul 23 12:39:58 Mimosa kernel: Total swap = 330584kB
> Jul 23 12:39:58 Mimosa kernel: 40960 pages of RAM
> Jul 23 12:39:58 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 12:39:58 Mimosa kernel: 1107 reserved pages
> Jul 23 12:39:58 Mimosa kernel: 14793 pages shared
> Jul 23 12:39:58 Mimosa kernel: 337 pages swap cached
> Jul 23 12:39:58 Mimosa kernel: 11 pages dirty
> Jul 23 12:39:58 Mimosa kernel: 0 pages writeback
> Jul 23 12:39:58 Mimosa kernel: 1098 pages mapped
> Jul 23 12:39:58 Mimosa kernel: 4646 pages slab
> Jul 23 12:39:58 Mimosa kernel: 221 pages pagetables
> Jul 23 13:23:53 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:23:53 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 13:23:53 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:23:53 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:23:53 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:23:53 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:23:53 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:23:53 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:23:53 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:23:53 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:23:53 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:23:53 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:23:53 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:23:53 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:23:53 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:23:54 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:23:54 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:23:54 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:23:54 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:23:54 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:23:54 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:23:54 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:23:54 Mimosa kernel:  [<c0136d49>] shrink_slab+0xc8/0x187
> Jul 23 13:23:54 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 13:23:54 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 13:23:54 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 13:23:54 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 13:23:54 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 13:23:54 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 13:23:54 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:23:54 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:23:54 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:23:54 Mimosa kernel:  =======================
> Jul 23 13:23:54 Mimosa kernel: Mem-info:
> Jul 23 13:23:54 Mimosa kernel: DMA per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:23:54 Mimosa kernel: Normal per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  37
> Jul 23 13:23:54 Mimosa kernel: Active:22041 inactive:11659 dirty:2
> writeback:0 unstable:0
> Jul 23 13:23:54 Mimosa kernel:  free:457 slab:4403 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:23:54 Mimosa kernel: DMA free:640kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:23:54 Mimosa kernel: Normal free:1188kB min:1448kB
low:1808kB
> high:2172kB active:81496kB inactive:42524kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:23:54 Mimosa kernel: DMA: 36*4kB 6*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 640kB
> Jul 23 13:23:54 Mimosa kernel: Normal: 99*4kB 31*8kB 20*16kB 1*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1188kB
> Jul 23 13:23:54 Mimosa kernel: 16903 total pagecache pages
> Jul 23 13:23:54 Mimosa kernel: Swap cache: add 1107, delete 539, find
> 264/346
> Jul 23 13:23:54 Mimosa kernel: Free swap  = 328008kB
> Jul 23 13:23:54 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:23:54 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:23:54 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:23:54 Mimosa kernel: 1107 reserved pages
> Jul 23 13:23:54 Mimosa kernel: 15171 pages shared
> Jul 23 13:23:54 Mimosa kernel: 568 pages swap cached
> Jul 23 13:23:54 Mimosa kernel: 2 pages dirty
> Jul 23 13:23:54 Mimosa kernel: 0 pages writeback
> Jul 23 13:23:54 Mimosa kernel: 1094 pages mapped
> Jul 23 13:23:54 Mimosa kernel: 4403 pages slab
> Jul 23 13:23:54 Mimosa kernel: 221 pages pagetables
> Jul 23 13:23:54 Mimosa kernel: syslogd: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:23:54 Mimosa kernel: Pid: 414, comm: syslogd Not tainted
> 2.6.26 #1
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:23:54 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:23:54 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:23:54 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:23:54 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:23:54 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:23:54 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:23:54 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:23:54 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:23:54 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:23:54 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:23:54 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:23:54 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:23:54 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:23:54 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:23:54 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:23:54 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c0240000>] skb_split+0xb6/0x206
> Jul 23 13:23:54 Mimosa kernel:  [<c01464e2>] kmem_cache_free+0x54/0x58
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c029964a>]
> unix_dgram_recvmsg+0x1c3/0x1dc
> Jul 23 13:23:54 Mimosa kernel:  [<c023aa60>] sock_recvmsg+0xbf/0xda
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c014a1be>]
> do_sync_readv_writev+0xb7/0xf8
> Jul 23 13:23:54 Mimosa kernel:  [<c023b8f6>] sys_recvfrom+0xa2/0xfc
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c01026cd>] handle_signal+0xf8/0x100
> Jul 23 13:23:54 Mimosa kernel:  [<c010655e>] read_tsc+0x6/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c01e535b>] copy_from_user+0x29/0x4e
> Jul 23 13:23:54 Mimosa kernel:  [<c014a430>]
do_readv_writev+0x128/0x134
> Jul 23 13:23:54 Mimosa kernel:  [<c023b969>] sys_recv+0x19/0x1d
> Jul 23 13:23:54 Mimosa kernel:  [<c023bef2>] sys_socketcall+0xfc/0x179
> Jul 23 13:23:54 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 13:23:54 Mimosa kernel:  =======================
> Jul 23 13:23:54 Mimosa kernel: Mem-info:
> Jul 23 13:23:54 Mimosa kernel: DMA per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:23:54 Mimosa kernel: Normal per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  37
> Jul 23 13:23:54 Mimosa kernel: Active:21995 inactive:11659 dirty:4
> writeback:0 unstable:0
> Jul 23 13:23:54 Mimosa kernel:  free:482 slab:4378 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:23:54 Mimosa kernel: DMA free:644kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:23:54 Mimosa kernel: Normal free:1284kB min:1448kB
low:1808kB
> high:2172kB active:81312kB inactive:42524kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:23:54 Mimosa kernel: DMA: 35*4kB 7*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 644kB
> Jul 23 13:23:54 Mimosa kernel: Normal: 99*4kB 31*8kB 20*16kB 4*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1284kB
> Jul 23 13:23:54 Mimosa kernel: 16903 total pagecache pages
> Jul 23 13:23:54 Mimosa kernel: Swap cache: add 1107, delete 539, find
> 264/346
> Jul 23 13:23:54 Mimosa kernel: Free swap  = 328008kB
> Jul 23 13:23:54 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:23:54 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:23:54 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:23:54 Mimosa kernel: 1107 reserved pages
> Jul 23 13:23:54 Mimosa kernel: 15216 pages shared
> Jul 23 13:23:54 Mimosa kernel: 568 pages swap cached
> Jul 23 13:23:54 Mimosa kernel: 4 pages dirty
> Jul 23 13:23:54 Mimosa kernel: 0 pages writeback
> Jul 23 13:23:54 Mimosa kernel: 1094 pages mapped
> Jul 23 13:23:54 Mimosa kernel: 4378 pages slab
> Jul 23 13:23:54 Mimosa kernel: 221 pages pagetables
> Jul 23 13:23:54 Mimosa kernel: syslogd: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:23:54 Mimosa kernel: Pid: 414, comm: syslogd Not tainted
> 2.6.26 #1
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:23:54 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:23:54 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:23:54 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:23:54 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:23:54 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:23:54 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:23:54 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:23:54 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:23:54 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:23:54 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:23:54 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:23:54 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:23:54 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:23:54 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:23:54 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:23:54 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:23:54 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c0240000>] skb_split+0xb6/0x206
> Jul 23 13:23:54 Mimosa kernel:  [<c01464e2>] kmem_cache_free+0x54/0x58
> Jul 23 13:23:54 Mimosa kernel:  [<c024118b>]
skb_free_datagram+0xa/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c029964a>]
> unix_dgram_recvmsg+0x1c3/0x1dc
> Jul 23 13:23:54 Mimosa kernel:  [<c023aa60>] sock_recvmsg+0xbf/0xda
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c014a1be>]
> do_sync_readv_writev+0xb7/0xf8
> Jul 23 13:23:54 Mimosa kernel:  [<c023b8f6>] sys_recvfrom+0xa2/0xfc
> Jul 23 13:23:54 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:23:54 Mimosa kernel:  [<c01026cd>] handle_signal+0xf8/0x100
> Jul 23 13:23:54 Mimosa kernel:  [<c010655e>] read_tsc+0x6/0x29
> Jul 23 13:23:54 Mimosa kernel:  [<c01e535b>] copy_from_user+0x29/0x4e
> Jul 23 13:23:54 Mimosa kernel:  [<c014a430>]
do_readv_writev+0x128/0x134
> Jul 23 13:23:54 Mimosa kernel:  [<c023b969>] sys_recv+0x19/0x1d
> Jul 23 13:23:54 Mimosa kernel:  [<c023bef2>] sys_socketcall+0xfc/0x179
> Jul 23 13:23:54 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 13:23:54 Mimosa kernel:  =======================
> Jul 23 13:23:54 Mimosa kernel: Mem-info:
> Jul 23 13:23:54 Mimosa kernel: DMA per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:23:54 Mimosa kernel: Normal per-cpu:
> Jul 23 13:23:54 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  37
> Jul 23 13:23:54 Mimosa kernel: Active:21995 inactive:11659 dirty:4
> writeback:0 unstable:0
> Jul 23 13:23:54 Mimosa kernel:  free:483 slab:4377 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:23:54 Mimosa kernel: DMA free:648kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:23:54 Mimosa kernel: Normal free:1284kB min:1448kB
low:1808kB
> high:2172kB active:81312kB inactive:42524kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:23:54 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:23:54 Mimosa kernel: DMA: 34*4kB 8*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 648kB
> Jul 23 13:23:54 Mimosa kernel: Normal: 99*4kB 31*8kB 20*16kB 4*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1284kB
> Jul 23 13:23:54 Mimosa kernel: 16903 total pagecache pages
> Jul 23 13:23:54 Mimosa kernel: Swap cache: add 1107, delete 539, find
> 264/346
> Jul 23 13:23:54 Mimosa kernel: Free swap  = 328008kB
> Jul 23 13:23:54 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:23:54 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:23:54 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:23:54 Mimosa kernel: 1107 reserved pages
> Jul 23 13:23:54 Mimosa kernel: 15216 pages shared
> Jul 23 13:23:54 Mimosa kernel: 568 pages swap cached
> Jul 23 13:23:54 Mimosa kernel: 4 pages dirty
> Jul 23 13:23:54 Mimosa kernel: 0 pages writeback
> Jul 23 13:23:54 Mimosa kernel: 1094 pages mapped
> Jul 23 13:23:54 Mimosa kernel: 4377 pages slab
> Jul 23 13:23:54 Mimosa kernel: 221 pages pagetables
> Jul 23 13:25:48 Mimosa kernel: kswapd0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:25:48 Mimosa kernel: Pid: 74, comm: kswapd0 Not tainted
2.6.26
> #1
> Jul 23 13:25:48 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:25:48 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:25:48 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:25:48 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:25:50 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:25:50 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:25:50 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:25:50 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:25:50 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:25:50 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:25:50 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:25:50 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:25:50 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:25:50 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:25:50 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:25:50 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:25:50 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:25:50 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:25:50 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:25:50 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:25:50 Mimosa kernel:  [<c01a7049>]
> xfs_iext_bno_to_ext+0x40/0x192
> Jul 23 13:25:50 Mimosa kernel:  [<c01899a0>]
> xfs_bmap_search_multi_extents+0x4f/0xbe
> Jul 23 13:25:50 Mimosa kernel:  [<c0189a42>]
> xfs_bmap_search_extents+0x33/0x87
> Jul 23 13:25:50 Mimosa kernel:  [<c018ab8a>] xfs_bmapi+0x294/0x105a
> Jul 23 13:25:50 Mimosa kernel:  [<c0132b7a>]
free_pages_bulk+0x8d/0x1f5
> Jul 23 13:25:50 Mimosa kernel:  [<c01badfc>]
> xfs_free_eofblocks+0xca/0x250
> Jul 23 13:25:50 Mimosa kernel:  [<c014570e>] check_pad_bytes+0x45/0x50
> Jul 23 13:25:50 Mimosa kernel:  [<c01bb657>] xfs_inactive+0x11e/0x3ff
> Jul 23 13:25:50 Mimosa kernel:  [<c0158213>] destroy_inode+0x24/0x33
> Jul 23 13:25:50 Mimosa kernel:  [<c01c6be5>]
> xfs_fs_clear_inode+0x2d/0x5c
> Jul 23 13:25:50 Mimosa kernel:  [<c0158389>] clear_inode+0x5e/0xaa
> Jul 23 13:25:50 Mimosa kernel:  [<c0158420>] dispose_list+0x4b/0xa4
> Jul 23 13:25:50 Mimosa kernel:  [<c01586b5>] prune_icache+0x13d/0x14f
> Jul 23 13:25:50 Mimosa kernel:  [<c01586db>]
> shrink_icache_memory+0x14/0x2b
> Jul 23 13:25:50 Mimosa kernel:  [<c0136daf>] shrink_slab+0x12e/0x187
> Jul 23 13:25:50 Mimosa kernel:  [<c0138290>] balance_pgdat+0x22d/0x32b
> Jul 23 13:25:50 Mimosa kernel:  [<c0137664>]
> isolate_pages_global+0x0/0x42
> Jul 23 13:25:50 Mimosa kernel:  [<c013007b>]
> do_generic_file_read+0x356/0x375
> Jul 23 13:25:50 Mimosa kernel:  [<c013843f>] kswapd+0xb1/0xb3
> Jul 23 13:25:50 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:25:50 Mimosa kernel:  [<c02a3806>]
> __sched_text_start+0x296/0x2b2
> Jul 23 13:25:50 Mimosa kernel:  [<c011102a>]
__wake_up_common+0x35/0x5e
> Jul 23 13:25:50 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:25:50 Mimosa kernel:  [<c01110d7>] complete+0x1f/0x28
> Jul 23 13:25:50 Mimosa kernel:  [<c013838e>] kswapd+0x0/0xb3
> Jul 23 13:25:50 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:25:50 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:25:50 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:25:50 Mimosa kernel:  =======================
> Jul 23 13:25:50 Mimosa kernel: Mem-info:
> Jul 23 13:25:50 Mimosa kernel: DMA per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:25:50 Mimosa kernel: Normal per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  29
> Jul 23 13:25:50 Mimosa kernel: Active:22006 inactive:11638 dirty:2
> writeback:0 unstable:0
> Jul 23 13:25:50 Mimosa kernel:  free:535 slab:4292 mapped:1092
> pagetables:221 bounce:0
> Jul 23 13:25:50 Mimosa kernel: DMA free:648kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:25:50 Mimosa kernel: Normal free:1492kB min:1448kB
low:1808kB
> high:2172kB active:81356kB inactive:42440kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:25:50 Mimosa kernel: DMA: 34*4kB 8*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 648kB
> Jul 23 13:25:50 Mimosa kernel: Normal: 147*4kB 37*8kB 22*16kB 4*32kB
> 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1492kB
> Jul 23 13:25:50 Mimosa kernel: 16868 total pagecache pages
> Jul 23 13:25:50 Mimosa kernel: Swap cache: add 1150, delete 580, find
> 274/359
> Jul 23 13:25:50 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:25:50 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:25:50 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:25:50 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:25:50 Mimosa kernel: 1107 reserved pages
> Jul 23 13:25:50 Mimosa kernel: 15149 pages shared
> Jul 23 13:25:50 Mimosa kernel: 570 pages swap cached
> Jul 23 13:25:50 Mimosa kernel: 2 pages dirty
> Jul 23 13:25:50 Mimosa kernel: 0 pages writeback
> Jul 23 13:25:50 Mimosa kernel: 1092 pages mapped
> Jul 23 13:25:50 Mimosa kernel: 4292 pages slab
> Jul 23 13:25:50 Mimosa kernel: 221 pages pagetables
> Jul 23 13:25:50 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 13:25:50 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:25:50 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:25:50 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:25:50 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:25:50 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:25:50 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:25:50 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:25:50 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:25:50 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:25:50 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:25:50 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:25:50 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:25:50 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:25:50 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:25:50 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:25:50 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:25:50 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:25:50 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:25:50 Mimosa kernel:  [<c01e0000>] get_options+0x51/0x62
> Jul 23 13:25:50 Mimosa kernel:  [<c0240d6c>]
memcpy_fromiovec+0x36/0x49
> Jul 23 13:25:50 Mimosa kernel:  [<c0298f24>]
> unix_dgram_sendmsg+0x1c9/0x3ee
> Jul 23 13:25:50 Mimosa kernel:  [<c023acd5>] do_sock_write+0x8d/0x94
> Jul 23 13:25:50 Mimosa kernel:  [<c023ad1d>] sock_aio_write+0x41/0x4f
> Jul 23 13:25:50 Mimosa kernel:  [<c010fb8d>]
__dequeue_entity+0x21/0x79
> Jul 23 13:25:50 Mimosa kernel:  [<c0149e10>] do_sync_write+0xb6/0xf7
> Jul 23 13:25:50 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:25:50 Mimosa kernel:  [<c0146484>] __slab_free+0x6a/0x74
> Jul 23 13:25:50 Mimosa kernel:  [<c0243f2a>] net_tx_action+0x51/0x9f
> Jul 23 13:25:50 Mimosa kernel:  [<c0149ee5>] vfs_write+0x94/0xe9
> Jul 23 13:25:50 Mimosa kernel:  [<c0149fd8>] sys_write+0x3c/0x62
> Jul 23 13:25:50 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 13:25:50 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 13:25:50 Mimosa kernel:  =======================
> Jul 23 13:25:50 Mimosa kernel: Mem-info:
> Jul 23 13:25:50 Mimosa kernel: DMA per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:25:50 Mimosa kernel: Normal per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  41
> Jul 23 13:25:50 Mimosa kernel: Active:22006 inactive:11638 dirty:2
> writeback:0 unstable:0
> Jul 23 13:25:50 Mimosa kernel:  free:526 slab:4385 mapped:1092
> pagetables:221 bounce:0
> Jul 23 13:25:50 Mimosa kernel: DMA free:640kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:25:50 Mimosa kernel: Normal free:1464kB min:1448kB
low:1808kB
> high:2172kB active:81356kB inactive:42440kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:25:50 Mimosa kernel: DMA: 36*4kB 6*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 640kB
> Jul 23 13:25:50 Mimosa kernel: Normal: 160*4kB 43*8kB 14*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1464kB
> Jul 23 13:25:50 Mimosa kernel: 16868 total pagecache pages
> Jul 23 13:25:50 Mimosa kernel: Swap cache: add 1150, delete 580, find
> 274/359
> Jul 23 13:25:50 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:25:50 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:25:50 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:25:50 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:25:50 Mimosa kernel: 1107 reserved pages
> Jul 23 13:25:50 Mimosa kernel: 15149 pages shared
> Jul 23 13:25:50 Mimosa kernel: 570 pages swap cached
> Jul 23 13:25:50 Mimosa kernel: 2 pages dirty
> Jul 23 13:25:50 Mimosa kernel: 0 pages writeback
> Jul 23 13:25:50 Mimosa kernel: 1092 pages mapped
> Jul 23 13:25:50 Mimosa kernel: 4385 pages slab
> Jul 23 13:25:50 Mimosa kernel: 221 pages pagetables
> Jul 23 13:25:50 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 13:25:50 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:25:50 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:25:50 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:25:50 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:25:50 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:25:50 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:25:50 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:25:50 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:25:50 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:25:50 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:25:50 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:25:50 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:25:50 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:25:50 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:25:50 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:25:50 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:25:50 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:25:50 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:25:50 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:25:50 Mimosa kernel:  [<c01e0000>] get_options+0x51/0x62
> Jul 23 13:25:50 Mimosa kernel:  [<c0240d6c>]
memcpy_fromiovec+0x36/0x49
> Jul 23 13:25:50 Mimosa kernel:  [<c0298f24>]
> unix_dgram_sendmsg+0x1c9/0x3ee
> Jul 23 13:25:50 Mimosa kernel:  [<c023acd5>] do_sock_write+0x8d/0x94
> Jul 23 13:25:50 Mimosa kernel:  [<c023ad1d>] sock_aio_write+0x41/0x4f
> Jul 23 13:25:50 Mimosa kernel:  [<c010fb8d>]
__dequeue_entity+0x21/0x79
> Jul 23 13:25:50 Mimosa kernel:  [<c0149e10>] do_sync_write+0xb6/0xf7
> Jul 23 13:25:50 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:25:50 Mimosa kernel:  [<c0146484>] __slab_free+0x6a/0x74
> Jul 23 13:25:50 Mimosa kernel:  [<c0243f2a>] net_tx_action+0x51/0x9f
> Jul 23 13:25:50 Mimosa kernel:  [<c0149ee5>] vfs_write+0x94/0xe9
> Jul 23 13:25:50 Mimosa kernel:  [<c0149fd8>] sys_write+0x3c/0x62
> Jul 23 13:25:50 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 13:25:50 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 13:25:50 Mimosa kernel:  =======================
> Jul 23 13:25:50 Mimosa kernel: Mem-info:
> Jul 23 13:25:50 Mimosa kernel: DMA per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:25:50 Mimosa kernel: Normal per-cpu:
> Jul 23 13:25:50 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  41
> Jul 23 13:25:50 Mimosa kernel: Active:22006 inactive:11638 dirty:2
> writeback:0 unstable:0
> Jul 23 13:25:50 Mimosa kernel:  free:526 slab:4385 mapped:1092
> pagetables:221 bounce:0
> Jul 23 13:25:50 Mimosa kernel: DMA free:640kB min:160kB low:200kB
> high:240kB active:6668kB inactive:4112kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:25:50 Mimosa kernel: Normal free:1464kB min:1448kB
low:1808kB
> high:2172kB active:81356kB inactive:42440kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:25:50 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:25:50 Mimosa kernel: DMA: 36*4kB 6*8kB 0*16kB 0*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 640kB
> Jul 23 13:25:50 Mimosa kernel: Normal: 160*4kB 43*8kB 14*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1464kB
> Jul 23 13:25:50 Mimosa kernel: 16868 total pagecache pages
> Jul 23 13:25:50 Mimosa kernel: Swap cache: add 1150, delete 580, find
> 274/359
> Jul 23 13:25:50 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:25:50 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:25:50 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:25:50 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:25:50 Mimosa kernel: 1107 reserved pages
> Jul 23 13:25:50 Mimosa kernel: 15149 pages shared
> Jul 23 13:25:50 Mimosa kernel: 570 pages swap cached
> Jul 23 13:25:50 Mimosa kernel: 2 pages dirty
> Jul 23 13:25:50 Mimosa kernel: 0 pages writeback
> Jul 23 13:25:50 Mimosa kernel: 1092 pages mapped
> Jul 23 13:25:50 Mimosa kernel: 4386 pages slab
> Jul 23 13:25:50 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:50 Mimosa kernel: ksoftirqd/0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:50 Mimosa kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
> 2.6.26 #1
> Jul 23 13:31:50 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:50 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:50 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:50 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:50 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:50 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:51 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:51 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:51 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:51 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:51 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:51 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:51 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:51 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:51 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:51 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:51 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:51 Mimosa kernel:  [<c0117502>] ksoftirqd+0x0/0x94
> Jul 23 13:31:51 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:51 Mimosa kernel:  [<c011753d>] ksoftirqd+0x3b/0x94
> Jul 23 13:31:51 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:31:51 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:31:51 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:31:51 Mimosa kernel:  =======================
> Jul 23 13:31:51 Mimosa kernel: Mem-info:
> Jul 23 13:31:51 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:51 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:51 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:51 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  10
> Jul 23 13:31:51 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:51 Mimosa kernel:  free:543 slab:4276 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:51 Mimosa kernel: DMA free:692kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:51 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:51 Mimosa kernel: Normal free:1480kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:51 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:51 Mimosa kernel: DMA: 33*4kB 8*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> Jul 23 13:31:51 Mimosa kernel: Normal: 114*4kB 50*8kB 25*16kB 1*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1480kB
> Jul 23 13:31:51 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:51 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:51 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:51 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:51 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:51 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:51 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:51 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:51 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:51 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:51 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:51 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:51 Mimosa kernel: 4276 pages slab
> Jul 23 13:31:51 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:51 Mimosa kernel: ksoftirqd/0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:51 Mimosa kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
> 2.6.26 #1
> Jul 23 13:31:51 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:51 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:51 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:51 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:51 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:51 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:51 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:51 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:51 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:51 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:51 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:51 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:51 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:51 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:51 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:51 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:51 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:51 Mimosa kernel:  [<c0117502>] ksoftirqd+0x0/0x94
> Jul 23 13:31:51 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:51 Mimosa kernel:  [<c011753d>] ksoftirqd+0x3b/0x94
> Jul 23 13:31:51 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:31:51 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:31:51 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:31:51 Mimosa kernel:  =======================
> Jul 23 13:31:51 Mimosa kernel: Mem-info:
> Jul 23 13:31:51 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:51 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:51 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:51 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  10
> Jul 23 13:31:51 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:51 Mimosa kernel:  free:543 slab:4276 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:51 Mimosa kernel: DMA free:692kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1480kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 33*4kB 8*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 114*4kB 50*8kB 25*16kB 1*32kB
> 1*64kB 1*128kB 0*256agecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4259 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: ksoftirqd/0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
> 2.6.26 #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c0117502>] ksoftirqd+0x0/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c011753d>] ksoftirqd+0x3b/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  11
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:559 slab:4259 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:692kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1544kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 33*4kB 8*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 114*4kB 50*8kB 25*16kB 3*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1544kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4259 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: ksoftirqd/0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
> 2.6.26 #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c0117502>] ksoftirqd+0x0/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c011753d>] ksoftirqd+0x3b/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  11
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:559 slab:4259 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:692kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1544kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 33*4kB 8*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 114*4kB 50*8kB 25*16kB 3*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1544kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4259 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: ksoftirqd/0: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 3, comm: ksoftirqd/0 Not tainted
> 2.6.26 #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c0117502>] ksoftirqd+0x0/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c011753d>] ksoftirqd+0x3b/0x94
> Jul 23 13:31:52 Mimosa kernel:  [<c0120cd9>] kthread+0x33/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0120ca6>] kthread+0x0/0x54
> Jul 23 13:31:52 Mimosa kernel:  [<c0103433>]
> kernel_thread_helper+0x7/0x10
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:  11
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:559 slab:4259 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:692kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1544kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 33*4kB 8*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 114*4kB 50*8kB 25*16kB 3*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1544kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4259 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:31:52 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:31:52 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:   8
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:549 slab:4400 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:712kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1484kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 36*4kB 7*8kB 0*16kB 0*32kB 0*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 712kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 107*4kB 50*8kB 25*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1484kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4400 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:31:52 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:31:52 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:   8
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:549 slab:4400 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:712kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1484kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 36*4kB 7*8kB 0*16kB 0*32kB 0*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 712kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 107*4kB 50*8kB 25*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1484kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4400 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: klogd: page allocation failure.
order:5,
> mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 417, comm: klogd Not tainted
2.6.26
> #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:31:52 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:31:52 Mimosa kernel:  [<c02a0000>] klist_release+0x6/0x30
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:   8
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:40
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:549 slab:4400 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:712kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1484kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 36*4kB 7*8kB 0*16kB 0*32kB 0*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 712kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 107*4kB 50*8kB 25*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1484kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 40 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4400 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
> Jul 23 13:31:52 Mimosa kernel: syslogd: page allocation failure.
> order:5, mode:0x4020
> Jul 23 13:31:52 Mimosa kernel: Pid: 414, comm: syslogd Not tainted
> 2.6.26 #1
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cc1>]
> __alloc_pages_internal+0x331/0x343
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cda>] __alloc_pages+0x7/0x9
> Jul 23 13:31:52 Mimosa kernel:  [<c0133cfd>]
__get_free_pages+0x16/0x32
> Jul 23 13:31:52 Mimosa kernel:  [<c023ea18>]
pskb_expand_head+0x41/0x13d
> Jul 23 13:31:52 Mimosa kernel:  [<c0287af4>]
ipcomp_decompress+0x58/0x9f
> Jul 23 13:31:52 Mimosa kernel:  [<c0287bbe>] ipcomp_input+0x83/0x91
> Jul 23 13:31:52 Mimosa kernel:  [<c02943ec>] xfrm_input+0x165/0x2ce
> Jul 23 13:31:52 Mimosa kernel:  [<c028e6b6>] xfrm4_rcv_encap+0x17/0x19
> Jul 23 13:31:52 Mimosa kernel:  [<c028e8ce>] xfrm4_rcv+0x13/0x15
> Jul 23 13:31:52 Mimosa kernel:  [<c0260d37>]
> ip_local_deliver_finish+0xcc/0x143
> Jul 23 13:31:52 Mimosa kernel:  [<c0260e14>]
ip_local_deliver+0x66/0x6c
> Jul 23 13:31:52 Mimosa kernel:  [<c0261041>] ip_rcv_finish+0x227/0x24a
> Jul 23 13:31:52 Mimosa kernel:  [<c026123b>] ip_rcv+0x1d7/0x1f4
> Jul 23 13:31:52 Mimosa kernel:  [<c0244202>]
> netif_receive_skb+0x223/0x23c
> Jul 23 13:31:52 Mimosa kernel:  [<c02442af>] process_backlog+0x94/0xb5
> Jul 23 13:31:52 Mimosa kernel:  [<c024435e>] net_rx_action+0x6b/0x14a
> Jul 23 13:31:52 Mimosa kernel:  [<c011725d>] __do_softirq+0x35/0x73
> Jul 23 13:31:52 Mimosa kernel:  [<c01172bd>] do_softirq+0x22/0x26
> Jul 23 13:31:52 Mimosa kernel:  [<c01047f0>] do_IRQ+0x4e/0x5d
> Jul 23 13:31:52 Mimosa kernel:  [<c01032c3>]
common_interrupt+0x23/0x28
> Jul 23 13:31:52 Mimosa kernel:  [<c015007b>]
> __link_path_walk+0x8f7/0x931
> Jul 23 13:31:52 Mimosa kernel:  [<c01c41c4>]
xfs_ichgtime_fast+0x42/0x55
> Jul 23 13:31:52 Mimosa kernel:  [<c01c57e4>] xfs_write+0x2be/0x6ba
> Jul 23 13:31:52 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:31:52 Mimosa kernel:  [<c01c233e>]
> xfs_file_aio_write+0x5c/0x64
> Jul 23 13:31:52 Mimosa kernel:  [<c014a1be>]
> do_sync_readv_writev+0xb7/0xf8
> Jul 23 13:31:52 Mimosa kernel:  [<c012104a>]
> autoremove_wake_function+0x0/0x2d
> Jul 23 13:31:52 Mimosa kernel:  [<c01026cd>] handle_signal+0xf8/0x100
> Jul 23 13:31:52 Mimosa kernel:  [<c010655e>] read_tsc+0x6/0x29
> Jul 23 13:31:52 Mimosa kernel:  [<c01e535b>] copy_from_user+0x29/0x4e
> Jul 23 13:31:52 Mimosa kernel:  [<c014a2a1>]
> rw_copy_check_uvector+0x5a/0xc1
> Jul 23 13:31:52 Mimosa kernel:  [<c014a391>]
do_readv_writev+0x89/0x134
> Jul 23 13:31:52 Mimosa kernel:  [<c01c22e2>]
xfs_file_aio_write+0x0/0x64
> Jul 23 13:31:52 Mimosa kernel:  [<c014a4b7>] vfs_writev+0x3d/0x41
> Jul 23 13:31:52 Mimosa kernel:  [<c014a559>] sys_writev+0x3c/0x62
> Jul 23 13:31:52 Mimosa kernel:  [<c010293a>] syscall_call+0x7/0xb
> Jul 23 13:31:52 Mimosa kernel:  =======================
> Jul 23 13:31:52 Mimosa kernel: Mem-info:
> Jul 23 13:31:52 Mimosa kernel: DMA per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jul 23 13:31:52 Mimosa kernel: Normal per-cpu:
> Jul 23 13:31:52 Mimosa kernel: CPU    0: hi:   42, btch:   7 usd:   8
> Jul 23 13:31:52 Mimosa kernel: Active:22057 inactive:11666 dirty:42
> writeback:0 unstable:0
> Jul 23 13:31:52 Mimosa kernel:  free:549 slab:4400 mapped:1094
> pagetables:221 bounce:0
> Jul 23 13:31:52 Mimosa kernel: DMA free:712kB min:160kB low:200kB
> high:240kB active:6672kB inactive:4108kB present:16256kB
pages_scanned:0
> all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 142 142
> Jul 23 13:31:52 Mimosa kernel: Normal free:1484kB min:1448kB
low:1808kB
> high:2172kB active:81556kB inactive:42556kB present:146304kB
> pages_scanned:0 all_unreclaimable? no
> Jul 23 13:31:52 Mimosa kernel: lowmem_reserve[]: 0 0 0
> Jul 23 13:31:52 Mimosa kernel: DMA: 36*4kB 7*8kB 0*16kB 0*32kB 0*64kB
> 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 712kB
> Jul 23 13:31:52 Mimosa kernel: Normal: 107*4kB 50*8kB 25*16kB 2*32kB
> 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1484kB
> Jul 23 13:31:52 Mimosa kernel: 16957 total pagecache pages
> Jul 23 13:31:52 Mimosa kernel: Swap cache: add 1207, delete 597, find
> 294/388
> Jul 23 13:31:52 Mimosa kernel: Free swap  = 327924kB
> Jul 23 13:31:52 Mimosa kernel: Total swap = 330584kB
> Jul 23 13:31:52 Mimosa kernel: 40960 pages of RAM
> Jul 23 13:31:52 Mimosa kernel: 0 pages of HIGHMEM
> Jul 23 13:31:52 Mimosa kernel: 1107 reserved pages
> Jul 23 13:31:52 Mimosa kernel: 15201 pages shared
> Jul 23 13:31:52 Mimosa kernel: 610 pages swap cached
> Jul 23 13:31:52 Mimosa kernel: 42 pages dirty
> Jul 23 13:31:52 Mimosa kernel: 0 pages writeback
> Jul 23 13:31:52 Mimosa kernel: 1094 pages mapped
> Jul 23 13:31:52 Mimosa kernel: 4400 pages slab
> Jul 23 13:31:52 Mimosa kernel: 221 pages pagetables
>
> Here is .config
>
> #
> # Automatically generated make config: don't edit
> # Linux kernel version: 2.6.26
> # Mon Jul 14 15:22:23 2008
> #
> # CONFIG_64BIT is not set
> CONFIG_X86_32=y
> # CONFIG_X86_64 is not set
> CONFIG_X86=y
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
> # CONFIG_GENERIC_LOCKBREAK is not set
> CONFIG_GENERIC_TIME=y
> CONFIG_GENERIC_CMOS_UPDATE=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_FAST_CMPXCHG_LOCAL=y
> CONFIG_MMU=y
> CONFIG_ZONE_DMA=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_HWEIGHT=y
> # CONFIG_GENERIC_GPIO is not set
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> # CONFIG_ARCH_HAS_ILOG2_U32 is not set
> # CONFIG_ARCH_HAS_ILOG2_U64 is not set
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> # CONFIG_GENERIC_TIME_VSYSCALL is not set
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> # CONFIG_HAVE_SETUP_PER_CPU_AREA is not set
> # CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> # CONFIG_ZONE_DMA32 is not set
> CONFIG_ARCH_POPULATES_NODE_MAP=y
> # CONFIG_AUDIT_ARCH is not set
> CONFIG_ARCH_SUPPORTS_AOUT=y
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_X86_BIOS_REBOOT=y
> CONFIG_KTIME_SCALAR=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
>
> #
> # General setup
> #
> # CONFIG_EXPERIMENTAL is not set
> CONFIG_BROKEN_ON_SMP=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_LOCALVERSION=""
> # CONFIG_LOCALVERSION_AUTO is not set
> CONFIG_SWAP=y
> CONFIG_SYSVIPC=y
> CONFIG_SYSVIPC_SYSCTL=y
> CONFIG_BSD_PROCESS_ACCT=y
> # CONFIG_BSD_PROCESS_ACCT_V3 is not set
> # CONFIG_TASKSTATS is not set
> # CONFIG_AUDIT is not set
> # CONFIG_IKCONFIG is not set
> CONFIG_LOG_BUF_SHIFT=14
> # CONFIG_CGROUPS is not set
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> # CONFIG_SYSFS_DEPRECATED_V2 is not set
> # CONFIG_RELAY is not set
> CONFIG_NAMESPACES=y
> # CONFIG_UTS_NS is not set
> # CONFIG_IPC_NS is not set
> # CONFIG_BLK_DEV_INITRD is not set
> CONFIG_CC_OPTIMIZE_FOR_SIZE=y
> CONFIG_SYSCTL=y
> # CONFIG_EMBEDDED is not set
> CONFIG_UID16=y
> CONFIG_SYSCTL_SYSCALL=y
> CONFIG_SYSCTL_SYSCALL_CHECK=y
> CONFIG_KALLSYMS=y
> # CONFIG_KALLSYMS_EXTRA_PASS is not set
> CONFIG_HOTPLUG=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> CONFIG_PCSPKR_PLATFORM=y
> CONFIG_COMPAT_BRK=y
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_ANON_INODES=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_SLUB_DEBUG=y
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_SLOB is not set
> # CONFIG_PROFILING is not set
> # CONFIG_MARKERS is not set
> CONFIG_HAVE_OPROFILE=y
> # CONFIG_KPROBES is not set
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> # CONFIG_HAVE_DMA_ATTRS is not set
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> # CONFIG_TINY_SHMEM is not set
> CONFIG_BASE_SMALL=0
> CONFIG_MODULES=y
> # CONFIG_MODULE_FORCE_LOAD is not set
> CONFIG_MODULE_UNLOAD=y
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> # CONFIG_KMOD is not set
> CONFIG_BLOCK=y
> # CONFIG_LBD is not set
> # CONFIG_BLK_DEV_IO_TRACE is not set
> # CONFIG_LSF is not set
>
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=y
> # CONFIG_IOSCHED_AS is not set
> # CONFIG_IOSCHED_DEADLINE is not set
> # CONFIG_IOSCHED_CFQ is not set
> # CONFIG_DEFAULT_AS is not set
> # CONFIG_DEFAULT_DEADLINE is not set
> # CONFIG_DEFAULT_CFQ is not set
> CONFIG_DEFAULT_NOOP=y
> CONFIG_DEFAULT_IOSCHED="noop"
> CONFIG_CLASSIC_RCU=y
>
> #
> # Processor type and features
> #
> # CONFIG_TICK_ONESHOT is not set
> # CONFIG_NO_HZ is not set
> # CONFIG_HIGH_RES_TIMERS is not set
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> # CONFIG_SMP is not set
> CONFIG_X86_PC=y
> # CONFIG_X86_ELAN is not set
> # CONFIG_X86_VOYAGER is not set
> # CONFIG_X86_NUMAQ is not set
> # CONFIG_X86_SUMMIT is not set
> # CONFIG_X86_BIGSMP is not set
> # CONFIG_X86_VISWS is not set
> # CONFIG_X86_GENERICARCH is not set
> # CONFIG_X86_ES7000 is not set
> # CONFIG_X86_RDC321X is not set
> # CONFIG_X86_VSMP is not set
> # CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER is not set
> # CONFIG_PARAVIRT_GUEST is not set
> # CONFIG_M386 is not set
> # CONFIG_M486 is not set
> # CONFIG_M586 is not set
> # CONFIG_M586TSC is not set
> # CONFIG_M586MMX is not set
> # CONFIG_M686 is not set
> CONFIG_MPENTIUMII=y
> # CONFIG_MPENTIUMIII is not set
> # CONFIG_MPENTIUMM is not set
> # CONFIG_MPENTIUM4 is not set
> # CONFIG_MK6 is not set
> # CONFIG_MK7 is not set
> # CONFIG_MK8 is not set
> # CONFIG_MCRUSOE is not set
> # CONFIG_MEFFICEON is not set
> # CONFIG_MWINCHIPC6 is not set
> # CONFIG_MWINCHIP2 is not set
> # CONFIG_MWINCHIP3D is not set
> # CONFIG_MGEODEGX1 is not set
> # CONFIG_MGEODE_LX is not set
> # CONFIG_MCYRIXIII is not set
> # CONFIG_MVIAC3_2 is not set
> # CONFIG_MVIAC7 is not set
> # CONFIG_MPSC is not set
> # CONFIG_MCORE2 is not set
> # CONFIG_GENERIC_CPU is not set
> # CONFIG_X86_GENERIC is not set
> CONFIG_X86_CPU=y
> CONFIG_X86_CMPXCHG=y
> CONFIG_X86_L1_CACHE_SHIFT=5
> CONFIG_X86_XADD=y
> CONFIG_X86_WP_WORKS_OK=y
> CONFIG_X86_INVLPG=y
> CONFIG_X86_BSWAP=y
> CONFIG_X86_POPAD_OK=y
> CONFIG_X86_GOOD_APIC=y
> CONFIG_X86_INTEL_USERCOPY=y
> CONFIG_X86_USE_PPRO_CHECKSUM=y
> CONFIG_X86_P6_NOP=y
> CONFIG_X86_TSC=y
> CONFIG_X86_CMOV=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=6
> CONFIG_X86_DEBUGCTLMSR=y
> # CONFIG_HPET_TIMER is not set
> CONFIG_DMI=y
> # CONFIG_IOMMU_HELPER is not set
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_X86_UP_APIC=y
> CONFIG_X86_UP_IOAPIC=y
> CONFIG_X86_LOCAL_APIC=y
> CONFIG_X86_IO_APIC=y
> # CONFIG_X86_MCE is not set
> CONFIG_VM86=y
> # CONFIG_TOSHIBA is not set
> # CONFIG_I8K is not set
> # CONFIG_X86_REBOOTFIXUPS is not set
> # CONFIG_MICROCODE is not set
> # CONFIG_X86_MSR is not set
> # CONFIG_X86_CPUID is not set
> CONFIG_NOHIGHMEM=y
> # CONFIG_HIGHMEM4G is not set
> # CONFIG_HIGHMEM64G is not set
> CONFIG_PAGE_OFFSET=0xC0000000
> # CONFIG_X86_PAE is not set
> CONFIG_FLATMEM=y
> CONFIG_FLAT_NODE_MEM_MAP=y
> # CONFIG_SPARSEMEM_STATIC is not set
> # CONFIG_SPARSEMEM_VMEMMAP_ENABLE is not set
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_SPLIT_PTLOCK_CPUS=4
> # CONFIG_RESOURCES_64BIT is not set
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> # CONFIG_MATH_EMULATION is not set
> # CONFIG_MTRR is not set
> # CONFIG_EFI is not set
> CONFIG_SECCOMP=y
> # CONFIG_HZ_100 is not set
> CONFIG_HZ_250=y
> # CONFIG_HZ_300 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=250
> # CONFIG_SCHED_HRTICK is not set
> # CONFIG_KEXEC is not set
> CONFIG_PHYSICAL_START=0x100000
> CONFIG_PHYSICAL_ALIGN=0x100000
> CONFIG_COMPAT_VDSO=y
>
> #
> # Power management options
> #
> CONFIG_PM=y
> # CONFIG_PM_DEBUG is not set
> # CONFIG_SUSPEND is not set
> # CONFIG_HIBERNATION is not set
> CONFIG_ACPI=y
> # CONFIG_ACPI_PROCFS is not set
> # CONFIG_ACPI_PROCFS_POWER is not set
> # CONFIG_ACPI_SYSFS_POWER is not set
> # CONFIG_ACPI_PROC_EVENT is not set
> # CONFIG_ACPI_AC is not set
> # CONFIG_ACPI_BATTERY is not set
> # CONFIG_ACPI_BUTTON is not set
> # CONFIG_ACPI_FAN is not set
> # CONFIG_ACPI_PROCESSOR is not set
> # CONFIG_ACPI_ASUS is not set
> # CONFIG_ACPI_TOSHIBA is not set
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> CONFIG_ACPI_BLACKLIST_YEAR=0
> # CONFIG_ACPI_DEBUG is not set
> CONFIG_ACPI_EC=y
> CONFIG_ACPI_POWER=y
> CONFIG_ACPI_SYSTEM=y
> CONFIG_X86_PM_TIMER=y
> # CONFIG_ACPI_SBS is not set
>
> #
> # CPU Frequency scaling
> #
> # CONFIG_CPU_FREQ is not set
> # CONFIG_CPU_IDLE is not set
>
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=y
> # CONFIG_PCI_GOBIOS is not set
> # CONFIG_PCI_GOMMCONFIG is not set
> # CONFIG_PCI_GODIRECT is not set
> # CONFIG_PCI_GOOLPC is not set
> CONFIG_PCI_GOANY=y
> CONFIG_PCI_BIOS=y
> CONFIG_PCI_DIRECT=y
> CONFIG_PCI_MMCONFIG=y
> CONFIG_PCI_DOMAINS=y
> # CONFIG_PCIEPORTBUS is not set
> CONFIG_ARCH_SUPPORTS_MSI=y
> # CONFIG_PCI_MSI is not set
> # CONFIG_PCI_LEGACY is not set
> # CONFIG_HT_IRQ is not set
> CONFIG_ISA_DMA_API=y
> # CONFIG_ISA is not set
> # CONFIG_MCA is not set
> # CONFIG_SCx200 is not set
> # CONFIG_OLPC is not set
> # CONFIG_PCCARD is not set
> # CONFIG_HOTPLUG_PCI is not set
>
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=y
> # CONFIG_BINFMT_AOUT is not set
> # CONFIG_BINFMT_MISC is not set
>
> #
> # Networking
> #
> CONFIG_NET=y
>
> #
> # Networking options
> #
> CONFIG_PACKET=y
> CONFIG_PACKET_MMAP=y
> CONFIG_UNIX=y
> CONFIG_XFRM=y
> CONFIG_XFRM_USER=y
> CONFIG_NET_KEY=y
> CONFIG_INET=y
> # CONFIG_IP_MULTICAST is not set
> CONFIG_IP_ADVANCED_ROUTER=y
> CONFIG_ASK_IP_FIB_HASH=y
> # CONFIG_IP_FIB_TRIE is not set
> CONFIG_IP_FIB_HASH=y
> CONFIG_IP_MULTIPLE_TABLES=y
> CONFIG_IP_ROUTE_MULTIPATH=y
> CONFIG_IP_ROUTE_VERBOSE=y
> # CONFIG_IP_PNP is not set
> # CONFIG_NET_IPIP is not set
> # CONFIG_NET_IPGRE is not set
> CONFIG_SYN_COOKIES=y
> # CONFIG_INET_AH is not set
> CONFIG_INET_ESP=y
> CONFIG_INET_IPCOMP=y
> CONFIG_INET_XFRM_TUNNEL=y
> CONFIG_INET_TUNNEL=y
> CONFIG_INET_XFRM_MODE_TRANSPORT=y
> CONFIG_INET_XFRM_MODE_TUNNEL=y
> # CONFIG_INET_XFRM_MODE_BEET is not set
> # CONFIG_INET_LRO is not set
> CONFIG_INET_DIAG=y
> CONFIG_INET_TCP_DIAG=y
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_DEFAULT_TCP_CONG="cubic"
> # CONFIG_IP_VS is not set
> # CONFIG_IPV6 is not set
> # CONFIG_NETWORK_SECMARK is not set
> CONFIG_NETFILTER=y
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=y
>
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=m
> CONFIG_NETFILTER_NETLINK_QUEUE=m
> CONFIG_NETFILTER_NETLINK_LOG=m
> CONFIG_NF_CONNTRACK=y
> CONFIG_NF_CT_ACCT=y
> CONFIG_NF_CONNTRACK_MARK=y
> # CONFIG_NF_CONNTRACK_EVENTS is not set
> CONFIG_NF_CT_PROTO_GRE=m
> CONFIG_NF_CT_PROTO_UDPLITE=m
> # CONFIG_NF_CONNTRACK_AMANDA is not set
> CONFIG_NF_CONNTRACK_FTP=m
> CONFIG_NF_CONNTRACK_H323=m
> # CONFIG_NF_CONNTRACK_IRC is not set
> CONFIG_NF_CONNTRACK_NETBIOS_NS=m
> CONFIG_NF_CONNTRACK_PPTP=m
> CONFIG_NF_CONNTRACK_SIP=m
> # CONFIG_NF_CONNTRACK_TFTP is not set
> # CONFIG_NF_CT_NETLINK is not set
> CONFIG_NETFILTER_XTABLES=y
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
> CONFIG_NETFILTER_XT_TARGET_DSCP=m
> CONFIG_NETFILTER_XT_TARGET_MARK=y
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
> CONFIG_NETFILTER_XT_TARGET_NFLOG=m
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
> CONFIG_NETFILTER_XT_TARGET_RATEEST=m
> CONFIG_NETFILTER_XT_TARGET_TRACE=m
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
> CONFIG_NETFILTER_XT_MATCH_COMMENT=m
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
> CONFIG_NETFILTER_XT_MATCH_DCCP=m
> CONFIG_NETFILTER_XT_MATCH_DSCP=m
> CONFIG_NETFILTER_XT_MATCH_ESP=m
> CONFIG_NETFILTER_XT_MATCH_HELPER=y
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
> CONFIG_NETFILTER_XT_MATCH_LENGTH=m
> CONFIG_NETFILTER_XT_MATCH_LIMIT=y
> CONFIG_NETFILTER_XT_MATCH_MAC=m
> CONFIG_NETFILTER_XT_MATCH_MARK=y
> CONFIG_NETFILTER_XT_MATCH_OWNER=m
> CONFIG_NETFILTER_XT_MATCH_POLICY=y
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
> CONFIG_NETFILTER_XT_MATCH_QUOTA=m
> CONFIG_NETFILTER_XT_MATCH_RATEEST=m
> CONFIG_NETFILTER_XT_MATCH_REALM=m
> CONFIG_NETFILTER_XT_MATCH_STATE=y
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
> CONFIG_NETFILTER_XT_MATCH_STRING=m
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
> CONFIG_NETFILTER_XT_MATCH_TIME=m
> CONFIG_NETFILTER_XT_MATCH_U32=m
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
>
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_CONNTRACK_IPV4=y
> # CONFIG_NF_CONNTRACK_PROC_COMPAT is not set
> # CONFIG_IP_NF_QUEUE is not set
> CONFIG_IP_NF_IPTABLES=y
> # CONFIG_IP_NF_MATCH_RECENT is not set
> CONFIG_IP_NF_MATCH_ECN=m
> # CONFIG_IP_NF_MATCH_AH is not set
> CONFIG_IP_NF_MATCH_TTL=m
> CONFIG_IP_NF_MATCH_ADDRTYPE=m
> CONFIG_IP_NF_FILTER=y
> CONFIG_IP_NF_TARGET_REJECT=y
> CONFIG_IP_NF_TARGET_LOG=m
> CONFIG_IP_NF_TARGET_ULOG=m
> CONFIG_NF_NAT=y
> CONFIG_NF_NAT_NEEDED=y
> CONFIG_IP_NF_TARGET_MASQUERADE=m
> CONFIG_IP_NF_TARGET_REDIRECT=m
> CONFIG_IP_NF_TARGET_NETMAP=m
> # CONFIG_NF_NAT_SNMP_BASIC is not set
> CONFIG_NF_NAT_PROTO_GRE=m
> CONFIG_NF_NAT_PROTO_UDPLITE=m
> CONFIG_NF_NAT_FTP=m
> # CONFIG_NF_NAT_IRC is not set
> # CONFIG_NF_NAT_TFTP is not set
> # CONFIG_NF_NAT_AMANDA is not set
> CONFIG_NF_NAT_PPTP=m
> CONFIG_NF_NAT_H323=m
> CONFIG_NF_NAT_SIP=m
> CONFIG_IP_NF_MANGLE=y
> CONFIG_IP_NF_TARGET_ECN=m
> CONFIG_IP_NF_TARGET_TTL=m
> CONFIG_IP_NF_RAW=m
> CONFIG_IP_NF_ARPTABLES=m
> CONFIG_IP_NF_ARPFILTER=m
> CONFIG_IP_NF_ARP_MANGLE=m
> # CONFIG_ATM is not set
> # CONFIG_BRIDGE is not set
> # CONFIG_VLAN_8021Q is not set
> # CONFIG_DECNET is not set
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> CONFIG_NET_SCHED=y
>
> #
> # Queueing/Scheduling
> #
> # CONFIG_NET_SCH_CBQ is not set
> CONFIG_NET_SCH_HTB=m
> CONFIG_NET_SCH_HFSC=m
> CONFIG_NET_SCH_PRIO=m
> CONFIG_NET_SCH_RED=m
> CONFIG_NET_SCH_SFQ=m
> CONFIG_NET_SCH_TEQL=m
> CONFIG_NET_SCH_TBF=m
> CONFIG_NET_SCH_GRED=m
> CONFIG_NET_SCH_DSMARK=m
> # CONFIG_NET_SCH_NETEM is not set
> CONFIG_NET_SCH_INGRESS=m
>
> #
> # Classification
> #
> CONFIG_NET_CLS=y
> CONFIG_NET_CLS_BASIC=m
> CONFIG_NET_CLS_TCINDEX=m
> CONFIG_NET_CLS_ROUTE4=m
> CONFIG_NET_CLS_ROUTE=y
> CONFIG_NET_CLS_FW=m
> CONFIG_NET_CLS_U32=m
> CONFIG_CLS_U32_PERF=y
> CONFIG_CLS_U32_MARK=y
> CONFIG_NET_CLS_RSVP=m
> # CONFIG_NET_CLS_RSVP6 is not set
> CONFIG_NET_CLS_FLOW=m
> CONFIG_NET_EMATCH=y
> CONFIG_NET_EMATCH_STACK=32
> CONFIG_NET_EMATCH_CMP=m
> CONFIG_NET_EMATCH_NBYTE=m
> CONFIG_NET_EMATCH_U32=m
> CONFIG_NET_EMATCH_META=m
> CONFIG_NET_EMATCH_TEXT=m
> CONFIG_NET_CLS_ACT=y
> CONFIG_NET_ACT_POLICE=m
> CONFIG_NET_ACT_GACT=m
> CONFIG_GACT_PROB=y
> CONFIG_NET_ACT_MIRRED=m
> CONFIG_NET_ACT_IPT=m
> CONFIG_NET_ACT_NAT=m
> CONFIG_NET_ACT_PEDIT=m
> # CONFIG_NET_ACT_SIMP is not set
> # CONFIG_NET_CLS_IND is not set
> CONFIG_NET_SCH_FIFO=y
>
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> CONFIG_FIB_RULES=y
>
> #
> # Wireless
> #
> # CONFIG_CFG80211 is not set
> # CONFIG_WIRELESS_EXT is not set
> # CONFIG_MAC80211 is not set
> # CONFIG_IEEE80211 is not set
> # CONFIG_RFKILL is not set
>
> #
> # Device Drivers
> #
>
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> CONFIG_STANDALONE=y
> # CONFIG_PREVENT_FIRMWARE_BUILD is not set
> # CONFIG_FW_LOADER is not set
> # CONFIG_SYS_HYPERVISOR is not set
> # CONFIG_CONNECTOR is not set
> # CONFIG_MTD is not set
> # CONFIG_PARPORT is not set
> CONFIG_PNP=y
> # CONFIG_PNP_DEBUG is not set
>
> #
> # Protocols
> #
> CONFIG_PNPACPI=y
> CONFIG_BLK_DEV=y
> CONFIG_BLK_DEV_FD=m
> # CONFIG_BLK_CPQ_DA is not set
> # CONFIG_BLK_CPQ_CISS_DA is not set
> # CONFIG_BLK_DEV_DAC960 is not set
> # CONFIG_BLK_DEV_COW_COMMON is not set
> # CONFIG_BLK_DEV_LOOP is not set
> # CONFIG_BLK_DEV_NBD is not set
> # CONFIG_BLK_DEV_SX8 is not set
> # CONFIG_BLK_DEV_RAM is not set
> # CONFIG_CDROM_PKTCDVD is not set
> # CONFIG_ATA_OVER_ETH is not set
> # CONFIG_MISC_DEVICES is not set
> CONFIG_HAVE_IDE=y
> CONFIG_IDE=y
> CONFIG_BLK_DEV_IDE=y
>
> #
> # Please see Documentation/ide/ide.txt for help/info on IDE drives
> #
> # CONFIG_BLK_DEV_IDE_SATA is not set
> CONFIG_BLK_DEV_IDEDISK=y
> # CONFIG_IDEDISK_MULTI_MODE is not set
> CONFIG_BLK_DEV_IDECD=m
> CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
> # CONFIG_BLK_DEV_IDETAPE is not set
> # CONFIG_BLK_DEV_IDEFLOPPY is not set
> # CONFIG_BLK_DEV_IDEACPI is not set
> # CONFIG_IDE_TASK_IOCTL is not set
> # CONFIG_IDE_PROC_FS is not set
>
> #
> # IDE chipset support/bugfixes
> #
> # CONFIG_IDE_GENERIC is not set
> # CONFIG_BLK_DEV_PLATFORM is not set
> # CONFIG_BLK_DEV_CMD640 is not set
> # CONFIG_BLK_DEV_IDEPNP is not set
> CONFIG_BLK_DEV_IDEDMA_SFF=y
>
> #
> # PCI IDE chipsets support
> #
> CONFIG_BLK_DEV_IDEPCI=y
> # CONFIG_IDEPCI_PCIBUS_ORDER is not set
> # CONFIG_BLK_DEV_GENERIC is not set
> # CONFIG_BLK_DEV_RZ1000 is not set
> CONFIG_BLK_DEV_IDEDMA_PCI=y
> # CONFIG_BLK_DEV_AEC62XX is not set
> # CONFIG_BLK_DEV_ALI15X3 is not set
> # CONFIG_BLK_DEV_AMD74XX is not set
> # CONFIG_BLK_DEV_ATIIXP is not set
> # CONFIG_BLK_DEV_CMD64X is not set
> # CONFIG_BLK_DEV_TRIFLEX is not set
> # CONFIG_BLK_DEV_CY82C693 is not set
> # CONFIG_BLK_DEV_CS5530 is not set
> # CONFIG_BLK_DEV_CS5535 is not set
> # CONFIG_BLK_DEV_HPT34X is not set
> # CONFIG_BLK_DEV_HPT366 is not set
> # CONFIG_BLK_DEV_JMICRON is not set
> # CONFIG_BLK_DEV_SC1200 is not set
> CONFIG_BLK_DEV_PIIX=y
> # CONFIG_BLK_DEV_IT8213 is not set
> # CONFIG_BLK_DEV_IT821X is not set
> # CONFIG_BLK_DEV_NS87415 is not set
> # CONFIG_BLK_DEV_PDC202XX_OLD is not set
> # CONFIG_BLK_DEV_PDC202XX_NEW is not set
> # CONFIG_BLK_DEV_SVWKS is not set
> # CONFIG_BLK_DEV_SIIMAGE is not set
> # CONFIG_BLK_DEV_SIS5513 is not set
> # CONFIG_BLK_DEV_SLC90E66 is not set
> # CONFIG_BLK_DEV_TRM290 is not set
> # CONFIG_BLK_DEV_VIA82CXXX is not set
> # CONFIG_BLK_DEV_TC86C001 is not set
> CONFIG_BLK_DEV_IDEDMA=y
> # CONFIG_BLK_DEV_HD_ONLY is not set
> # CONFIG_BLK_DEV_HD is not set
>
> #
> # SCSI device support
> #
> # CONFIG_RAID_ATTRS is not set
> # CONFIG_SCSI is not set
> # CONFIG_SCSI_DMA is not set
> # CONFIG_SCSI_NETLINK is not set
> # CONFIG_ATA is not set
> # CONFIG_MD is not set
> # CONFIG_FUSION is not set
>
> #
> # IEEE 1394 (FireWire) support
> #
>
> #
> # A new alternative FireWire stack is available with EXPERIMENTAL=y
> #
> # CONFIG_IEEE1394 is not set
> # CONFIG_I2O is not set
> # CONFIG_MACINTOSH_DRIVERS is not set
> CONFIG_NETDEVICES=y
> # CONFIG_NETDEVICES_MULTIQUEUE is not set
> CONFIG_IFB=m
> # CONFIG_DUMMY is not set
> # CONFIG_BONDING is not set
> # CONFIG_EQUALIZER is not set
> CONFIG_TUN=m
> # CONFIG_VETH is not set
> # CONFIG_NET_SB1000 is not set
> # CONFIG_ARCNET is not set
> # CONFIG_PHYLIB is not set
> CONFIG_NET_ETHERNET=y
> CONFIG_MII=m
> # CONFIG_HAPPYMEAL is not set
> # CONFIG_SUNGEM is not set
> # CONFIG_CASSINI is not set
> CONFIG_NET_VENDOR_3COM=y
> CONFIG_VORTEX=m
> CONFIG_TYPHOON=m
> # CONFIG_NET_TULIP is not set
> # CONFIG_HP100 is not set
> # CONFIG_IBM_NEW_EMAC_ZMII is not set
> # CONFIG_IBM_NEW_EMAC_RGMII is not set
> # CONFIG_IBM_NEW_EMAC_TAH is not set
> # CONFIG_IBM_NEW_EMAC_EMAC4 is not set
> CONFIG_NET_PCI=y
> # CONFIG_PCNET32 is not set
> # CONFIG_AMD8111_ETH is not set
> # CONFIG_ADAPTEC_STARFIRE is not set
> # CONFIG_B44 is not set
> # CONFIG_FORCEDETH is not set
> # CONFIG_EEPRO100 is not set
> CONFIG_E100=m
> # CONFIG_FEALNX is not set
> # CONFIG_NATSEMI is not set
> # CONFIG_NE2K_PCI is not set
> # CONFIG_8139TOO is not set
> # CONFIG_R6040 is not set
> # CONFIG_SIS900 is not set
> # CONFIG_EPIC100 is not set
> # CONFIG_SUNDANCE is not set
> # CONFIG_TLAN is not set
> # CONFIG_VIA_RHINE is not set
> # CONFIG_NETDEV_1000 is not set
> # CONFIG_NETDEV_10000 is not set
> # CONFIG_TR is not set
>
> #
> # Wireless LAN
> #
> # CONFIG_WLAN_PRE80211 is not set
> # CONFIG_WLAN_80211 is not set
> # CONFIG_IWLWIFI_LEDS is not set
> # CONFIG_WAN is not set
> # CONFIG_FDDI is not set
> # CONFIG_PPP is not set
> # CONFIG_SLIP is not set
> # CONFIG_NETPOLL is not set
> # CONFIG_NET_POLL_CONTROLLER is not set
> # CONFIG_ISDN is not set
> # CONFIG_PHONE is not set
>
> #
> # Input device support
> #
> CONFIG_INPUT=y
> # CONFIG_INPUT_FF_MEMLESS is not set
> # CONFIG_INPUT_POLLDEV is not set
>
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=y
> # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> # CONFIG_INPUT_JOYDEV is not set
> # CONFIG_INPUT_EVDEV is not set
> # CONFIG_INPUT_EVBUG is not set
>
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=y
> CONFIG_KEYBOARD_ATKBD=y
> # CONFIG_KEYBOARD_SUNKBD is not set
> # CONFIG_KEYBOARD_LKKBD is not set
> # CONFIG_KEYBOARD_XTKBD is not set
> # CONFIG_KEYBOARD_NEWTON is not set
> # CONFIG_KEYBOARD_STOWAWAY is not set
> # CONFIG_INPUT_MOUSE is not set
> # CONFIG_INPUT_JOYSTICK is not set
> # CONFIG_INPUT_TABLET is not set
> # CONFIG_INPUT_TOUCHSCREEN is not set
> # CONFIG_INPUT_MISC is not set
>
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> # CONFIG_SERIO_SERPORT is not set
> # CONFIG_SERIO_CT82C710 is not set
> # CONFIG_SERIO_PCIPS2 is not set
> CONFIG_SERIO_LIBPS2=y
> # CONFIG_SERIO_RAW is not set
> # CONFIG_GAMEPORT is not set
>
> #
> # Character devices
> #
> CONFIG_VT=y
> CONFIG_VT_CONSOLE=y
> CONFIG_HW_CONSOLE=y
> # CONFIG_VT_HW_CONSOLE_BINDING is not set
> # CONFIG_DEVKMEM is not set
> # CONFIG_SERIAL_NONSTANDARD is not set
>
> #
> # Serial drivers
> #
> # CONFIG_SERIAL_8250 is not set
> CONFIG_FIX_EARLYCON_MEM=y
>
> #
> # Non-8250 serial port support
> #
> # CONFIG_SERIAL_JSM is not set
> CONFIG_UNIX98_PTYS=y
> # CONFIG_LEGACY_PTYS is not set
> # CONFIG_IPMI_HANDLER is not set
> # CONFIG_HW_RANDOM is not set
> # CONFIG_NVRAM is not set
> # CONFIG_RTC is not set
> # CONFIG_GEN_RTC is not set
> # CONFIG_R3964 is not set
> # CONFIG_APPLICOM is not set
> # CONFIG_MWAVE is not set
> # CONFIG_PC8736x_GPIO is not set
> # CONFIG_NSC_GPIO is not set
> # CONFIG_CS5535_GPIO is not set
> # CONFIG_RAW_DRIVER is not set
> # CONFIG_HPET is not set
> # CONFIG_HANGCHECK_TIMER is not set
> CONFIG_DEVPORT=y
> # CONFIG_I2C is not set
> # CONFIG_SPI is not set
> # CONFIG_W1 is not set
> # CONFIG_POWER_SUPPLY is not set
> # CONFIG_HWMON is not set
> # CONFIG_THERMAL is not set
> # CONFIG_THERMAL_HWMON is not set
> # CONFIG_WATCHDOG is not set
>
> #
> # Sonics Silicon Backplane
> #
> CONFIG_SSB_POSSIBLE=y
> # CONFIG_SSB is not set
>
> #
> # Multifunction device drivers
> #
> # CONFIG_MFD_SM501 is not set
> # CONFIG_HTC_PASIC3 is not set
>
> #
> # Multimedia devices
> #
>
> #
> # Multimedia core support
> #
> # CONFIG_VIDEO_DEV is not set
> # CONFIG_DVB_CORE is not set
> # CONFIG_VIDEO_MEDIA is not set
>
> #
> # Multimedia drivers
> #
> # CONFIG_DAB is not set
>
> #
> # Graphics support
> #
> # CONFIG_AGP is not set
> # CONFIG_DRM is not set
> # CONFIG_VGASTATE is not set
> # CONFIG_VIDEO_OUTPUT_CONTROL is not set
> # CONFIG_FB is not set
> # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
>
> #
> # Display device support
> #
> # CONFIG_DISPLAY_SUPPORT is not set
>
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=y
> # CONFIG_VGACON_SOFT_SCROLLBACK is not set
> # CONFIG_VIDEO_SELECT is not set
> CONFIG_DUMMY_CONSOLE=y
>
> #
> # Sound
> #
> # CONFIG_SOUND is not set
> # CONFIG_HID_SUPPORT is not set
> # CONFIG_USB_SUPPORT is not set
> # CONFIG_MMC is not set
> # CONFIG_MEMSTICK is not set
> # CONFIG_NEW_LEDS is not set
> # CONFIG_ACCESSIBILITY is not set
> # CONFIG_INFINIBAND is not set
> # CONFIG_RTC_CLASS is not set
> # CONFIG_DMADEVICES is not set
> # CONFIG_UIO is not set
>
> #
> # Firmware Drivers
> #
> # CONFIG_EDD is not set
> # CONFIG_DELL_RBU is not set
> # CONFIG_DCDBAS is not set
> # CONFIG_DMIID is not set
> # CONFIG_ISCSI_IBFT_FIND is not set
>
> #
> # File systems
> #
> CONFIG_EXT2_FS=m
> # CONFIG_EXT2_FS_XATTR is not set
> # CONFIG_EXT2_FS_XIP is not set
> # CONFIG_EXT3_FS is not set
> # CONFIG_REISERFS_FS is not set
> # CONFIG_JFS_FS is not set
> # CONFIG_FS_POSIX_ACL is not set
> CONFIG_XFS_FS=y
> # CONFIG_XFS_QUOTA is not set
> # CONFIG_XFS_POSIX_ACL is not set
> # CONFIG_XFS_RT is not set
> # CONFIG_OCFS2_FS is not set
> # CONFIG_DNOTIFY is not set
> CONFIG_INOTIFY=y
> CONFIG_INOTIFY_USER=y
> # CONFIG_QUOTA is not set
> # CONFIG_AUTOFS_FS is not set
> # CONFIG_AUTOFS4_FS is not set
> # CONFIG_FUSE_FS is not set
>
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=m
> # CONFIG_JOLIET is not set
> # CONFIG_ZISOFS is not set
> # CONFIG_UDF_FS is not set
>
> #
> # DOS/FAT/NT Filesystems
> #
> # CONFIG_MSDOS_FS is not set
> # CONFIG_VFAT_FS is not set
> # CONFIG_NTFS_FS is not set
>
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=y
> # CONFIG_PROC_KCORE is not set
> CONFIG_PROC_SYSCTL=y
> CONFIG_SYSFS=y
> # CONFIG_TMPFS is not set
> # CONFIG_HUGETLBFS is not set
> # CONFIG_HUGETLB_PAGE is not set
> # CONFIG_CONFIGFS_FS is not set
>
> #
> # Miscellaneous filesystems
> #
> # CONFIG_HFSPLUS_FS is not set
> # CONFIG_CRAMFS is not set
> # CONFIG_VXFS_FS is not set
> # CONFIG_MINIX_FS is not set
> # CONFIG_HPFS_FS is not set
> # CONFIG_QNX4FS_FS is not set
> # CONFIG_ROMFS_FS is not set
> # CONFIG_SYSV_FS is not set
> # CONFIG_UFS_FS is not set
> # CONFIG_NETWORK_FILESYSTEMS is not set
>
> #
> # Partition Types
> #
> # CONFIG_PARTITION_ADVANCED is not set
> CONFIG_MSDOS_PARTITION=y
> # CONFIG_NLS is not set
>
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> # CONFIG_PRINTK_TIME is not set
> # CONFIG_ENABLE_WARN_DEPRECATED is not set
> # CONFIG_ENABLE_MUST_CHECK is not set
> CONFIG_FRAME_WARN=1024
> # CONFIG_MAGIC_SYSRQ is not set
> # CONFIG_UNUSED_SYMBOLS is not set
> # CONFIG_DEBUG_FS is not set
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_KERNEL is not set
> # CONFIG_SLUB_DEBUG_ON is not set
> # CONFIG_SLUB_STATS is not set
> CONFIG_DEBUG_BUGVERBOSE=y
> # CONFIG_LATENCYTOP is not set
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=y
> # CONFIG_NONPROMISC_DEVMEM is not set
> CONFIG_EARLY_PRINTK=y
> # CONFIG_4KSTACKS is not set
> CONFIG_X86_FIND_SMP_CONFIG=y
> CONFIG_X86_MPPARSE=y
> CONFIG_DOUBLEFAULT=y
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> CONFIG_IO_DELAY_0X80=y
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=0
>
> #
> # Security options
> #
> # CONFIG_KEYS is not set
> # CONFIG_SECURITY is not set
> CONFIG_CRYPTO=y
>
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_ALGAPI=y
> CONFIG_CRYPTO_AEAD=y
> CONFIG_CRYPTO_BLKCIPHER=y
> CONFIG_CRYPTO_HASH=y
> CONFIG_CRYPTO_MANAGER=y
> # CONFIG_CRYPTO_NULL is not set
> # CONFIG_CRYPTO_CRYPTD is not set
> CONFIG_CRYPTO_AUTHENC=y
> # CONFIG_CRYPTO_TEST is not set
>
> #
> # Authenticated Encryption with Associated Data
> #
> # CONFIG_CRYPTO_CCM is not set
> # CONFIG_CRYPTO_GCM is not set
> # CONFIG_CRYPTO_SEQIV is not set
>
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=y
> # CONFIG_CRYPTO_CTR is not set
> # CONFIG_CRYPTO_CTS is not set
> CONFIG_CRYPTO_ECB=m
> # CONFIG_CRYPTO_PCBC is not set
>
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=y
>
> #
> # Digest
> #
> # CONFIG_CRYPTO_CRC32C is not set
> # CONFIG_CRYPTO_MD4 is not set
> CONFIG_CRYPTO_MD5=y
> # CONFIG_CRYPTO_MICHAEL_MIC is not set
> CONFIG_CRYPTO_SHA1=y
> CONFIG_CRYPTO_SHA256=y
> CONFIG_CRYPTO_SHA512=y
> # CONFIG_CRYPTO_TGR192 is not set
> # CONFIG_CRYPTO_WP512 is not set
>
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=y
> CONFIG_CRYPTO_AES_586=y
> # CONFIG_CRYPTO_ANUBIS is not set
> # CONFIG_CRYPTO_ARC4 is not set
> CONFIG_CRYPTO_BLOWFISH=m
> # CONFIG_CRYPTO_CAMELLIA is not set
> # CONFIG_CRYPTO_CAST5 is not set
> # CONFIG_CRYPTO_CAST6 is not set
> CONFIG_CRYPTO_DES=y
> # CONFIG_CRYPTO_FCRYPT is not set
> # CONFIG_CRYPTO_KHAZAD is not set
> # CONFIG_CRYPTO_SEED is not set
> CONFIG_CRYPTO_SERPENT=m
> # CONFIG_CRYPTO_TEA is not set
> # CONFIG_CRYPTO_TWOFISH is not set
> CONFIG_CRYPTO_TWOFISH_COMMON=m
> CONFIG_CRYPTO_TWOFISH_586=m
>
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=y
> CONFIG_CRYPTO_LZO=m
> # CONFIG_CRYPTO_HW is not set
> CONFIG_HAVE_KVM=y
> # CONFIG_VIRTUALIZATION is not set
>
> #
> # Library routines
> #
> CONFIG_BITREVERSE=m
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_FIND_NEXT_BIT=y
> CONFIG_CRC_CCITT=m
> CONFIG_CRC16=m
> # CONFIG_CRC_ITU_T is not set
> CONFIG_CRC32=m
> # CONFIG_CRC7 is not set
> CONFIG_LIBCRC32C=m
> CONFIG_ZLIB_INFLATE=y
> CONFIG_ZLIB_DEFLATE=y
> CONFIG_LZO_COMPRESS=m
> CONFIG_LZO_DECOMPRESS=m
> CONFIG_TEXTSEARCH=y
> CONFIG_TEXTSEARCH_KMP=m
> CONFIG_TEXTSEARCH_BM=m
> CONFIG_TEXTSEARCH_FSM=m
> CONFIG_PLIST=y
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
>
>


