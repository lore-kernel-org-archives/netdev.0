From: Borislav Petkov <bp@alien8.de>
Subject: NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0 timed out
Date: Mon, 18 Jun 2012 22:43:34 +0200
Message-ID: <20120618204334.GB4148@liondog.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just got the below on -rc3 after resuming. No network afterwards.

Rebooting fixed it.

[15473.272994] Restarting tasks ... done.
[15473.685535] forcedeth 0000:00:08.0: eth0: link up
[15483.926079] ------------[ cut here ]------------
[15483.926095] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x16f/0x213()
[15483.926099] Hardware name:  
[15483.926103] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0 timed out
[15483.926160] Modules linked in: nls_iso8859_15 nls_cp437 tun cpufreq_powersave cpufreq_userspace ip6table_filter cpufreq_conservative ip6_tables cpufreq_stats iptable_filter ip_tables x_tables binfmt_misc fuse dm_crypt ipv6 vfat fat dm_mod powernow_k8 mperf kvm_amd kvm radeon drm_kms_helper ttm edac_core k10temp microcode cfbfillrect cfbimgblt cfbcopyarea
[15483.926166] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc3+ #3
[15483.926170] Call Trace:
[15483.926180]  <IRQ>  [<ffffffff8137b500>] ? dev_watchdog+0x72/0x213
[15483.926189]  [<ffffffff8102b354>] warn_slowpath_common+0x83/0x9b
[15483.926195]  [<ffffffff8102b40f>] warn_slowpath_fmt+0x46/0x48
[15483.926203]  [<ffffffff8137b5fd>] dev_watchdog+0x16f/0x213
[15483.926211]  [<ffffffff8103a4a9>] run_timer_softirq+0x37b/0x58f
[15483.926217]  [<ffffffff8103a354>] ? run_timer_softirq+0x226/0x58f
[15483.926224]  [<ffffffff8105e56e>] ? local_clock+0x2a/0x3b
[15483.926231]  [<ffffffff81051842>] ? hrtimer_interrupt+0x118/0x1b4
[15483.926237]  [<ffffffff8137b48e>] ? pfifo_fast_dequeue+0xc2/0xc2
[15483.926245]  [<ffffffff81075638>] ? trace_hardirqs_off_caller+0x1f/0x10e
[15483.926256]  [<ffffffff81032c26>] __do_softirq+0x17f/0x32d
[15483.926262]  [<ffffffff810720c2>] ? clockevents_program_event+0xab/0xc7
[15483.926269]  [<ffffffff813fe40c>] call_softirq+0x1c/0x30
[15483.926277]  [<ffffffff810035bf>] do_softirq+0x3d/0x86
[15483.926282]  [<ffffffff81033021>] irq_exit+0x53/0xbb
[15483.926290]  [<ffffffff813fea2d>] smp_apic_timer_interrupt+0x8a/0x98
[15483.926296]  [<ffffffff813fdbdc>] apic_timer_interrupt+0x6c/0x80
[15483.926304]  <EOI>  [<ffffffff810532b0>] ? __atomic_notifier_call_chain+0xdb/0x109
[15483.926313]  [<ffffffff81009a40>] ? default_idle+0x113/0x24e
[15483.926319]  [<ffffffff81009a3e>] ? default_idle+0x111/0x24e
[15483.926326]  [<ffffffff81009d06>] amd_e400_idle+0xe5/0xe7
[15483.926332]  [<ffffffff8100a4ae>] cpu_idle+0x6c/0xc8
[15483.926339]  [<ffffffff813e044c>] rest_init+0x130/0x137
[15483.926345]  [<ffffffff813e031c>] ? csum_partial_copy_generic+0x16c/0x16c
[15483.926353]  [<ffffffff8186fa30>] start_kernel+0x2d2/0x2df
[15483.926359]  [<ffffffff8186f567>] ? repair_env_string+0x56/0x56
[15483.926366]  [<ffffffff8186f27a>] x86_64_start_reservations+0x7e/0x82
[15483.926373]  [<ffffffff8186f36e>] x86_64_start_kernel+0xf0/0xf7
[15483.926377] ---[ end trace bd46b3883a3ab819 ]---
[15483.926385] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15488.929896] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15498.921512] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15508.913144] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15518.904786] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15528.896409] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15538.888039] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15548.879678] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15558.871309] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15568.862929] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15578.854570] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15588.846189] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15598.837828] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15608.829441] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15618.821083] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15628.812722] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15638.804350] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15648.795974] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15658.787605] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15668.779222] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15678.770871] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15688.762501] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15698.754136] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15708.745764] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15718.737391] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15728.729019] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15738.720654] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15748.712280] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15754.570157] forcedeth 0000:00:08.0: eth0: link down
[15756.972392] forcedeth 0000:00:08.0: eth0: link up
[15762.700565] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15777.679993] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15787.671642] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15797.663285] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15802.667092] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15812.658701] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15822.650341] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15832.641980] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15882.600137] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15892.591755] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15917.562840] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15932.558276] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15962.533183] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15972.524806] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15982.516438] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[15992.508077] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[16002.499699] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[16012.491327] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[16022.482969] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020
[16032.474585] forcedeth 0000:00:08.0: eth0: Got tx_timeout. irq status: 00000020

-- 
Regards/Gruss,
    Boris.
