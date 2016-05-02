From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 117521] New: BUG: unable to handle kernel paging request
 at 000001a400015ff4
Date: Mon, 2 May 2016 14:48:10 -0700
Message-ID: <20160502144810.4c13d8292168e43a72f4ce59@linux-foundation.org>
References: <bug-117521-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: gbalasun@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56347 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbcEBVsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 17:48:12 -0400
In-Reply-To: <bug-117521-27@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Thanks.  It's probably a TIPC issue.

On Mon, 02 May 2016 16:44:18 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=117521
> 
>             Bug ID: 117521
>            Summary: BUG: unable to handle kernel paging request at
>                     000001a400015ff4
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.4.0
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: gbalasun@gmail.com
>         Regression: No
> 
> [   65.954959] sm-msp-queue[1279]: unable to qualify my own domain name
> (dcsx5testslot3) -- using short name
> [  632.098785] perf interrupt took too long (2505 > 2500), lowering
> kernel.perf_event_max_sample_rate to 50000
> [ 5880.428123] perf interrupt took too long (5585 > 5000), lowering
> kernel.perf_event_max_sample_rate to 25000
> [17934.014969] CE: hpet increased min_delta_ns to 20115 nsec
> [38956.721789] CE: hpet4 increased min_delta_ns to 20115 nsec
> [46927.872827] hrtimer: interrupt took 63361 ns
> [101662.241093] CE: hpet2 increased min_delta_ns to 20115 nsec
> [245973.044600] CE: hpet6 increased min_delta_ns to 20115 nsec
> [368639.565040] show_signal_msg: 6 callbacks suppressed
> [375832.498126] BUG: unable to handle kernel paging request at 000001a400015ff4
> [375832.505300] IP: [<ffffffff810c3566>] queued_spin_lock_slowpath+0xe6/0x160
> [375832.512394] PGD 0 
> [375832.514657] Oops: 0002 [#1] SMP
> [375832.518306] Modules linked in: nf_log_ipv6 nf_log_ipv4 nf_log_common xt_LOG
> sctp libcrc32c e1000e tipc udp_tunnel ip6_udp_tunnel 8021q garp iTCO_wdt
> xt_physdev br_netfilter bridge stp llc nf_conntrack_ipv4 nf_defrag_ipv4
> ipmiq_drv(O) sio_mmc(O) ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6
> nf_defrag_ipv6 xt_state nf_conntrack lockd ip6table_filter event_drv(O)
> ip6_tables grace pt_timer_info(O) ddi(O) usb_storage ixgbe igb i2c_i801
> iTCO_vendor_support i2c_algo_bit ioatdma intel_ips i2c_core pcspkr sunrpc ptp
> mdio dca pps_core lpc_ich tpm_tis mfd_core tpm [last unloaded: iTCO_wdt]
> [375832.573693] CPU: 4 PID: 0 Comm: swapper/4 Tainted: G           O    4.4.0
> #14
> [375832.581385] Hardware name: PT AMC124/Base Board Product Name, BIOS
> LGNAJFIP.PTI.0012.P15 01/15/2014
> [375832.591028] task: ffff880351a89b40 ti: ffff880351a90000 task.ti:
> ffff880351a90000
> [375832.599026] RIP: 0010:[<ffffffff810c3566>]  [<ffffffff810c3566>]
> queued_spin_lock_slowpath+0xe6/0x160
> [375832.608964] RSP: 0018:ffff88035fc83d58  EFLAGS: 00010002
> [375832.614825] RAX: 0000000000001447 RBX: 0000000000000292 RCX:
> ffff88035fc95fc0
> [375832.622743] RDX: 000001a400015ff4 RSI: 0000000000140000 RDI:
> ffff880351232f80
> [375832.630567] RBP: ffff88035fc83d58 R08: 0000000000000101 R09:
> 0000000000000004
> [375832.638348] R10: 0000000000000000 R11: 0000000000000000 R12:
> 0000000001001002
> [375832.645919] R13: 0000000000000001 R14: 0000000000000000 R15:
> 0000000000000000
> [375832.653610] FS:  0000000000000000(0000) GS:ffff88035fc80000(0000)
> knlGS:0000000000000000
> [375832.662317] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [375832.668483] CR2: 000001a400015ff4 CR3: 0000000001c0a000 CR4:
> 00000000000006e0
> [375832.676133] Stack:
> [375832.678344]  ffff88035fc83d78 ffffffff816de2c1 ffff88034a8bba60
> ffff880351232f80
> [375832.686163]  ffff88035fc83db8 ffffffff810bc592 ffff88035fc83dc8
> ffff880351758000
> [375832.694139]  0000000001001002 0000000000000000 00000000b802f4bd
> ffffffffa024e6f0
> [375832.702154] Call Trace:
> [375832.704844]  <IRQ> 
> [375832.707018]  [<ffffffff816de2c1>] _raw_spin_lock_irqsave+0x31/0x40
> [375832.713970]  [<ffffffff810bc592>] __wake_up+0x32/0x70
> [375832.719444]  [<ffffffffa024e6f0>] ? tipc_recv_stream+0x370/0x370 [tipc]
> [375832.726589]  [<ffffffff815bf890>] sock_def_wakeup+0x30/0x40
> [375832.732566]  [<ffffffffa024e838>] tipc_sk_timeout+0x148/0x180 [tipc]
> [375832.739388]  [<ffffffffa024e6f0>] ? tipc_recv_stream+0x370/0x370 [tipc]
> [375832.746507]  [<ffffffff810e1644>] call_timer_fn+0x44/0x110
> [375832.752378]  [<ffffffff810e0e6a>] ? cascade+0x4a/0x80
> [375832.757848]  [<ffffffffa024e6f0>] ? tipc_recv_stream+0x370/0x370 [tipc]
> [375832.764871]  [<ffffffff810e2c4c>] run_timer_softirq+0x22c/0x280
> [375832.771175]  [<ffffffff81083d88>] __do_softirq+0xc8/0x260
> [375832.776958]  [<ffffffff81084123>] irq_exit+0x83/0xb0
> [375832.782369]  [<ffffffff816e0c65>] do_IRQ+0x65/0xf0
> [375832.787607]  [<ffffffff816df13f>] common_interrupt+0x7f/0x7f
> [375832.793709]  <EOI> 
> [375832.795803]  [<ffffffff81591bdd>] ? cpuidle_enter_state+0xad/0x200
> [375832.802765]  [<ffffffff81591bc1>] ? cpuidle_enter_state+0x91/0x200
> [375832.809338]  [<ffffffff81591d67>] cpuidle_enter+0x17/0x20
> [375832.815155]  [<ffffffff810bcdc7>] call_cpuidle+0x37/0x60
> [375832.821184]  [<ffffffff81591d43>] ? cpuidle_select+0x13/0x20
> [375832.827249]  [<ffffffff810bd001>] cpu_startup_entry+0x211/0x2d0
> [375832.833535]  [<ffffffff8103b213>] start_secondary+0x103/0x130
> [375832.839759] Code: 87 47 02 c1 e0 10 85 c0 74 38 48 89 c2 c1 e8 12 48 c1 ea
> 0c 83 e8 01 83 e2 30 48 98 48 81 c2 c0 5f 01 00 48 03 14 c5 00 b2 d1 81 <48> 89
> 0a 8b 41 08 85 c0 75 0d f3 90 8b 41 08 85 c0 74 f7 eb 02 
> [375832.861151] RIP  [<ffffffff810c3566>] queued_spin_lock_slowpath+0xe6/0x160
> [375832.868607]  RSP <ffff88035fc83d58>
> [375832.872371] CR2: 000001a400015ff4
> [375832.876408] ---[ end trace f12e0074b180a165 ]---
> [375832.881433] Kernel panic - not syncing: Fatal exception in interrupt
> [375832.888391] Kernel Offset: disabled
> [375832.891968] ---[ end Kernel panic - not syncing: Fatal exception in
> interrupt
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
