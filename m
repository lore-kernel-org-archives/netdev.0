From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Latest kernel net-next - 4.14-rc1+ / WARNING: CPU: 16 PID: 0 at
 net/sched/sch_hfsc.c:1385 hfsc_dequeue+0x241/0x269
Date: Tue, 26 Sep 2017 14:00:55 +0200
Message-ID: <00115c1c-6296-bc76-8ac2-5160aa870596@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.iq.pl ([86.111.242.220]:55370 "EHLO smtp11.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934961AbdIZMDA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 08:03:00 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3y1fjH1CHnz3xR6
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 14:02:59 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[50102.787542] ------------[ cut here ]------------
[50102.787545] WARNING: CPU: 16 PID: 0 at net/sched/sch_hfsc.c:1385 
hfsc_dequeue+0x241/0x269
[50102.787545] Modules linked in: ipmi_si x86_pkg_temp_thermal
[50102.787547] CPU: 16 PID: 0 Comm: swapper/16 Tainted: G W       
4.14.0-rc1+ #10
[50102.787548] task: ffff88046d440000 task.stack: ffffc900032e0000
[50102.787549] RIP: 0010:hfsc_dequeue+0x241/0x269
[50102.787550] RSP: 0018:ffff88046fc83eb0 EFLAGS: 00010246
[50102.787551] RAX: 0000000000000000 RBX: ffff880456309948 RCX: 
0000000000000018
[50102.787551] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff880456309c40
[50102.787552] RBP: ffff88046fc83ed8 R08: 000000000001c000 R09: 
0000000000000100
[50102.787553] R10: ffff88046fc83e98 R11: 0000000000000003 R12: 
ffff880456309800
[50102.787553] R13: 000000b6459156dd R14: 0000000000000001 R15: 
ffff880456309c40
[50102.787554] FS:  0000000000000000(0000) GS:ffff88046fc80000(0000) 
knlGS:0000000000000000
[50102.787555] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[50102.787556] CR2: 00007fc764f21090 CR3: 000000085844a000 CR4: 
00000000001606e0
[50102.787556] Call Trace:
[50102.787557]  <IRQ>
[50102.787558]  __qdisc_run+0xed/0x293
[50102.787560]  net_tx_action+0xeb/0x18b
[50102.787562]  __do_softirq+0xe4/0x23a
[50102.787564]  irq_exit+0x4d/0x5b
[50102.787565]  smp_apic_timer_interrupt+0xc0/0xfa
[50102.787566]  apic_timer_interrupt+0x90/0xa0
[50102.787566]  </IRQ>
[50102.787568] RIP: 0010:cpuidle_enter_state+0x134/0x189
[50102.787569] RSP: 0018:ffffc900032e3ea0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff10
[50102.787570] RAX: 00002d9176d7d9f4 RBX: 0000000000000002 RCX: 
000000000000001f
[50102.787570] RDX: 0000000000000000 RSI: 0000000000000010 RDI: 
0000000000000000
[50102.787571] RBP: ffffc900032e3ed0 R08: 00000000ffffffd8 R09: 
0000000000000003
[50102.787572] R10: ffffc900032e3e70 R11: ffff88046fc98e50 R12: 
ffff88046c234400
[50102.787572] R13: 00002d9176d7d9f4 R14: 0000000000000002 R15: 
00002d9176d6e845
[50102.787575]  cpuidle_enter+0x12/0x14
[50102.787576]  do_idle+0x113/0x16b
[50102.787578]  cpu_startup_entry+0x1a/0x1f
[50102.787580]  start_secondary+0xea/0xed
[50102.787581]  secondary_startup_64+0xa5/0xa5
[50102.787582] Code: f6 48 3d 90 00 00 00 74 04 48 8b 70 70 49 8b 84 24 
68 02 00 00 48 85 c0 74 0c 48 39 f0 72 24 48 85 f6 75 09 eb 1d 48 85 f6 
75 02 <0f> ff 49 8d bc 24 48 04 00 00 48 c1 e6 06 e8 a9 62 ff ff e9 eb
[50102.787602] ---[ end trace 8558fb6f1ca3beb2 ]---
