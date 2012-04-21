From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@fiec.espol.edu.ec>
Subject: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Sat, 21 Apr 2012 12:21:17 -0500
Message-ID: <4F92EC8D.2010806@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([200.93.199.101]:38017 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab2DURxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 13:53:08 -0400
Received: from karlalex.palosanto.com (unknown [190.130.130.80])
	by pbx.palosanto.com (Postfix) with ESMTP id AFBCD1368001
	for <netdev@vger.kernel.org>; Sat, 21 Apr 2012 12:21:29 -0500 (ECT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting the following WARNING while running 3.4-rc3 x86_64. Every 
time I get this, I am running my Bittorrent client (transmission-gtk).

[ 1494.720011] ------------[ cut here ]------------
[ 1494.720024] WARNING: at net/sched/sch_generic.c:256 
dev_watchdog+0x277/0x280()
[ 1494.720027] Hardware name: OEM
[ 1494.720031] NETDEV WATCHDOG: p17p1 (r8169): transmit queue 0 timed out
[ 1494.720034] Modules linked in: fuse vboxpci(O) vboxnetadp(O) 
vboxnetflt(O) lockd vboxdrv(O) nf_conntrack_ipv4 nf_defrag_ipv4 
ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack 
ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel 
snd_hda_codec snd_hwdep snd_seq snd_seq_device ppdev snd_pcm uinput 
coretemp microcode pcspkr iTCO_wdt iTCO_vendor_support i2c_i801 
parport_pc parport snd_timer snd soundcore r8169 mii snd_page_alloc 
sunrpc binfmt_misc floppy i915 drm_kms_helper drm i2c_algo_bit i2c_core 
video [last unloaded: scsi_wait_scan]
[ 1494.720100] Pid: 0, comm: swapper/1 Tainted: G           O 3.4.0-rc3 #35
[ 1494.720103] Call Trace:
[ 1494.720106] <IRQ>  [<ffffffff81059bbf>] warn_slowpath_common+0x7f/0xc0
[ 1494.720120]  [<ffffffff81059cb6>] warn_slowpath_fmt+0x46/0x50
[ 1494.720127]  [<ffffffff8151ab97>] dev_watchdog+0x277/0x280
[ 1494.720134]  [<ffffffff81068f61>] run_timer_softirq+0x131/0x440
[ 1494.720139]  [<ffffffff8151a920>] ? qdisc_reset+0x50/0x50
[ 1494.720145]  [<ffffffff810611a8>] __do_softirq+0xb8/0x280
[ 1494.720151]  [<ffffffff8101cd62>] ? native_sched_clock+0x22/0x80
[ 1494.720157]  [<ffffffff81090895>] ? sched_clock_local+0x25/0x90
[ 1494.720164]  [<ffffffff8161619c>] call_softirq+0x1c/0x30
[ 1494.720170]  [<ffffffff810172e5>] do_softirq+0x65/0xa0
[ 1494.720174]  [<ffffffff8106169e>] irq_exit+0x9e/0xc0
[ 1494.720180]  [<ffffffff81616acb>] smp_apic_timer_interrupt+0x6b/0x98
[ 1494.720186]  [<ffffffff8161584a>] apic_timer_interrupt+0x6a/0x70
[ 1494.720190] <EOI>  [<ffffffff8101e253>] ? mwait_idle+0x93/0x320
[ 1494.720199]  [<ffffffff8101e1fa>] ? mwait_idle+0x3a/0x320
[ 1494.720204]  [<ffffffff8101ee19>] cpu_idle+0xd9/0x130
[ 1494.720210]  [<ffffffff815fb7cf>] start_secondary+0x266/0x26d
[ 1494.720216] ---[ end trace b0a1361739c69d32 ]---
[ 1494.721181] r8169 0000:02:00.0: p17p1: link up
