From: Dave Jones <davej@redhat.com>
Subject: [r8169 3.10rc5] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0
 timed out
Date: Sat, 15 Jun 2013 14:46:46 -0400
Message-ID: <20130615184646.GA19439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278Ab3FOSqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 14:46:55 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5FIktPm026331
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:46:55 -0400
Received: from gelk.kernelslacker.org (ovpn-113-67.phx2.redhat.com [10.3.113.67])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r5FIknPn021166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:46:55 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.5) with ESMTP id r5FIkmIp019635
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:46:49 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r5FIkkpk019634
	for netdev@vger.kernel.org; Sat, 15 Jun 2013 14:46:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see this from time to time, but this is the first time in a few months since
I last saw it..

[90816.000090] ------------[ cut here ]------------
[90816.002995] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x248/0x260()
[90816.006283] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
[90816.009715] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter nf_conntrack_ipv4 nf_defrag_ipv4 ip6_tables xt_conntrack nf_conntrack microcode pcspkr serio_raw r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 video backlight i2c_algo_bit drm_kms_helper drm
[90816.019947] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.10.0-rc5+ #7 
[90816.023930] Hardware name:                  /D510MO, BIOS MOPNV10J.86A.0175.2010.0308.0620 03/08/2010
[90816.027804]  ffffffff817d5979 ffff88007e603d18 ffffffff8152014b ffff88007e603d58
[90816.031640]  ffffffff8103cafb ffff88007e603d38 0000000000000000 ffff8800656b8000
[90816.035623]  ffff880076f74710 0000000000000001 0000000000000002 ffff88007e603db8
[90816.039362] Call Trace:
[90816.043287]  <IRQ>  [<ffffffff8152014b>] dump_stack+0x19/0x1b
[90816.046976]  [<ffffffff8103cafb>] warn_slowpath_common+0x6b/0xa0
[90816.051065]  [<ffffffff8103cbd1>] warn_slowpath_fmt+0x41/0x50
[90816.054851]  [<ffffffff8143d6f8>] dev_watchdog+0x248/0x260
[90816.058889]  [<ffffffff8143d4b0>] ? dev_deactivate_queue.constprop.36+0x70/0x70
[90816.062909]  [<ffffffff8104acc4>] call_timer_fn+0x84/0x100
[90816.066677]  [<ffffffff8104ac40>] ? destroy_timer_on_stack+0x20/0x20
[90816.070626]  [<ffffffff8143d4b0>] ? dev_deactivate_queue.constprop.36+0x70/0x70
[90816.074449]  [<ffffffff8104b2b3>] run_timer_softirq+0x1c3/0x270
[90816.078384]  [<ffffffff81044d72>] __do_softirq+0xe2/0x1c0
[90816.082329]  [<ffffffff81045025>] irq_exit+0xd5/0xe0
[90816.086135]  [<ffffffff81020738>] smp_apic_timer_interrupt+0x68/0xa0
[90816.090290]  [<ffffffff8152e16f>] apic_timer_interrupt+0x6f/0x80
[90816.094132]  <EOI>  [<ffffffff810753c8>] ? sched_clock_cpu+0xa8/0x120
[90816.097966]  [<ffffffff813e0d2e>] ? cpuidle_enter_state+0x5e/0xe0
[90816.101895]  [<ffffffff813e0d2a>] ? cpuidle_enter_state+0x5a/0xe0
[90816.105632]  [<ffffffff813e0e4e>] cpuidle_idle_call+0x9e/0x160
[90816.109484]  [<ffffffff810cdcad>] ? rcu_eqs_enter+0x5d/0xa0
[90816.113393]  [<ffffffff8100a7e9>] arch_cpu_idle+0x9/0x30
[90816.117143]  [<ffffffff81089000>] cpu_startup_entry+0x80/0x1b0
[90816.121225]  [<ffffffff81cab6e0>] start_secondary+0x265/0x26c
[90816.125014] ---[ end trace 4e00436f911bbea3 ]---
[90816.182424] r8169 0000:05:00.0 eth1: link up
