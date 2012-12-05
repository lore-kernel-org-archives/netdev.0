From: Dave Jones <davej@redhat.com>
Subject: NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
Date: Tue, 4 Dec 2012 20:19:10 -0500
Message-ID: <20121205011910.GA16531@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093Ab2LEBTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 20:19:13 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qB51JDh3022567
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 4 Dec 2012 20:19:13 -0500
Received: from gelk.kernelslacker.org (ovpn-113-42.phx2.redhat.com [10.3.113.42])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qB51JCrf020509
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 4 Dec 2012 20:19:12 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id qB51JB4d025841
	for <netdev@vger.kernel.org>; Tue, 4 Dec 2012 20:19:11 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id qB51JA5i025840
	for netdev@vger.kernel.org; Tue, 4 Dec 2012 20:19:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We continue to see warnings like this reported against the Fedora kernel
for a number of different NICs. I just hit this one myself for the first time
on that hardware iirc.

Anything else I can provide ?

	Dave

[22347.960097] ------------[ cut here ]------------
[22347.965388] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x258/0x270()
[22347.973764] Hardware name:         
[22347.977748] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
[22347.985212] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_conntrack ip6_tables nf_conntrack microcode pcspkr r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 video backlight i2c_algo_bit drm_kms_helper drm
[22348.020948] Pid: 0, comm: swapper/3 Not tainted 3.7.0-rc8+ #5
[22348.027483] Call Trace:
[22348.030420]  <IRQ>  [<ffffffff8104928f>] warn_slowpath_common+0x7f/0xc0
[22348.038029]  [<ffffffff81049386>] warn_slowpath_fmt+0x46/0x50
[22348.044710]  [<ffffffff814d35a8>] dev_watchdog+0x258/0x270
[22348.051096]  [<ffffffff814d3350>] ? dev_deactivate_queue.constprop.30+0x80/0x80
[22348.059408]  [<ffffffff8105afea>] call_timer_fn+0x8a/0x330
[22348.065791]  [<ffffffff8105af65>] ? call_timer_fn+0x5/0x330
[22348.072276]  [<ffffffff814d3350>] ? dev_deactivate_queue.constprop.30+0x80/0x80
[22348.080721]  [<ffffffff814d3350>] ? dev_deactivate_queue.constprop.30+0x80/0x80
[22348.089032]  [<ffffffff8105b4d4>] run_timer_softirq+0x244/0x380
[22348.095913]  [<ffffffff81052a00>] __do_softirq+0xe0/0x3c0
[22348.102204]  [<ffffffff810a71d4>] ? tick_program_event+0x24/0x30
[22348.109045]  [<ffffffff815e36cc>] call_softirq+0x1c/0x26
[22348.115236]  [<ffffffff810043cd>] do_softirq+0x8d/0xc0
[22348.121226]  [<ffffffff81052eb5>] irq_exit+0xd5/0xe0
[22348.126882]  [<ffffffff815e381b>] smp_apic_timer_interrupt+0x6b/0x98
[22348.134253]  [<ffffffff815e302f>] apic_timer_interrupt+0x6f/0x80
[22348.141293]  <EOI>  [<ffffffff8108bad5>] ? sched_clock_local+0x25/0xa0
[22348.148819]  [<ffffffff81343d3d>] ? intel_idle+0xfd/0x160
[22348.155110]  [<ffffffff81343d36>] ? intel_idle+0xf6/0x160
[22348.161399]  [<ffffffff81474dc9>] cpuidle_enter+0x19/0x20
[22348.167562]  [<ffffffff81475462>] cpuidle_idle_call+0xa2/0x5f0
[22348.174346]  [<ffffffff8100c59a>] cpu_idle+0xca/0x160
[22348.180235]  [<ffffffff81ceead4>] start_secondary+0x251/0x258
[22348.186776] ---[ end trace 62a349a839e1b608 ]---
[22348.261360] r8169 0000:05:00.0 eth1: link up
