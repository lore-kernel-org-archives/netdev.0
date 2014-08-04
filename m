From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [vmxnet3] dma-debug warning message.
Date: Mon, 4 Aug 2014 20:02:40 +0900
Message-ID: <201408042002.IBE57329.JOHQFFOtLVFMOS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sbhatewara@vmware.com, pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:11829 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaHDLCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 07:02:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I got below warning.

Regards.
----------
vmxnet3 0000:03:00.0 eth0: intr type 3, mode 0, 5 vectors allocated
------------[ cut here ]------------
WARNING: CPU: 2 PID: 1148 at lib/dma-debug.c:1140 check_unmap+0x436/0x8e0()
vmxnet3 0000:03:00.0: DMA-API: device driver failed to check map error[device address=0x0000000049eb1f00] [size=6 bytes] [mapped as single]
Modules linked in: ipv6 vhost_net macvtap macvlan vhost tun ppdev snd_ens1371 snd_rawmidi snd_ac97_codec ac97_bus dm_mod snd_seq snd_seq_device snd_pcm snd_timer snd soundcore sg i2c_piix4 i2c_core parport_pc parport shpchp ext4(E) jbd2(E) mbcache(E) crc16(E) sd_mod(E) crc_t10dif(E) sr_mod(E) cdrom(E) vmxnet3(E) mptspi(E) mptscsih(E) mptbase(E) scsi_transport_spi(E) pata_acpi(E) ata_generic(E) ata_piix(E)
CPU: 2 PID: 1148 Comm: ip Tainted: G            E 3.16.0 #413
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
 0000000000000474 ffff88004cf33408 ffffffff81647f8e ffffffff81a3df7e
 ffff88004cf33458 ffff88004cf33448 ffffffff810590ec ffff88004cf33448
 ffff88004cf33558 ffff88006e327e40 ffffffff831722c0 0000000000000006
Call Trace:
 [<ffffffff81647f8e>] dump_stack+0x51/0x6b
 [<ffffffff810590ec>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff810591d6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff8134ff06>] check_unmap+0x436/0x8e0
 [<ffffffff8135062a>] debug_dma_unmap_page+0x5a/0x60
 [<ffffffffa005e015>] vmxnet3_set_mc+0x155/0x2f0 [vmxnet3]
 [<ffffffffa0060152>] vmxnet3_activate_dev+0x292/0x420 [vmxnet3]
 [<ffffffffa0061578>] ? vmxnet3_create_queues+0x148/0x1a0 [vmxnet3]
 [<ffffffffa0061668>] vmxnet3_open+0x98/0xc0 [vmxnet3]
 [<ffffffff8155a0f6>] ? call_netdevice_notifiers+0x16/0x20
 [<ffffffff8155ae3f>] __dev_open+0xbf/0x120
 [<ffffffff8155ac2c>] __dev_change_flags+0xac/0x190
 [<ffffffff8155ad40>] dev_change_flags+0x30/0x70
 [<ffffffff8119c355>] ? do_anonymous_page+0xd5/0x290
 [<ffffffff81571e7a>] do_setlink+0x2ba/0x770
 [<ffffffff8164e54b>] ? _raw_spin_unlock+0x2b/0x40
 [<ffffffff8119c355>] ? do_anonymous_page+0xd5/0x290
 [<ffffffff81573bc9>] rtnl_newlink+0x539/0x760
 [<ffffffff815737b8>] ? rtnl_newlink+0x128/0x760
 [<ffffffff810b83b5>] ? __lock_acquired+0x145/0x360
 [<ffffffff8157289d>] rtnetlink_rcv_msg+0x1ad/0x230
 [<ffffffff815726c7>] ? rtnl_lock+0x17/0x20
 [<ffffffff81592e75>] ? netlink_deliver_tap+0x75/0x110
 [<ffffffff810bc7ee>] ? __lock_release+0x9e/0x1f0
 [<ffffffff815726c7>] ? rtnl_lock+0x17/0x20
 [<ffffffff81592e75>] ? netlink_deliver_tap+0x75/0x110
 [<ffffffff815726f0>] ? __rtnl_unlock+0x20/0x20
 [<ffffffff81593b89>] netlink_rcv_skb+0xa9/0xd0
 [<ffffffff81572975>] rtnetlink_rcv+0x25/0x40
 [<ffffffff81593922>] netlink_unicast+0x182/0x210
 [<ffffffff81594cdf>] netlink_sendmsg+0x2af/0x400
 [<ffffffff81542650>] sock_sendmsg+0x90/0xc0
 [<ffffffff810bc7ee>] ? __lock_release+0x9e/0x1f0
 [<ffffffff8119b826>] ? might_fault+0x66/0xc0
 [<ffffffff815511cd>] ? verify_iovec+0x8d/0x110
 [<ffffffff81542f66>] ___sys_sendmsg+0x3f6/0x410
 [<ffffffff810b4083>] ? up_read+0x23/0x40
 [<ffffffff811fa165>] ? rcu_read_lock_held+0x45/0x50
 [<ffffffff811fc275>] ? __fget_light+0x105/0x110
 [<ffffffff81543149>] __sys_sendmsg+0x49/0x90
 [<ffffffff815431a9>] SyS_sendmsg+0x19/0x20
 [<ffffffff8164ea52>] system_call_fastpath+0x16/0x1b
---[ end trace 88178fb516055c43 ]---
Mapped at:
 [<ffffffff81350983>] debug_dma_map_page+0xb3/0x160
 [<ffffffffa005e135>] vmxnet3_set_mc+0x275/0x2f0 [vmxnet3]
 [<ffffffffa0060152>] vmxnet3_activate_dev+0x292/0x420 [vmxnet3]
 [<ffffffffa0061668>] vmxnet3_open+0x98/0xc0 [vmxnet3]
 [<ffffffff8155ae3f>] __dev_open+0xbf/0x120
vmxnet3 0000:03:00.0 eth0: NIC Link is Up 10000 Mbps
