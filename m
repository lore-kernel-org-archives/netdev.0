From: Dave Jones <davej@redhat.com>
Subject: r8169: DMA-API: exceeded 7 overlapping mappings of pfn 943ad
Date: Thu, 30 Jan 2014 11:01:13 -0500
Message-ID: <20140130160113.GA18779@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209AbaA3QBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 11:01:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
DMA-API: exceeded 7 overlapping mappings of pfn 943ad
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_conntrack nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel microcode pcspkr r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit drm_kms_helper drm video backlight
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0+ #10
Hardware name: Shuttle Inc. SH87R/FH87, BIOS 1.02 06/26/2013
 0000000000000009 62a5d1f597ade7cd ffff88013ac03910 ffffffff8157a0ca
 ffff88013ac03958 ffff88013ac03948 ffffffff8105c343 00000000000943ad
 ffff8800b198ce38 0000000000000286 ffffffff828acb40 0000000000000286
Call Trace:
 <IRQ>  [<ffffffff8157a0ca>] dump_stack+0x4d/0x66
 [<ffffffff8105c343>] warn_slowpath_common+0x73/0x90
 [<ffffffff8105c3b7>] warn_slowpath_fmt+0x57/0x80
 [<ffffffff812bf60d>] ? active_pfn_read_overlap+0x2d/0x50
 [<ffffffff812bfbd7>] add_dma_entry+0x127/0x130
 [<ffffffff812bff0a>] debug_dma_map_page+0x11a/0x140
 [<ffffffffa01ebaae>] rtl8169_start_xmit+0x1fe/0xac0 [r8169]
 [<ffffffff810a81bf>] ? lock_release_holdtime.part.30+0xf/0x190
 [<ffffffff8146b3f0>] ? dev_queue_xmit_nit+0x170/0x3d0
 [<ffffffff8146d69b>] dev_hard_start_xmit+0x2cb/0x4c0
 [<ffffffff8148e3de>] sch_direct_xmit+0xee/0x280
 [<ffffffff8146da90>] __dev_queue_xmit+0x200/0x770
 [<ffffffff8146d890>] ? dev_hard_start_xmit+0x4c0/0x4c0
 [<ffffffff8146e00b>] dev_queue_xmit+0xb/0x10
 [<ffffffff8147912a>] neigh_resolve_output+0x17a/0x2e0
 [<ffffffff814a87f0>] ? ip_finish_output+0x3f0/0x8e0
 [<ffffffff814a87f0>] ip_finish_output+0x3f0/0x8e0
 [<ffffffff814a8666>] ? ip_finish_output+0x266/0x8e0
 [<ffffffff814aa427>] ip_output+0x57/0xf0
 [<ffffffff814a5121>] ip_forward_finish+0x71/0x1c0
 [<ffffffff814a5483>] ip_forward+0x213/0x590
 [<ffffffff814a3030>] ip_rcv_finish+0x140/0x570
 [<ffffffff814a39b4>] ip_rcv+0x294/0x3d0
 [<ffffffff8146aaa2>] __netif_receive_skb_core+0x762/0x960
 [<ffffffff8146a47d>] ? __netif_receive_skb_core+0x13d/0x960
 [<ffffffff810aad4d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8146acb3>] __netif_receive_skb+0x13/0x60
 [<ffffffff8146ad2d>] netif_receive_skb_internal+0x2d/0x210
 [<ffffffff8146ca68>] napi_gro_receive+0x58/0x80
 [<ffffffffa01ec4d6>] rtl8169_poll+0x166/0x700 [r8169]
 [<ffffffff8146b839>] net_rx_action+0x129/0x1e0
 [<ffffffff81060ebc>] __do_softirq+0x11c/0x2a0
 [<ffffffff8106137d>] irq_exit+0x11d/0x140
 [<ffffffff810043c3>] do_IRQ+0x53/0xf0
 [<ffffffff81582def>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff8142c35f>] ? cpuidle_enter_state+0x4f/0xc0
 [<ffffffff8142c35b>] ? cpuidle_enter_state+0x4b/0xc0
 [<ffffffff8142c466>] cpuidle_idle_call+0x96/0x140
 [<ffffffff8100b879>] arch_cpu_idle+0x9/0x30
 [<ffffffff810b505a>] cpu_startup_entry+0xea/0x220
 [<ffffffff81571a83>] rest_init+0x133/0x140
 [<ffffffff81571950>] ? csum_partial_copy_generic+0x170/0x170
 [<ffffffff81c78e6c>] start_kernel+0x41f/0x440
 [<ffffffff81c78856>] ? repair_env_string+0x5c/0x5c
 [<ffffffff81c78571>] x86_64_start_reservations+0x2a/0x2c
 [<ffffffff81c7863a>] x86_64_start_kernel+0xc7/0xca

This box has two r8169's. Two different revs..
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 03)
