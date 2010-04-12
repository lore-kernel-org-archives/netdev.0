From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 19:11:27 +0300
Message-ID: <201004121911.27955.nuclearcat@nuclearcat.com>
References: <201004112338.47019.nuclearcat@nuclearcat.com> <OF802D1BE7.C2709B61-ON65257703.00235EF5-65257703.002B5F38@in.ibm.com> <1271064703.16881.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vY0wLNx1Y+ok6WN"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36502 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab0DLQNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 12:13:13 -0400
In-Reply-To: <1271064703.16881.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_vY0wLNx1Y+ok6WN
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit

On Monday 12 April 2010 12:31:43 Eric Dumazet wrote:
.
Seems problem still remain. Patched kernel, but paniced now.
Btw, i dont have any multiqueue card, i think.

--Boundary-00=_vY0wLNx1Y+ok6WN
Content-Type: text/plain;
  charset="utf-8";
  name="x.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x.txt"

Apr 12 18:46:58 80.83.17.1 dropbear[4843]: exit before auth: Disconnect received
Apr 12 18:46:59 80.83.17.1 dropbear[4845]: Child connection from 82.113.44.186:48692
Apr 12 18:46:59 80.83.17.1 dropbear[4844]: exit before auth: Disconnect received
Apr 12 18:46:59 80.83.17.1 kernel: [12598.956375] BUG: unable to handle kernel NULL pointer dereference at (null)
Apr 12 18:46:59 80.83.17.1 kernel: [12598.956571] IP: [<ffffffff811e587f>] dev_queue_xmit+0x28c/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.956762] PGD 21debc067 PUD 21c881067 PMD 0 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.956947] Oops: 0000 [#1] SMP 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957126] last sysfs file: /sys/devices/virtual/vc/vcs3/dev
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957311] CPU 0 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] Pid: 0, comm: swapper Not tainted 2.6.33.2-build-0052test-64 #2         /        
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RIP: 0010:[<ffffffff811e587f>]  [<ffffffff811e587f>] dev_queue_xmit+0x28c/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RSP: 0000:ffff880028203a30  EFLAGS: 00010202
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RAX: 0000000000002000 RBX: 0000000000000000 RCX: ffff880209d8a900
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RDX: ffff88021d870000 RSI: 0000000000000000 RDI: ffff88020a7b48e8
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RBP: ffff880028203a60 R08: ffff88021c8be89c R09: ffff88021c8bec00
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] R10: dead000000200200 R11: dead000000100100 R12: ffff88021f98a880
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] R13: ffff88021d5c0900 R14: ffff88020a7b48e8 R15: ffff88021cbad000
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] CR2: 0000000000000000 CR3: 000000021c9d8000 CR4: 00000000000006f0
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] Process swapper (pid: 0, threadinfo ffffffff81392000, task ffffffff813a1020)
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] Stack:
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  ffff88021d870000 ffff88021d5c0900 0000000000000042 ffff88021d5c0900
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] <0> ffff88021cbad000 ffff88021cbad000 ffff880028203a80 ffffffffa01c12a9
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] <0> 0000000000000000 ffff88020a7b48e8 ffff880028203ad0 ffffffff811e540e
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] Call Trace:
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  <IRQ> 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffffa01c12a9>] vlan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811e540e>] dev_hard_start_xmit+0x232/0x304
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811f648a>] sch_direct_xmit+0x5d/0x16b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811f6654>] __qdisc_run+0xbc/0xdc
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811e5939>] dev_queue_xmit+0x346/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8120a384>] ip_finish_output2+0x1c2/0x206
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8120a430>] ip_finish_output+0x68/0x6a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8120a4d2>] ip_output+0xa0/0xa5
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81206d2e>] ip_forward_finish+0x2e/0x32
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81206ff4>] ip_forward+0x2c2/0x322
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81205ae0>] ip_rcv_finish+0x2f0/0x30a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81205d77>] ip_rcv+0x27d/0x2a4
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8124ad48>] ? vlan_hwaccel_do_receive+0x2b/0xda
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811e47b6>] netif_receive_skb+0x450/0x475
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811e4909>] napi_skb_finish+0x24/0x3b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8124b01b>] vlan_gro_receive+0x7c/0x81
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffffa015d6c5>] e1000_receive_skb+0x4a/0x65 [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffffa015d8cb>] e1000_clean_rx_irq+0x1eb/0x29c [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffffa015ebfb>] e1000_clean+0x75/0x22e [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffffa0234d6c>] ? hfsc_dequeue+0x171/0x2a6 [sch_hfsc]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff811e4e56>] net_rx_action+0xa7/0x17a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81039670>] __do_softirq+0x96/0x11a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff810037cc>] call_softirq+0x1c/0x28
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81005543>] do_softirq+0x33/0x68
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81039407>] irq_exit+0x36/0x75
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81004c3e>] do_IRQ+0xaa/0xc1
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8125ba93>] ret_from_intr+0x0/0xa
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  <EOI> 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8100a0c7>] ? mwait_idle+0x66/0x6b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81001d24>] ? enter_idle+0x20/0x22
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff81001d7b>] cpu_idle+0x55/0x8d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff8124bba5>] rest_init+0x79/0x7b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff813fca70>] start_kernel+0x362/0x36d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff813fc0a8>] x86_64_start_reservations+0xa5/0xa9
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  [<ffffffff813fc189>] x86_64_start_kernel+0xdd/0xe4
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] Code: e2 48 8b 55 d0 49 c1 e4 07 66 41 8b 86 a6 00 00 00 4c 03 a2 00 03 00 00 80 e4 cf 80 cc 20 49 8b 5c 24 08 66 41 89 86 a6 00 00 00 <48> 83 3b 00 0f 84 bb 00 00 00 4c 8d ab 9c 00 00 00 4c 89 ef e8 
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] RIP  [<ffffffff811e587f>] dev_queue_xmit+0x28c/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342]  RSP <ffff880028203a30>
Apr 12 18:46:59 80.83.17.1 kernel: [12598.957342] CR2: 0000000000000000
Apr 12 18:46:59 80.83.17.1 kernel: [12598.974856] ---[ end trace 739e5480c8ab784f ]---
Apr 12 18:46:59 80.83.17.1 kernel: [12598.975082] Kernel panic - not syncing: Fatal exception in interrupt
Apr 12 18:46:59 80.83.17.1 kernel: [12598.975311] Pid: 0, comm: swapper Tainted: G      D    2.6.33.2-build-0052test-64 #2
Apr 12 18:46:59 80.83.17.1 kernel: [12598.975706] Call Trace:
Apr 12 18:46:59 80.83.17.1 kernel: [12598.975920]  <IRQ>  [<ffffffff81259753>] panic+0xa0/0x161
Apr 12 18:46:59 80.83.17.1 kernel: [12598.976200]  [<ffffffff81003293>] ? apic_timer_interrupt+0x13/0x20
Apr 12 18:46:59 80.83.17.1 kernel: [12598.976431]  [<ffffffff81035673>] ? kmsg_dump+0x112/0x12c
Apr 12 18:46:59 80.83.17.1 kernel: [12598.976657]  [<ffffffff81006651>] oops_end+0xaa/0xba
Apr 12 18:46:59 80.83.17.1 kernel: [12598.976882]  [<ffffffff8101e653>] no_context+0x1f3/0x202
Apr 12 18:46:59 80.83.17.1 kernel: [12598.977113]  [<ffffffff8101e81c>] __bad_area_nosemaphore+0x1ba/0x1e0
Apr 12 18:46:59 80.83.17.1 kernel: [12598.977347]  [<ffffffff8113f8b3>] ? swiotlb_map_page+0x0/0xd5
Apr 12 18:46:59 80.83.17.1 kernel: [12598.977577]  [<ffffffffa015c55a>] ? pci_map_single+0x8a/0x99 [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.977806]  [<ffffffff8113f0c0>] ? swiotlb_dma_mapping_error+0x18/0x25
Apr 12 18:46:59 80.83.17.1 kernel: [12598.978045]  [<ffffffffa015a2e0>] ? pci_dma_mapping_error+0x31/0x3d [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.978282]  [<ffffffffa015cc37>] ? e1000_xmit_frame+0x6ce/0xa43 [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.978513]  [<ffffffff8101e850>] bad_area_nosemaphore+0xe/0x10
Apr 12 18:46:59 80.83.17.1 kernel: [12598.978741]  [<ffffffff8101eb32>] do_page_fault+0x114/0x24a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.978967]  [<ffffffff8125bc9f>] page_fault+0x1f/0x30
Apr 12 18:46:59 80.83.17.1 kernel: [12598.979196]  [<ffffffff811e587f>] ? dev_queue_xmit+0x28c/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.979426]  [<ffffffffa01c12a9>] vlan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.979821]  [<ffffffff811e540e>] dev_hard_start_xmit+0x232/0x304
Apr 12 18:46:59 80.83.17.1 kernel: [12598.980055]  [<ffffffff811f648a>] sch_direct_xmit+0x5d/0x16b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.980284]  [<ffffffff811f6654>] __qdisc_run+0xbc/0xdc
Apr 12 18:46:59 80.83.17.1 kernel: [12598.980514]  [<ffffffff811e5939>] dev_queue_xmit+0x346/0x46d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.980740]  [<ffffffff8120a384>] ip_finish_output2+0x1c2/0x206
Apr 12 18:46:59 80.83.17.1 kernel: [12598.980966]  [<ffffffff8120a430>] ip_finish_output+0x68/0x6a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.981197]  [<ffffffff8120a4d2>] ip_output+0xa0/0xa5
Apr 12 18:46:59 80.83.17.1 kernel: [12598.981427]  [<ffffffff81206d2e>] ip_forward_finish+0x2e/0x32
Apr 12 18:46:59 80.83.17.1 kernel: [12598.981654]  [<ffffffff81206ff4>] ip_forward+0x2c2/0x322
Apr 12 18:46:59 80.83.17.1 kernel: [12598.981880]  [<ffffffff81205ae0>] ip_rcv_finish+0x2f0/0x30a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.982111]  [<ffffffff81205d77>] ip_rcv+0x27d/0x2a4
Apr 12 18:46:59 80.83.17.1 kernel: [12598.982337]  [<ffffffff8124ad48>] ? vlan_hwaccel_do_receive+0x2b/0xda
Apr 12 18:46:59 80.83.17.1 kernel: [12598.982566]  [<ffffffff811e47b6>] netif_receive_skb+0x450/0x475
Apr 12 18:46:59 80.83.17.1 kernel: [12598.982793]  [<ffffffff811e4909>] napi_skb_finish+0x24/0x3b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.983025]  [<ffffffff8124b01b>] vlan_gro_receive+0x7c/0x81
Apr 12 18:46:59 80.83.17.1 kernel: [12598.983260]  [<ffffffffa015d6c5>] e1000_receive_skb+0x4a/0x65 [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.983492]  [<ffffffffa015d8cb>] e1000_clean_rx_irq+0x1eb/0x29c [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.983727]  [<ffffffffa015ebfb>] e1000_clean+0x75/0x22e [e1000e]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.983955]  [<ffffffffa0234d6c>] ? hfsc_dequeue+0x171/0x2a6 [sch_hfsc]
Apr 12 18:46:59 80.83.17.1 kernel: [12598.984190]  [<ffffffff811e4e56>] net_rx_action+0xa7/0x17a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.984416]  [<ffffffff81039670>] __do_softirq+0x96/0x11a
Apr 12 18:46:59 80.83.17.1 kernel: [12598.984642]  [<ffffffff810037cc>] call_softirq+0x1c/0x28
Apr 12 18:46:59 80.83.17.1 kernel: [12598.984866]  [<ffffffff81005543>] do_softirq+0x33/0x68
Apr 12 18:46:59 80.83.17.1 kernel: [12598.985097]  [<ffffffff81039407>] irq_exit+0x36/0x75
Apr 12 18:46:59 80.83.17.1 kernel: [12598.985323]  [<ffffffff81004c3e>] do_IRQ+0xaa/0xc1
Apr 12 18:46:59 80.83.17.1 kernel: [12598.985546]  [<ffffffff8125ba93>] ret_from_intr+0x0/0xa
Apr 12 18:46:59 80.83.17.1 kernel: [12598.985770]  <EOI>  [<ffffffff8100a0c7>] ? mwait_idle+0x66/0x6b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.986048]  [<ffffffff81001d24>] ? enter_idle+0x20/0x22
Apr 12 18:46:59 80.83.17.1 kernel: [12598.986284]  [<ffffffff81001d7b>] cpu_idle+0x55/0x8d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.986507]  [<ffffffff8124bba5>] rest_init+0x79/0x7b
Apr 12 18:46:59 80.83.17.1 kernel: [12598.986730]  [<ffffffff813fca70>] start_kernel+0x362/0x36d
Apr 12 18:46:59 80.83.17.1 kernel: [12598.986955]  [<ffffffff813fc0a8>] x86_64_start_reservations+0xa5/0xa9
Apr 12 18:46:59 80.83.17.1 kernel: [12598.987189]  [<ffffffff813fc189>] x86_64_start_kernel+0xdd/0xe4

--Boundary-00=_vY0wLNx1Y+ok6WN--
