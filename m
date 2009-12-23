From: Yinghai Lu <yinghai@kernel.org>
Subject: ixgbe warning
Date: Tue, 22 Dec 2009 21:00:27 -0800
Message-ID: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

bunch of warning...

[  809.824721] WARNING: at net/core/dev.c:1908 dev_queue_xmit+0x243/0x4c7()
[  809.832183] Hardware name: Sun
[  809.832193] eth16 selects TX queue 98, but real number of TX queues is 64
[  809.832203] Modules linked in:
[  809.832216] Pid: 26440, comm: iperf Not tainted
2.6.33-rc1-tip-yh-00304-g97a015d-dirty #1007
[  809.832221] Call Trace:
[  809.832232]  <IRQ>  [<ffffffff81c14e08>] ? dev_queue_xmit+0x243/0x4c7
[  809.832266]  [<ffffffff8107a098>] warn_slowpath_common+0x7c/0xa9
[  809.832283]  [<ffffffff8107a11c>] warn_slowpath_fmt+0x41/0x43
[  809.832300]  [<ffffffff81c14e08>] dev_queue_xmit+0x243/0x4c7
[  809.832319]  [<ffffffff81c14d5a>] ? dev_queue_xmit+0x195/0x4c7
[  809.832340]  [<ffffffff81c52e87>] arp_send+0x39/0x3b
[  809.832355]  [<ffffffff81c5384c>] arp_solicit+0x1da/0x1f7
[  809.832376]  [<ffffffff81c1d89d>] neigh_timer_handler+0x243/0x292
[  809.832391]  [<ffffffff81c1d65a>] ? neigh_timer_handler+0x0/0x292
[  809.832411]  [<ffffffff8108844b>] run_timer_softirq+0x265/0x322
[  809.832429]  [<ffffffff810883af>] ? run_timer_softirq+0x1c9/0x322
[  809.832448]  [<ffffffff81098bd3>] ? __run_hrtimer+0x104/0x132
[  809.832471]  [<ffffffff81080909>] __do_softirq+0xee/0x1b9
[  809.832488]  [<ffffffff81034a8c>] call_softirq+0x1c/0x3e
[  809.832499]  [<ffffffff810360e9>] do_softirq+0x3d/0x85
[  809.832516]  [<ffffffff81080492>] irq_exit+0x4a/0x89
[  809.832536]  [<ffffffff81d37afb>] smp_apic_timer_interrupt+0x8d/0x9b
[  809.832557]  [<ffffffff81034553>] apic_timer_interrupt+0x13/0x20
[  809.832563]  <EOI>  [<ffffffff81068e41>] ? walk_tg_tree+0x0/0xe3
[  809.832594]  [<ffffffff810a6f29>] ? trace_hardirqs_on+0xd/0xf
[  809.832616]  [<ffffffff81d32759>] ? _raw_spin_unlock_irq+0x33/0x36
[  809.832634]  [<ffffffff81d2fc12>] schedule+0x7a2/0x83d
[  809.832649]  [<ffffffff81d32756>] ? _raw_spin_unlock_irq+0x30/0x36
[  809.832666]  [<ffffffff81d31b97>] __down_read+0x97/0xc4
[  809.832674]  [<ffffffff81d311c7>] down_read+0x6d/0x81
[  809.832684]  [<ffffffff81d3539e>] ? do_page_fault+0x1bb/0x31d
[  809.832699]  [<ffffffff81d3539e>] do_page_fault+0x1bb/0x31d
[  809.832716]  [<ffffffff81d32c7f>] page_fault+0x1f/0x30
[  809.832726] ---[ end trace 9c325e35daa3e5c8 ]---
[  809.851136] ------------[ cut here ]------------
[  809.851146] WARNING: at net/core/dev.c:1908 dev_queue_xmit+0x243/0x4c7()
[  809.851155] Hardware name: Sun
[  809.851165] eth13 selects TX queue 98, but real number of TX queues is 64
[  809.851175] Modules linked in:
[  809.851192] Pid: 0, comm: swapper Tainted: G        W
2.6.33-rc1-tip-yh-00304-g97a015d-dirty #1007
[  809.851201] Call Trace:
[  809.851212]  <IRQ>  [<ffffffff81c14e08>] ? dev_queue_xmit+0x243/0x4c7
[  809.851240]  [<ffffffff8107a098>] warn_slowpath_common+0x7c/0xa9
[  809.851257]  [<ffffffff8107a11c>] warn_slowpath_fmt+0x41/0x43
[  809.851271]  [<ffffffff81c14e08>] dev_queue_xmit+0x243/0x4c7
[  809.851283]  [<ffffffff81c14d5a>] ? dev_queue_xmit+0x195/0x4c7
[  809.851298]  [<ffffffff81c52e87>] arp_send+0x39/0x3b
[  809.851312]  [<ffffffff81c5384c>] arp_solicit+0x1da/0x1f7
[  809.851327]  [<ffffffff81c1d89d>] neigh_timer_handler+0x243/0x292
[  809.851342]  [<ffffffff81c1d65a>] ? neigh_timer_handler+0x0/0x292
[  809.851357]  [<ffffffff8108844b>] run_timer_softirq+0x265/0x322
[  809.851371]  [<ffffffff810883af>] ? run_timer_softirq+0x1c9/0x322
[  809.851388]  [<ffffffff81098bd3>] ? __run_hrtimer+0x104/0x132
[  809.851423]  [<ffffffff81080909>] __do_softirq+0xee/0x1b9
[  809.851439]  [<ffffffff81034a8c>] call_softirq+0x1c/0x3e
[  809.851454]  [<ffffffff810360e9>] do_softirq+0x3d/0x85
[  809.851473]  [<ffffffff81080492>] irq_exit+0x4a/0x89
[  809.851490]  [<ffffffff81d37afb>] smp_apic_timer_interrupt+0x8d/0x9b
[  809.851507]  [<ffffffff81034553>] apic_timer_interrupt+0x13/0x20
[  809.851515]  <EOI>  [<ffffffff8106a2a4>] ? update_shares+0x5a/0x5f
[  809.851549]  [<ffffffff81d35597>] ? __atomic_notifier_call_chain+0x0/0x8c
[  809.851572]  [<ffffffff810a6f29>] ? trace_hardirqs_on+0xd/0xf
[  809.851606]  [<ffffffff8103aaf4>] ? mwait_idle+0xaf/0xbc
[  809.851628]  [<ffffffff8103aaeb>] ? mwait_idle+0xa6/0xbc
[  809.851649]  [<ffffffff81032d95>] cpu_idle+0x64/0xa1
[  809.851676]  [<ffffffff81d2a044>] start_secondary+0xa6/0xa8
[  809.851708] ---[ end trace 9c325e35daa3e5c9 ]---
[  809.852208] ------------[ cut here ]------------
[  809.852223] WARNING: at net/core/dev.c:1908 dev_queue_xmit+0x243/0x4c7()
[  809.852227] Hardware name: Sun
[  809.852233] eth12 selects TX queue 113, but real number of TX queues is 64
[  809.852238] Modules linked in:
[  809.852257] Pid: 26428, comm: iperf Tainted: G        W
2.6.33-rc1-tip-yh-00304-g97a015d-dirty #1007
[  809.852262] Call Trace:
[  809.852268]  <IRQ>  [<ffffffff81c14e08>] ? dev_queue_xmit+0x243/0x4c7
[  809.852306]  [<ffffffff8107a098>] warn_slowpath_common+0x7c/0xa9
[  809.852317]  [<ffffffff8107a11c>] warn_slowpath_fmt+0x41/0x43
[  809.852325]  [<ffffffff81c14e08>] dev_queue_xmit+0x243/0x4c7
[  809.852334]  [<ffffffff81c14d5a>] ? dev_queue_xmit+0x195/0x4c7
[  809.852349]  [<ffffffff81c52e87>] arp_send+0x39/0x3b
[  809.852359]  [<ffffffff81c5384c>] arp_solicit+0x1da/0x1f7
[  809.852370]  [<ffffffff81c1d89d>] neigh_timer_handler+0x243/0x292
[  809.852382]  [<ffffffff81c1d65a>] ? neigh_timer_handler+0x0/0x292
[  809.852393]  [<ffffffff8108844b>] run_timer_softirq+0x265/0x322
[  809.852401]  [<ffffffff810883af>] ? run_timer_softirq+0x1c9/0x322
[  809.852414]  [<ffffffff81098bd3>] ? __run_hrtimer+0x104/0x132
[  809.852433]  [<ffffffff81080909>] __do_softirq+0xee/0x1b9
[  809.852442]  [<ffffffff81034a8c>] call_softirq+0x1c/0x3e
[  809.852452]  [<ffffffff810360e9>] do_softirq+0x3d/0x85
[  809.852460]  [<ffffffff81080492>] irq_exit+0x4a/0x89
[  809.852470]  [<ffffffff81d37afb>] smp_apic_timer_interrupt+0x8d/0x9b
[  809.852481]  [<ffffffff81034553>] apic_timer_interrupt+0x13/0x20
[  809.852486]  <EOI>  [<ffffffff810a6f29>] ? trace_hardirqs_on+0xd/0xf
[  809.852505]  [<ffffffff8106a9fb>] ? tg_shares_up+0x260/0x271
[  809.852516]  [<ffffffff8106a79b>] ? tg_shares_up+0x0/0x271
[  809.852525]  [<ffffffff81062330>] ? tg_nop+0x0/0xd
[  809.852537]  [<ffffffff81068ee9>] walk_tg_tree+0xa8/0xe3
[  809.852549]  [<ffffffff81068e41>] ? walk_tg_tree+0x0/0xe3
[  809.852557]  [<ffffffff8106a2a4>] update_shares+0x5a/0x5f
[  809.852565]  [<ffffffff8106af63>] select_task_rq_fair+0x2c1/0x41c
[  809.852589]  [<ffffffff8107463d>] sched_fork+0xed/0x1a0
[  809.852600]  [<ffffffff81078c28>] copy_process+0x5a0/0xf1e
[  809.852615]  [<ffffffff810a5c2e>] ? trace_hardirqs_off_caller+0x1f/0xa9
[  809.852624]  [<ffffffff8107970f>] do_fork+0x169/0x334
[  809.852632]  [<ffffffff810a6f29>] ? trace_hardirqs_on+0xd/0xf
[  809.852649]  [<ffffffff8152a4c7>] ? __up_write+0xf8/0x107
[  809.852660]  [<ffffffff81d31c3d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  809.852671]  [<ffffffff81033c0c>] ? sysret_check+0x27/0x62
[  809.852686]  [<ffffffff8103aef2>] sys_clone+0x28/0x2a
[  809.852695]  [<ffffffff81033ec3>] stub_clone+0x13/0x20
[  809.852703]  [<ffffffff81033bdb>] ? system_call_fastpath+0x16/0x1b
[  809.852724] ---[ end trace 9c325e35daa3e5ca ]---
[  809.860981] ------------[ cut here ]------------
[  809.861001] WARNING: at net/core/dev.c:1908 dev_queue_xmit+0x243/0x4c7()
[  809.861009] Hardware name: Sun
[  809.861019] eth12 selects TX queue 82, but real number of TX queues is 64
[  809.861029] Modules linked in:
[  809.861043] Pid: 26443, comm: iperf Tainted: G        W
2.6.33-rc1-tip-yh-00304-g97a015d-dirty #1007
[  809.861053] Call Trace:
[  809.861091]  [<ffffffff81c14e08>] ? dev_queue_xmit+0x243/0x4c7
[  809.861111]  [<ffffffff8107a098>] warn_slowpath_common+0x7c/0xa9
[  809.861127]  [<ffffffff8107a11c>] warn_slowpath_fmt+0x41/0x43
[  809.861146]  [<ffffffff81c14e08>] dev_queue_xmit+0x243/0x4c7
[  809.861163]  [<ffffffff81c14d5a>] ? dev_queue_xmit+0x195/0x4c7
[  809.861180]  [<ffffffff81c33fca>] ip_finish_output+0x233/0x27a
[  809.861197]  [<ffffffff81c34076>] ip_output+0x65/0x67
[  809.861211]  [<ffffffff81c31e55>] ip_local_out+0x65/0x67
[  809.861227]  [<ffffffff81c339be>] ip_queue_xmit+0x2e7/0x333
[  809.861268]  [<ffffffff81c45869>] tcp_transmit_skb+0x55c/0x59f
[  809.861285]  [<ffffffff81c47f19>] tcp_write_xmit+0x311/0x3e6
[  809.861306]  [<ffffffff8110c03b>] ? might_fault+0x53/0xa0
[  809.861326]  [<ffffffff81c48053>] __tcp_push_pending_frames+0x2f/0x85
[  809.861339]  [<ffffffff8110c03b>] ? might_fault+0x53/0xa0
[  809.861359]  [<ffffffff81c3c177>] tcp_sendmsg+0x934/0xa3c
[  809.861374]  [<ffffffff81c03e76>] sock_sendmsg+0xc0/0xd9
[  809.861391]  [<ffffffff810a978c>] ? print_lock_contention_bug+0x1e/0x110
[  809.861412]  [<ffffffff810962a8>] ? finish_wait+0x40/0x6a
[  809.861434]  [<ffffffff81132767>] ? fget_light+0xd0/0x100
[  809.861468]  [<ffffffff81c03ef2>] ? sockfd_lookup_light+0x20/0x59
[  809.861484]  [<ffffffff81c045bc>] sys_sendto+0xe4/0x10c
[  809.861503]  [<ffffffff8110c03b>] ? might_fault+0x53/0xa0
[  809.861520]  [<ffffffff81c024da>] ? move_addr_to_user+0x61/0x7f
[  809.861538]  [<ffffffff81c0467a>] ? sys_getpeername+0x80/0x94
[  809.861563]  [<ffffffff81d31c3d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  809.861589]  [<ffffffff81033bdb>] system_call_fastpath+0x16/0x1b
[  809.861626] ---[ end trace 9c325e35daa3e5cb ]---
[  809.867916] ------------[ cut here ]------------

------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
