From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 11 Jun 2012 23:04:22 +0200
Message-ID: <CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
References: <20120501182405.3dda59b9@stein>
	<20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
	<20120602111335.0b94fb59@stein>
	<loom.20120611T175322-643@post.gmane.org>
	<20120611204925.GA7070@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36617 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab2FKVEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 17:04:23 -0400
Received: by pbbrp8 with SMTP id rp8so6102461pbb.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:04:22 -0700 (PDT)
In-Reply-To: <20120611204925.GA7070@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

here you are:

[ 2839.337509] WARNING: at net/sched/sch_generic.c:256
dev_watchdog+0x16b/0x20f()
[ 2839.337513] Hardware name: SH55J
[ 2839.337516] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
[ 2839.337519] Modules linked in: vhost_net cls_route cls_u32 cls_fw
sch_sfq sch_htb ipt_REDIRECT ipt_MASQUERADE xt_limit xt_tcpudp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_state iptable_nat nf_nat
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6table_filter
ip6_tables iptable_filter ip_tables x_tables kvm_intel kvm fuse r8169
[ 2839.337554] Pid: 0, comm: swapper/3 Not tainted 3.4.2 #1
[ 2839.337556] Call Trace:
[ 2839.337559]  <IRQ>  [<ffffffff81026881>] ? warn_slowpath_common+0x78/0x8c
[ 2839.337571]  [<ffffffff81026936>] ? warn_slowpath_fmt+0x45/0x4a
[ 2839.337576]  [<ffffffff81042fc2>] ? scheduler_tick+0xaf/0xc3
[ 2839.337582]  [<ffffffff812535a0>] ? dev_watchdog+0x16b/0x20f
[ 2839.337588]  [<ffffffff8102f3ae>] ? run_timer_softirq+0x177/0x209
[ 2839.337594]  [<ffffffff8103e7b3>] ? hrtimer_interrupt+0x100/0x19b
[ 2839.337599]  [<ffffffff81253435>] ? qdisc_reset+0x35/0x35
[ 2839.337605]  [<ffffffff8102b256>] ? __do_softirq+0x7f/0x106
[ 2839.337611]  [<ffffffff812e298c>] ? call_softirq+0x1c/0x30
[ 2839.337616]  [<ffffffff81003376>] ? do_softirq+0x31/0x67
[ 2839.337621]  [<ffffffff8102b503>] ? irq_exit+0x44/0x75
[ 2839.337625]  [<ffffffff810032b5>] ? do_IRQ+0x94/0xad
[ 2839.337631]  [<ffffffff812e10a7>] ? common_interrupt+0x67/0x67
[ 2839.337634]  <EOI>  [<ffffffff81163f07>] ? intel_idle+0xde/0x103
[ 2839.337645]  [<ffffffff81163ee3>] ? intel_idle+0xba/0x103
[ 2839.337652]  [<ffffffff81220bfa>] ? cpuidle_idle_call+0x7e/0xc4
[ 2839.337659]  [<ffffffff81008e92>] ? cpu_idle+0x53/0x7c
[ 2839.337663] ---[ end trace 04a2b9c09e9d7860 ]---
[ 2839.341697] r8169 0000:01:00.0: eth1: link up

If you need something else just tell me.

Thanks in advance

Regards
Tomas

On Mon, Jun 11, 2012 at 10:49 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Tomas Papan <tomas.papan@gmail.com> :
> [...]
>> I have the same problem on 3.4.1 and 3.4.2 (3.2.x is fine)
>> interestingly enough, the problem occurs only once, then it is running fine
>> (3.4.1 and six days uptime)
>
> Please send a complete dmesg including the XID line emitted by the
> r8169 driver.
>
> --
> Ueimor
