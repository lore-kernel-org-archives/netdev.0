From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 04:16:55 +0100
Message-ID: <64bb37e0801051916j5d496aedk62184850e2688d5a@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
	 <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
	 <20080105000700.GA3224@ami.dom.local>
	 <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
	 <20080105101327.GA3103@ami.dom.local>
	 <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
	 <64bb37e0801051410p39746295oab4dad438943372@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:22272 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbYAFDQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 22:16:57 -0500
Received: by py-out-1112.google.com with SMTP id u52so11872667pyb.10
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 19:16:56 -0800 (PST)
In-Reply-To: <64bb37e0801051410p39746295oab4dad438943372@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 5, 2008 11:10 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> 2.6.24-rc6 + mm-patches up to git.battery (includes git-net and
> git-netdev-all) worked for 110 packages, then I proclaimed it good.
> 2.6.24-rc6 + mm-patches up to (including) git.nfsd is currently
> getting testet (9 packages done...)
That kernel did also work for all 110 packages.

2.6.24-rc6 + mm-patches up to (including) git.xfs -> crash

[  576.899332] ------------[ cut here ]------------
[  576.903661] kernel BUG at lib/list_debug.c:33!
[  576.903661] invalid opcode: 0000 [1] SMP
[  576.903661] last sysfs file:
/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[  576.903661] CPU 3
[  576.903661] Modules linked in: radeon drm w83792d ipv6 tuner
tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx tea5761
tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
videobuf_core btcx_risc tveeprom videodev v4l2_common usbhid
v4l1_compat sg hid i2c_nforce2 pata_amd
[  576.903661] Pid: 5559, comm: nfsv4-svc Not tainted 2.6.24-rc6-mm-git.xfs #2
[  576.903661] RIP: 0010:[<ffffffff803c16e4>]  [<ffffffff803c16e4>]
__list_add+0x54/0x60
[  576.903661] RSP: 0018:ffff81007d4e1dc0  EFLAGS: 00010282
[  576.903661] RAX: 0000000000000088 RBX: ffff81007e955800 RCX: fffffffffc6c7900
[  576.903661] RDX: ffff81007d53eef0 RSI: 0000000000000001 RDI: ffffffff80760140
[  576.903661] RBP: ffff81007d4e1dc0 R08: 0000000000000001 R09: 0000000000000000
[  576.903661] R10: ffff810080062008 R11: 0000000000000001 R12: ffff81007ed00900
[  576.903661] R13: ffff81007ed00938 R14: ffff81007ed00938 R15: ffff81007dd6f100
[  576.903661] FS:  00007f1b7e6a36f0(0000) GS:ffff81011ff1b780(0000)
knlGS:0000000000000000
[  576.903661] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  576.903661] CR2: 00007ffb28c2c000 CR3: 00000000741ab000 CR4: 00000000000006e0
[  576.903661] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  576.903661] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  576.903661] Process nfsv4-svc (pid: 5559, threadinfo
ffff81007d4e0000, task ffff81007d53eef0)
[  576.903661] Stack:  ffff81007d4e1e00 ffffffff805c4dbb
ffff81007ed00908 ffff81007dd6f100
[  576.903661]  ffff81011ad7bc00 ffff81007d458000 ffff81007e955800
ffff81007dd6f110
[  576.903661]  ffff81007d4e1e10 ffffffff805c4ea7 ffff81007d4e1ee0
ffffffff805c5fd4
[  576.903661] Call Trace:
[  576.903661]  [<ffffffff805c4dbb>] svc_xprt_enqueue+0x1ab/0x240
[  576.903661]  [<ffffffff805c4ea7>] svc_xprt_received+0x17/0x20
[  576.903661]  [<ffffffff805c5fd4>] svc_recv+0x394/0x7c0
[  576.903661]  [<ffffffff805c53de>] svc_send+0xae/0xd0
[  576.903661]  [<ffffffff80230ab0>] default_wake_function+0x0/0x10
[  576.903661]  [<ffffffff80316499>] nfs_callback_svc+0x79/0x130
[  576.903662]  [<ffffffff80232f8c>] finish_task_switch+0xcc/0xe0
[  576.903662]  [<ffffffff8020c818>] child_rip+0xa/0x12
[  576.903662]  [<ffffffff8020bf2f>] restore_args+0x0/0x30
[  576.903662]  [<ffffffff805b9ecd>] __svc_create_thread+0xdd/0x200
[  576.903662]  [<ffffffff80316420>] nfs_callback_svc+0x0/0x130
[  576.903662]  [<ffffffff8020c80e>] child_rip+0x0/0x12
[  576.903662]
[  576.903662]
[  576.903662] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16
48 89 e5 e8
[  576.903662] RIP  [<ffffffff803c16e4>] __list_add+0x54/0x60
[  576.903662]  RSP <ffff81007d4e1dc0>
[  576.903673] ---[ end trace d46de6b99ae8cd5a ]---
[  576.913664] Kernel panic - not syncing: Aiee, killing interrupt handler!

Torsten
