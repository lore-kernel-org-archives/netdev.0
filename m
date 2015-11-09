From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 106711] VXLAN: RTNL assertion failed at
 net/core/net_namespace.c:187
Date: Mon, 9 Nov 2015 10:39:29 -0800
Message-ID: <20151109103929.572fb840@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36529 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbKISjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 13:39:20 -0500
Received: by pacdm15 with SMTP id dm15so182703670pac.3
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 10:39:19 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id hi4sm17753354pbc.7.2015.11.09.10.39.18
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:39:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 9 Nov 2015 09:42:52 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 106711] VXLAN: RTNL assertion failed at net/core/net_namespace.c:187


https://bugzilla.kernel.org/show_bug.cgi?id=106711

Kari Hautio <khautio@gmail.com> changed:

           What    |Removed                     |Added
----------------------------------------------------------------------------
                 CC|                            |khautio@gmail.com

--- Comment #1 from Kari Hautio <khautio@gmail.com> ---
Also affects 4.1.12

[   34.412104] RTNL: assertion failed at
/home/kernel/COD/linux/net/core/net_namespace.c (187)
[   34.412120] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.1.12-040112-generic
#201510262131
[   34.412123] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.7.5-20140709_153950- 04/01/2014
[   34.412126]  ffff880035dd2380 ffff88013fd838f8 ffffffff817e367c
0000000000000000
[   34.412131]  00000000ffffffff ffff88013fd83928 ffffffff816cfbe5
ffff880035526200
[   34.412135]  ffff8800b9b3fe00 ffff88013a3dc9c0 ffff88013a3dccc0
ffff88013fd83938
[   34.412140] Call Trace:
[   34.412142]  <IRQ>  [<ffffffff817e367c>] dump_stack+0x45/0x57
[   34.412159]  [<ffffffff816cfbe5>] __peernet2id+0xa5/0xb0
[   34.412163]  [<ffffffff816cfc08>] peernet2id+0x18/0x30
[   34.412168]  [<ffffffffc034587a>] vxlan_fdb_info+0xfa/0x360 [vxlan]
[   34.412173]  [<ffffffff816c788c>] ? __alloc_skb+0x8c/0x1f0
[   34.412178]  [<ffffffffc0345b52>] vxlan_fdb_notify+0x72/0x100 [vxlan]
[   34.412182]  [<ffffffffc034634a>] vxlan_fdb_create+0x14a/0x3a0 [vxlan]
[   34.412187]  [<ffffffffc0346f0b>] vxlan_snoop+0x1cb/0x1d0 [vxlan]
[   34.412192]  [<ffffffffc03475a2>] vxlan_rcv+0x3a2/0x620 [vxlan]
[   34.412196]  [<ffffffffc03490d6>] vxlan_udp_encap_recv+0x156/0x420 [vxlan]
[   34.412201]  [<ffffffffc0348f80>] ? vxlan_open+0x1e0/0x1e0 [vxlan]
[   34.412207]  [<ffffffff817487b3>] udp_queue_rcv_skb+0x1f3/0x4f0
[   34.412211]  [<ffffffff817490a7>] __udp4_lib_rcv+0x127/0x930
[   34.412215]  [<ffffffff81749dda>] udp_rcv+0x1a/0x20
[   34.412227]  [<ffffffff81715e1e>] ip_local_deliver_finish+0xae/0x230
[   34.412231]  [<ffffffff81716136>] ip_local_deliver+0x46/0xa0
[   34.412235]  [<ffffffff81715a81>] ip_rcv_finish+0x81/0x370
[   34.412239]  [<ffffffff81716432>] ip_rcv+0x2a2/0x3c0
[   34.412244]  [<ffffffff816d98f3>] __netif_receive_skb_core+0x7e3/0xa10
[   34.412248]  [<ffffffff816d9b38>] __netif_receive_skb+0x18/0x60
[   34.412252]  [<ffffffff816da8e2>] process_backlog+0xb2/0x150
[   34.412256]  [<ffffffff816da0aa>] net_rx_action+0x1fa/0x320
[   34.412265]  [<ffffffff8107e093>] __do_softirq+0x103/0x280
[   34.412269]  [<ffffffff8107e39d>] irq_exit+0xad/0xb0
[   34.412274]  [<ffffffff817ed5b6>] smp_apic_timer_interrupt+0x46/0x60
[   34.412279]  [<ffffffff817eb63e>] apic_timer_interrupt+0x6e/0x80
[   34.412280]  <EOI>  [<ffffffff8105fb56>] ? native_safe_halt+0x6/0x10
[   34.412290]  [<ffffffff810de4e3>] ? rcu_eqs_enter+0xa3/0xb0
[   34.412297]  [<ffffffff8101ec4e>] default_idle+0x1e/0xc0
[   34.412315]  [<ffffffff8101f7df>] arch_cpu_idle+0xf/0x20
[   34.412325]  [<ffffffff810bd557>] cpu_startup_entry+0x367/0x3e0
[   34.412332]  [<ffffffff810f48b2>] ? clockevents_register_device+0x112/0x1e0
[   34.412338]  [<ffffffff8104cb6e>] start_secondary+0x17e/0x1a0

-- 
You are receiving this mail because:
You are the assignee for the bug.
