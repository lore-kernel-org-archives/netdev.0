From: poma <pomidorabelisima@gmail.com>
Subject: freshclam: page allocation failure: order:0, mode:0x2204010
Date: Sat, 16 Jan 2016 00:25:37 +0100
Message-ID: <56997FF1.9000407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34230 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbcAOXZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 18:25:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Fi, 

as you can see it looks very peculiar mix, nouveau and usbnet.
Are they hidden viruses!?

...
freshclam: page allocation failure: order:0, mode:0x2204010
CPU: 0 PID: 12885 Comm: freshclam Not tainted 4.4.0-1.fc22.x86_64 #1
...
Call Trace:
 <IRQ>  [<ffffffff81427e39>] dump_stack+0x4b/0x72
 [<ffffffff811ebbca>] warn_alloc_failed+0xfa/0x160
 [<ffffffff811f00a1>] __alloc_pages_nodemask+0x4b1/0xd70
 [<ffffffffa0389402>] ? nvkm_client_ioctl+0x12/0x20 [nouveau]
 [<ffffffff8124287b>] alloc_pages_current+0x9b/0x1c0
 [<ffffffff8124c518>] new_slab+0x2a8/0x530
 [<ffffffff8124dd30>] ___slab_alloc+0x1f0/0x580
 [<ffffffff810e80a7>] ? sched_clock_local+0x17/0x80
 [<ffffffff8142d958>] ? radix_tree_node_alloc+0x28/0xa0
 [<ffffffffa04e548d>] ? intr_complete+0x3d/0xd0 [usbnet]
 [<ffffffff8142d958>] ? radix_tree_node_alloc+0x28/0xa0
 [<ffffffff8124e111>] __slab_alloc+0x51/0x90
 [<ffffffff8124e3a0>] kmem_cache_alloc+0x250/0x300
 [<ffffffff8142d958>] ? radix_tree_node_alloc+0x28/0xa0
 [<ffffffff8142d958>] radix_tree_node_alloc+0x28/0xa0
 [<ffffffff8142db1c>] __radix_tree_create+0x7c/0x200
 [<ffffffff8142dce1>] radix_tree_insert+0x41/0xe0
 [<ffffffff81459432>] add_dma_entry+0xa2/0x170
 [<ffffffff81459843>] debug_dma_map_page+0x113/0x150
 [<ffffffff816240a8>] usb_hcd_map_urb_for_dma+0x5f8/0x780
 [<ffffffff81108d8d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8162469d>] usb_hcd_submit_urb+0x1cd/0xac0
 [<ffffffff810e82ca>] ? sched_clock_cpu+0x8a/0xb0
 [<ffffffff816e6387>] ? led_trigger_blink_oneshot+0x77/0x90
 [<ffffffff810e8345>] ? local_clock+0x15/0x20
 [<ffffffff81127b6d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
 [<ffffffff8162626c>] usb_submit_urb+0x3fc/0x5a0
 [<ffffffff8187fb17>] ? _raw_read_unlock+0x27/0x40
 [<ffffffffa04e548d>] intr_complete+0x3d/0xd0 [usbnet]
 [<ffffffff81622bbe>] __usb_hcd_giveback_urb+0x8e/0x160
 [<ffffffff81622d2a>] usb_giveback_urb_bh+0x9a/0xf0
 [<ffffffff810b3184>] tasklet_hi_action+0x184/0x1d0
 [<ffffffff810b3c1e>] __do_softirq+0xde/0x490
 [<ffffffff81122dbd>] ? handle_fasteoi_irq+0x11d/0x150
 [<ffffffff810b4212>] irq_exit+0x112/0x120
 [<ffffffff81882dda>] do_IRQ+0x6a/0x120
 [<ffffffff81880b91>] common_interrupt+0x91/0x91
 <EOI>  [<ffffffff8187f6a3>] ? _raw_spin_unlock_irq+0x33/0x40
 [<ffffffff8187f69c>] ? _raw_spin_unlock_irq+0x2c/0x40
 [<ffffffff811ff9e8>] shrink_active_list+0x178/0x3a0
 [<ffffffff812001f5>] shrink_lruvec+0x5e5/0x750
 [<ffffffff8120044f>] shrink_zone+0xef/0x2e0
 [<ffffffff812007bc>] do_try_to_free_pages+0x17c/0x400
 [<ffffffff81200b3e>] try_to_free_pages+0xfe/0x2c0
 [<ffffffff811f0484>] __alloc_pages_nodemask+0x894/0xd70
 [<ffffffff8110959a>] ? __lock_acquire+0x4ba/0x1b70
 [<ffffffff810268b9>] ? sched_clock+0x9/0x10
 [<ffffffff8124287b>] alloc_pages_current+0x9b/0x1c0
 [<ffffffff811e4ba0>] __page_cache_alloc+0x150/0x1a0
 [<ffffffff811e54d0>] ? find_get_entry+0x120/0x240
 [<ffffffff811e53b5>] ? find_get_entry+0x5/0x240
 [<ffffffff811e5704>] pagecache_get_page+0x84/0x200
 [<ffffffff811e5aa9>] grab_cache_page_write_begin+0x29/0x40
 [<ffffffff8131ca80>] ext4_da_write_begin+0xd0/0x3d0
 [<ffffffff811e42f1>] generic_perform_write+0xd1/0x1e0
 [<ffffffff8129484f>] ? file_update_time+0x5f/0x110
 [<ffffffff811e7042>] __generic_file_write_iter+0x1a2/0x1e0
 [<ffffffff81310a12>] ext4_file_write_iter+0x102/0x480
 [<ffffffff810268b9>] ? sched_clock+0x9/0x10
 [<ffffffff812760dc>] __vfs_write+0xcc/0x110
 [<ffffffff8127677c>] vfs_write+0xac/0x1a0
 [<ffffffff81297a56>] ? __fget_light+0x66/0x90
 [<ffffffff81277478>] SyS_write+0x58/0xd0
 [<ffffffff818800b2>] entry_SYSCALL_64_fastpath+0x12/0x76
SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
  cache: radix_tree_node, object size: 576, buffer size: 584, default order: 2, min order: 0
  node 0: slabs: 766, objs: 21448, free: 0
DMA-API: cacheline tracking ENOMEM, dma-debug disabled
...
