From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PANIC] pktgen panic on load
Date: Sun, 20 Sep 2009 15:45:47 -0700
Message-ID: <1253486747.17792.9.camel@jbrandeb-mobl2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21456 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbZITWph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 18:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just got this today after cloning Linus' tree, please let me know if you
want .config or full dmesg


[   22.441999] modprobe used greatest stack depth: 3144 bytes left
[  503.775093] ------------[ cut here ]------------
[  503.780252] kernel BUG at net/core/pktgen.c:3503!
[  503.785505] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  503.791575] last sysfs file: /sys/devices/system/cpu/sched_smt_power_savings
[  503.799443] CPU 6
[  503.801698] Modules linked in: pktgen(+) ixgbe mdio [last unloaded: scsi_wait_scan]
[  503.810313] Pid: 6120, comm: kpktgend_13 Not tainted 2.6.31 #1 S5520HC
[  503.817600] RIP: 0010:[<ffffffffa0029cda>]  [<ffffffffa0029cda>] pktgen_thread_worker+0x76/0x1497 [pktgen]
[  503.828402] RSP: 0018:ffff88036dca7d80  EFLAGS: 00010297
[  503.834332] RAX: 0000000000000006 RBX: ffff88036d6d0fe0 RCX: 0000000000000000
[  503.842299] RDX: 0000000000000006 RSI: ffff8800282d3740 RDI: ffff88036dca7e18
[  503.850264] RBP: ffff88036dca7ee0 R08: ffff88036dca6000 R09: ffff8801ed430700
[  503.858231] R10: 00000000afddf7db R11: ffff8801e0423e08 R12: ffff88036d9dd9e8
[  503.866195] R13: ffffffffa0029c64 R14: ffff88036d9dd9e8 R15: 0000000000000001
[  503.874161] FS:  0000000000000000(0000) GS:ffff8800282c0000(0000) knlGS:0000000000000000
[  503.883196] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  503.889611] CR2: 00007f1bb5b3e00f CR3: 00000001d7c91000 CR4: 00000000000006e0
[  503.897578] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  503.905544] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  503.913513] Process kpktgend_13 (pid: 6120, threadinfo ffff88036dca6000, task ffff88036d6d0fe0)
[  503.923224] Stack:
[  503.925472]  ffff88036dca7ea0 00000002afddf7db 000000000000028c 00000000d2c939bd
[  503.933573] <0> ffff88036dca7e00 ffffffff8100a7b4 ffff8801f5993740 00000000afddf7db
[  503.942191] <0> ffff8800282d3740 ffff8801ef1897d0 ffff88036dca7e10 ffffffff8104906c
[  503.951002] Call Trace:
[  503.953739]  [<ffffffff8100a7b4>] ? __switch_to+0xfd/0x23b
[  503.959870]  [<ffffffff8104906c>] ? finish_task_switch+0x4d/0x92
[  503.966582]  [<ffffffff8106b57b>] ? autoremove_wake_function+0x0/0x5a
[  503.973778]  [<ffffffff8147aaa5>] ? thread_return+0x71/0xd8
[  503.980003]  [<ffffffffa0029c64>] ? pktgen_thread_worker+0x0/0x1497 [pktgen]
[  503.987874]  [<ffffffff8106b12e>] kthread+0x89/0x91
[  503.993321]  [<ffffffff8100ce5a>] child_rip+0xa/0x20
[  503.998865]  [<ffffffff8106b0a5>] ? kthread+0x0/0x91
[  504.004409]  [<ffffffff8100ce50>] ? child_rip+0x0/0x20
[  504.010146] Code: 48 89 85 28 ff ff ff 48 89 85 30 ff ff ff 48 c7 85 20 ff ff ff 7b b5 06 81 65 8b 04 25 30 cc 00 00 41 3b 84 24 34 02 00 00 74 04 <0f> 0b eb fe 49 8d 94 24 38 02 00 00 48 c7 c6 a8 ec 02 a0 48 89
[  504.032139] RIP  [<ffffffffa0029cda>] pktgen_thread_worker+0x76/0x1497 [pktgen]
[  504.040316]  RSP <ffff88036dca7d80>
[  504.044227] ---[ end trace ddca71c9720a201f ]---

-- 
Jesse Brandeburg
This email sent from Evolution, powered by Linux

