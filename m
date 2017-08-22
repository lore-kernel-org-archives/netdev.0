From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196727] New: WARNING: CPU: 11 PID: 0 at
 net/sched/sch_generic.c:316 dev_watchdog+0xc5/0x122
Date: Tue, 22 Aug 2017 09:01:22 -0700
Message-ID: <20170822090122.6583937d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36846 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdHVQBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 12:01:32 -0400
Received: by mail-pg0-f42.google.com with SMTP id i12so116962368pgr.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 09:01:31 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id l2sm24379530pfe.168.2017.08.22.09.01.30
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Aug 2017 09:01:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New Intel driver timeout?

Begin forwarded message:

Date: Tue, 22 Aug 2017 06:51:58 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196727] New: WARNING: CPU: 11 PID: 0 at net/sched/sch_generic.c:316 dev_watchdog+0xc5/0x122


https://bugzilla.kernel.org/show_bug.cgi?id=196727

            Bug ID: 196727
           Summary: WARNING: CPU: 11 PID: 0 at net/sched/sch_generic.c:316
                    dev_watchdog+0xc5/0x122
           Product: Networking
           Version: 2.5
    Kernel Version: 4.12.8
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: pstaszewski@artcom.pl
        Regression: No

[ 2452.163445] NETDEV WATCHDOG: eth0 (ixgbe): transmit queue 0 timed out
[ 2452.163467] ------------[ cut here ]------------
[ 2452.163475] WARNING: CPU: 11 PID: 0 at net/sched/sch_generic.c:316
dev_watchdog+0xc5/0x122
[ 2452.163476] Modules linked in: ipmi_si x86_pkg_temp_thermal
[ 2452.163482] CPU: 11 PID: 0 Comm: swapper/11 Tainted: G          I     4.12.8
#1
[ 2452.163483] task: ffff88086d8fe200 task.stack: ffffc90003214000
[ 2452.163485] RIP: 0010:dev_watchdog+0xc5/0x122
[ 2452.163485] RSP: 0018:ffff88087f843ea0 EFLAGS: 00010286
[ 2452.163486] RAX: 0000000000000039 RBX: ffff88046ca78000 RCX:
0000000000000000
[ 2452.163487] RDX: ffff88087f853310 RSI: ffff88087f84caa8 RDI:
ffff88087f84caa8
[ 2452.163487] RBP: ffff88087f843eb0 R08: 0000000000000000 R09:
0000000000000000
[ 2452.163488] R10: 00000000003d0900 R11: ffff88087ff9194c R12:
0000000000000000
[ 2452.163489] R13: ffffffff815a37a2 R14: ffff88046ca78438 R15:
ffff88046ca78000
[ 2452.163490] FS:  0000000000000000(0000) GS:ffff88087f840000(0000)
knlGS:0000000000000000
[ 2452.163490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2452.163491] CR2: 00000000006b2008 CR3: 0000000001c09000 CR4:
00000000001406e0
[ 2452.163492] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 2452.163492] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[ 2452.163493] Call Trace:
[ 2452.163494]  <IRQ>
[ 2452.163500]  call_timer_fn+0x5b/0x123
[ 2452.163501]  run_timer_softirq+0x137/0x15a
[ 2452.163503]  ? tk_clock_read+0xc/0xe
[ 2452.163505]  ? timekeeping_get_ns+0x1d/0x31
[ 2452.163506]  ? ktime_get+0x2d/0x3e
[ 2452.163508]  __do_softirq+0xe4/0x23a
[ 2452.163512]  ? tick_program_event+0x5d/0x64
[ 2452.163513]  irq_exit+0x4d/0x5b
[ 2452.163518]  smp_apic_timer_interrupt+0x29/0x34
[ 2452.163520]  apic_timer_interrupt+0x86/0x90
[ 2452.163524] RIP: 0010:cpuidle_enter_state+0x12f/0x184
[ 2452.163525] RSP: 0018:ffffc90003217ea0 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff10
[ 2452.163526] RAX: 0000023af054988b RBX: 0000000000000002 RCX:
000000000000001f
[ 2452.163527] RDX: 0000000000000000 RSI: 000000000000000b RDI:
0000000000000000
[ 2452.163527] RBP: ffffc90003217ed0 R08: 00000000ffffffe3 R09:
000000003ff003ff
[ 2452.163528] R10: ffffc90003217e70 R11: 0000000000000004 R12:
ffff88086c10d400
[ 2452.163528] R13: 0000023af054988b R14: 0000000000000002 R15:
0000023af0528d14
[ 2452.163529]  </IRQ>
[ 2452.163531]  cpuidle_enter+0x12/0x14
[ 2452.163534]  do_idle+0x10e/0x166
[ 2452.163535]  cpu_startup_entry+0x1a/0x1c
[ 2452.163537]  start_secondary+0xd0/0xd3
[ 2452.163540]  secondary_startup_64+0x9f/0x9f
[ 2452.163541] Code: 70 15 73 00 00 75 38 48 89 df c6 05 64 15 73 00 01 e8 1d
4a fe ff 44 89 e1 48 89 de 48 c7 c7 eb 8f a9 81 48 89 c2 e8 b4 ab b3 ff <0f> ff
eb 10 41 ff c4 48 05 40 01 00 00 41 39 f4 75 9a eb 0d 48
[ 2452.163559] ---[ end trace e35aaedfdb6bf6da ]---
[ 2452.163562] ixgbe 0000:02:00.0 eth0: initiating reset due to tx timeout
[ 2452.163579] ixgbe 0000:02:00.0 eth0: Reset adapter
[ 2473.173038] ixgbe 0000:02:00.0 eth0: detected SFP+: 5
[ 2473.325081] ixgbe 0000:02:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control:
None
[ 2473.450701] ixgbe 0000:02:00.0 eth0: NIC Link is Down
[ 2473.450784] ixgbe 0000:02:00.0 eth0: initiating reset to clear Tx work after
link loss
[ 2473.537116] ixgbe 0000:02:00.0 eth0: Reset adapter
[ 2473.821091] ixgbe 0000:02:00.0 eth0: detected SFP+: 5
[ 2473.969178] ixgbe 0000:02:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control:
None
[ 2474.112745] ixgbe 0000:02:00.0 eth0: NIC Link is Down
[ 2474.112830] ixgbe 0000:02:00.0 eth0: initiating reset to clear Tx work after
link loss
[ 2474.177126] ixgbe 0000:02:00.0 eth0: Reset adapter
[ 2474.461154] ixgbe 0000:02:00.0 eth0: detected SFP+: 5
[ 2474.613208] ixgbe 0000:02:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control:
None

-- 
You are receiving this mail because:
You are the assignee for the bug.
