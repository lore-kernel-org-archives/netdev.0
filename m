From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 25 Jun 2012 18:13:17 +0200
Message-ID: <CAMGsXDSSCnOF+CykudBoEjTacSYL4LYG_ZnRTcS+Xzt54LW=Og@mail.gmail.com>
References: <20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
	<20120602111335.0b94fb59@stein>
	<loom.20120611T175322-643@post.gmane.org>
	<20120611204925.GA7070@electric-eye.fr.zoreil.com>
	<CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
	<20120611215203.GA8860@electric-eye.fr.zoreil.com>
	<CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com>
	<20120612052631.GA14567@electric-eye.fr.zoreil.com>
	<CAMGsXDSsSMWfrV1vjnqkWH45ypZw+ZtYF7=ytc79MWRJ5RF5jQ@mail.gmail.com>
	<CAMGsXDRAE5RZduZnTRa-JmA9_N0Kv+juzYNB_0hf-x+Q8nkpSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33498 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996Ab2FYQNS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 12:13:18 -0400
Received: by pbbrp8 with SMTP id rp8so6749452pbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 09:13:18 -0700 (PDT)
In-Reply-To: <CAMGsXDRAE5RZduZnTRa-JmA9_N0Kv+juzYNB_0hf-x+Q8nkpSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The problem still exists in 3.4.4. I'm currently using 3.2.21, which is=
 fine.
Unfortunately it is service affecting, after some time the machine
just froze. I'm using headless setup, so I can not tell if this causes
the problem (logs are empty). But I had with 3.2.x more than 30+ days
uptime and no problems or warnings whatsoever (dmesg and logs are
clear). I do not believe that I'm the only one with this problem,
r8169 is quite popular.
Is there anything what can I provide or try? I do not want to be stuck
on 3.2.x kernel.

[13513.912323] WARNING: at net/sched/sch_generic.c:256
dev_watchdog+0x16b/0x20f()
[13513.912327] Hardware name: SH55J
[13513.912330] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed ou=
t
[13513.912333] Modules linked in: vhost_net cls_route cls_u32 cls_fw
sch_sfq sch_htb ipt_REDIRECT ipt_MASQUERADE ipt_REJECT xt_limit
xt_tcpudp nf_conntrack_ipv6 nf_defrag_ipv6 xt_state iptable_nat nf_nat
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6table_filter
ip6_tables iptable_filter ip_tables x_tables kvm_intel kvm fuse r8169
[13513.912369] Pid: 0, comm: swapper/2 Not tainted 3.4.4 #1
[13513.912372] Call Trace:
[13513.912374]  <IRQ>  [<ffffffff81026881>] ? warn_slowpath_common+0x78=
/0x8c
[13513.912386]  [<ffffffff81026936>] ? warn_slowpath_fmt+0x45/0x4a
[13513.912392]  [<ffffffff81042fc2>] ? scheduler_tick+0xaf/0xc3
[13513.912400]  [<ffffffff81049f70>] ? ktime_get+0x5f/0xb9
[13513.912404]  [<ffffffff812535f0>] ? dev_watchdog+0x16b/0x20f
[13513.912411]  [<ffffffff8102f3ae>] ? run_timer_softirq+0x177/0x209
[13513.912417]  [<ffffffff8103e7b3>] ? hrtimer_interrupt+0x100/0x19b
[13513.912421]  [<ffffffff81253485>] ? qdisc_reset+0x35/0x35
[13513.912428]  [<ffffffff8102b256>] ? __do_softirq+0x7f/0x106
[13513.912434]  [<ffffffff812e2a4c>] ? call_softirq+0x1c/0x30
[13513.912439]  [<ffffffff81003376>] ? do_softirq+0x31/0x67
[13513.912444]  [<ffffffff8102b503>] ? irq_exit+0x44/0x75
[13513.912448]  [<ffffffff810032b5>] ? do_IRQ+0x94/0xad
[13513.912454]  [<ffffffff812e1167>] ? common_interrupt+0x67/0x67
[13513.912457]  <EOI>  [<ffffffff81163f87>] ? intel_idle+0xde/0x103
[13513.912468]  [<ffffffff81163f63>] ? intel_idle+0xba/0x103
[13513.912475]  [<ffffffff81220c4a>] ? cpuidle_idle_call+0x7e/0xc4
[13513.912483]  [<ffffffff81008e92>] ? cpu_idle+0x53/0x7c
[13513.912487] ---[ end trace 635a32207d8c1b48 ]---
[13513.915428] r8169 0000:01:00.0: eth1: link up

Thanks in advance
Tomas


On Tue, Jun 12, 2012 at 4:34 PM, Tomas Papan <tomas.papan@gmail.com> wr=
ote:
> Hi Francois,
>
> Unfortunately after the warning occurred =C2=A0once again after 28 00=
0 seconds.
> Is there anything else what can I do?
>
> Regards
> Tomas
>
> [28914.344765] ------------[ cut here ]------------
> [28914.344775] WARNING: at net/sched/sch_generic.c:256
> dev_watchdog+0x16b/0x20f()
> [28914.344779] Hardware name: SH55J
> [28914.344782] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed =
out
> [28914.344785] Modules linked in: vhost_net cls_route cls_u32 cls_fw
> sch_sfq sch_htb ipt_REDIRECT ipt_MASQUERADE xt_limit xt_tcpudp
> nf_conntrack_ipv6 nf_defrag_ipv6 xt_state iptable_nat nf_nat
> nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6table_filter
> ip6_tables iptable_filter ip_tables x_tables kvm_intel kvm fuse r8169
> [28914.344819] Pid: 0, comm: swapper/2 Not tainted 3.4.2 #1
> [28914.344822] Call Trace:
> [28914.344825] =C2=A0<IRQ> =C2=A0[<ffffffff81026881>] ? warn_slowpath=
_common+0x78/0x8c
> [28914.344837] =C2=A0[<ffffffff81026936>] ? warn_slowpath_fmt+0x45/0x=
4a
> [28914.344843] =C2=A0[<ffffffff81042fc2>] ? scheduler_tick+0xaf/0xc3
> [28914.344850] =C2=A0[<ffffffff81049f70>] ? ktime_get+0x5f/0xb9
> [28914.344855] =C2=A0[<ffffffff812535a0>] ? dev_watchdog+0x16b/0x20f
> [28914.344861] =C2=A0[<ffffffff8102f3ae>] ? run_timer_softirq+0x177/0=
x209
> [28914.344868] =C2=A0[<ffffffff8103e7b3>] ? hrtimer_interrupt+0x100/0=
x19b
> [28914.344872] =C2=A0[<ffffffff81253435>] ? qdisc_reset+0x35/0x35
> [28914.344879] =C2=A0[<ffffffff8102b256>] ? __do_softirq+0x7f/0x106
> [28914.344884] =C2=A0[<ffffffff812e298c>] ? call_softirq+0x1c/0x30
> [28914.344890] =C2=A0[<ffffffff81003376>] ? do_softirq+0x31/0x67
> [28914.344895] =C2=A0[<ffffffff8102b503>] ? irq_exit+0x44/0x75
> [28914.344899] =C2=A0[<ffffffff810032b5>] ? do_IRQ+0x94/0xad
> [28914.344905] =C2=A0[<ffffffff812e10a7>] ? common_interrupt+0x67/0x6=
7
> [28914.344908] =C2=A0<EOI> =C2=A0[<ffffffff81163f07>] ? intel_idle+0x=
de/0x103
> [28914.344919] =C2=A0[<ffffffff81163ee3>] ? intel_idle+0xba/0x103
> [28914.344926] =C2=A0[<ffffffff81220bfa>] ? cpuidle_idle_call+0x7e/0x=
c4
> [28914.344933] =C2=A0[<ffffffff81008e92>] ? cpu_idle+0x53/0x7c
> [28914.344937] ---[ end trace 3d8459064a9171b4 ]---
> [28914.347829] r8169 0000:01:00.0: eth1: link up
