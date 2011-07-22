From: David <david@unsolicited.net>
Subject: Re: Linux 3.0 release
Date: Fri, 22 Jul 2011 20:11:23 +0100
Message-ID: <4E29CB5B.4040408@unsolicited.net>
References: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.unsolicited.net ([173.255.193.191]:50348 "EHLO
	mx1.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166Ab1GVTaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 15:30:23 -0400
In-Reply-To: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/07/11 03:59, Linus Torvalds wrote:
> really smooth. Which is not to say that there may not be bugs, but if
> anything, there are hopefully fewer than usual, rather than the normal
> ".0" problems.

I'm getting the following warning at boot from 3.0, everything seems to be fine otherwise though.

Jul 22 19:40:02 server kernel: [   15.526629] ------------[ cut here ]------------
Jul 22 19:40:02 server kernel: [   15.526635] WARNING: at kernel/timer.c:1011 del_timer_sync+0x4e/0x50()
Jul 22 19:40:02 server kernel: [   15.526637] Hardware name: System Product Name
Jul 22 19:40:02 server kernel: [   15.526638] Modules linked in: xt_owner ipt_REDIRECT ipt_MASQUERADE ts_kmp xt_string ipt_REJECT xt_recent xt_state xt_multiport xt_tcpudp xt_pkttype ipt_LOG xt_limit
iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables ip6table_filter ip6_tables x_tables wctdm dahdi hisax nfsd isl6421 crc_ccitt b2c2_flexcop_pci
dvb_pll b2c2_flexcop mt352 isdn cx24123 dvb_usb_digitv cx24113 s5h1420 dvb_usb e1000e snd_hda_codec_hdmi exportfs it87 dvb_core pl2303 hwmon_vid lp snd_hda_codec_via ppdev nfs k10temp i2c_piix4
snd_hda_intel snd_hda_codec r8169 mii lockd snd_pcm snd_timer snd shpchp soundcore parport_pc snd_page_alloc parport auth_rpcgss nfs_acl sunrpc
Jul 22 19:40:02 server kernel: [   15.526667] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0 #1
Jul 22 19:40:02 server kernel: [   15.526668] Call Trace:
Jul 22 19:40:02 server kernel: [   15.526670]  <IRQ>  [<ffffffff8104599a>] warn_slowpath_common+0x7a/0xb0
Jul 22 19:40:02 server kernel: [   15.526675]  [<ffffffff810459e5>] warn_slowpath_null+0x15/0x20
Jul 22 19:40:02 server kernel: [   15.526677]  [<ffffffff81054b4e>] del_timer_sync+0x4e/0x50
Jul 22 19:40:02 server kernel: [   15.526679]  [<ffffffff8145e224>] linkwatch_schedule_work+0x84/0xa0
Jul 22 19:40:02 server kernel: [   15.526681]  [<ffffffff8145e2bc>] linkwatch_fire_event+0x7c/0x100
Jul 22 19:40:02 server kernel: [   15.526684]  [<ffffffff8146b1ed>] netif_carrier_on+0x2d/0x40
Jul 22 19:40:02 server kernel: [   15.526689]  [<ffffffffa006b6fb>] __rtl8169_check_link_status+0x4b/0xc0 [r8169]
Jul 22 19:40:02 server kernel: [   15.526693]  [<ffffffffa006c016>] rtl8169_interrupt+0x166/0x3a0 [r8169]
Jul 22 19:40:02 server kernel: [   15.526696]  [<ffffffff810a4385>] handle_irq_event_percpu+0x55/0x1f0
Jul 22 19:40:02 server kernel: [   15.526698]  [<ffffffff810a4551>] handle_irq_event+0x31/0x50
Jul 22 19:40:02 server kernel: [   15.526701]  [<ffffffff8101a371>] ? ack_apic_edge+0x31/0x40
Jul 22 19:40:02 server kernel: [   15.526703]  [<ffffffff810a6eb5>] handle_edge_irq+0x65/0x120
Jul 22 19:40:02 server kernel: [   15.526706]  [<ffffffff81003f8d>] handle_irq+0x1d/0x30
Jul 22 19:40:02 server kernel: [   15.526708]  [<ffffffff81003918>] do_IRQ+0x58/0xe0
Jul 22 19:40:02 server kernel: [   15.526711]  [<ffffffff815588d3>] common_interrupt+0x13/0x13
Jul 22 19:40:02 server kernel: [   15.526712]  <EOI>  [<ffffffff8106bf5d>] ? sched_clock_local+0x1d/0x90
Jul 22 19:40:02 server kernel: [   15.526717]  [<ffffffff81009e25>] ? default_idle+0x55/0x170
Jul 22 19:40:02 server kernel: [   15.526719]  [<ffffffff81009fc3>] amd_e400_idle+0x83/0x100
Jul 22 19:40:02 server kernel: [   15.526721]  [<ffffffff8155bb55>] ? atomic_notifier_call_chain+0x15/0x20
Jul 22 19:40:02 server kernel: [   15.526723]  [<ffffffff81001fd9>] cpu_idle+0x59/0xb0
Jul 22 19:40:02 server kernel: [   15.526726]  [<ffffffff81551552>] start_secondary+0x181/0x185
Jul 22 19:40:02 server kernel: [   15.526727] ---[ end trace 5bac97729a402448 ]---

(dual core phenom 2, dmesg etc on request)

Cheers
David

