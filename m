From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 109581] New: WARNING: CPU: 1 PID: 0 at
 net/sched/sch_hfsc.c:1429 hfsc_dequeue+0x166/0x2da()
Date: Fri, 18 Dec 2015 09:23:41 -0800
Message-ID: <20151218092341.217fa9fb@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36131 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933050AbbLRRXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 12:23:35 -0500
Received: by mail-pf0-f169.google.com with SMTP id o64so52014091pfb.3
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 09:23:34 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id fm1sm23576587pab.6.2015.12.18.09.23.34
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 09:23:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 18 Dec 2015 17:12:15 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 109581] New: WARNING: CPU: 1 PID: 0 at net/sched/sch_hfsc.c:1429 hfsc_dequeue+0x166/0x2da()


https://bugzilla.kernel.org/show_bug.cgi?id=109581

            Bug ID: 109581
           Summary: WARNING: CPU: 1 PID: 0 at net/sched/sch_hfsc.c:1429
                    hfsc_dequeue+0x166/0x2da()
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3.3
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: pstaszewski@artcom.pl
        Regression: No

Dec 18 18:08:12 rtbgp05 kernel: [63943.791331] WARNING: CPU: 1 PID: 0 at
net/sched/sch_hfsc.c:1429 hfsc_dequeue+0x166/0x2da()
Dec 18 18:08:12 rtbgp05 kernel: [63943.791332] Modules linked in: ip_vs
act_police bonding ipmi_si ipmi_msghandler
Dec 18 18:08:12 rtbgp05 kernel: [63943.791339] CPU: 1 PID: 0 Comm: swapper/1
Tainted: G        W       4.3.3 #1
Dec 18 18:08:12 rtbgp05 kernel: [63943.791339]  0000000000000595
ffff88021fc43788 ffffffff812550ec 0000000000000000
Dec 18 18:08:12 rtbgp05 kernel: [63943.791341]  0000000000000000
ffff88021fc437c8 ffffffff8103c428 ffff880200c340e8
Dec 18 18:08:12 rtbgp05 kernel: [63943.791344]  ffffffff81528b38
0000000000000000 ffff8802135b3800 ffff8802135b3940
Dec 18 18:08:12 rtbgp05 kernel: [63943.791346] Call Trace:
Dec 18 18:08:12 rtbgp05 kernel: [63943.791347]  <IRQ>  [<ffffffff812550ec>]
dump_stack+0x48/0x5c
Dec 18 18:08:12 rtbgp05 kernel: [63943.791350]  [<ffffffff8103c428>]
warn_slowpath_common+0x97/0xb1
Dec 18 18:08:12 rtbgp05 kernel: [63943.791352]  [<ffffffff81528b38>] ?
hfsc_dequeue+0x166/0x2da
Dec 18 18:08:12 rtbgp05 kernel: [63943.791353]  [<ffffffff8103c457>]
warn_slowpath_null+0x15/0x17
Dec 18 18:08:12 rtbgp05 kernel: [63943.791354]  [<ffffffff81528b38>]
hfsc_dequeue+0x166/0x2da
Dec 18 18:08:12 rtbgp05 kernel: [63943.791356]  [<ffffffff8151ddb9>]
__qdisc_run+0xc0/0x17b
Dec 18 18:08:12 rtbgp05 kernel: [63943.791358]  [<ffffffff815060ec>]
__dev_queue_xmit+0x28d/0x3ee
Dec 18 18:08:12 rtbgp05 kernel: [63943.791360]  [<ffffffff8151d1e3>] ?
eth_header+0x28/0xb5
Dec 18 18:08:12 rtbgp05 kernel: [63943.791361]  [<ffffffff81506266>]
dev_queue_xmit_sk+0xe/0x10
Dec 18 18:08:12 rtbgp05 kernel: [63943.791363]  [<ffffffff8150ff64>]
neigh_connected_output+0xa7/0xc5
Dec 18 18:08:12 rtbgp05 kernel: [63943.791364]  [<ffffffff81540d59>]
ip_finish_output2+0x2b3/0x2fb
Dec 18 18:08:12 rtbgp05 kernel: [63943.791365]  [<ffffffff81535c07>] ?
nf_hook_slow+0x3f/0xb8
Dec 18 18:08:12 rtbgp05 kernel: [63943.791366]  [<ffffffff81541883>]
ip_finish_output+0x131/0x141
Dec 18 18:08:12 rtbgp05 kernel: [63943.791367]  [<ffffffff81541f35>]
ip_output+0x6e/0x73
Dec 18 18:08:12 rtbgp05 kernel: [63943.791369]  [<ffffffff8153ebbf>]
ip_forward_finish+0x7b/0x82
Dec 18 18:08:12 rtbgp05 kernel: [63943.791370]  [<ffffffff8153ef1a>]
ip_forward+0x354/0x3ee
Dec 18 18:08:12 rtbgp05 kernel: [63943.791372]  [<ffffffff8153eb44>] ?
ip_frag_mem+0x43/0x43
Dec 18 18:08:12 rtbgp05 kernel: [63943.791373]  [<ffffffff8153d4f9>]
ip_rcv_finish+0x278/0x294
Dec 18 18:08:12 rtbgp05 kernel: [63943.791375]  [<ffffffff8153d281>] ?
pskb_may_pull+0x2d/0x2d
Dec 18 18:08:12 rtbgp05 kernel: [63943.791376]  [<ffffffff8153d6dd>]
NF_HOOK.clone.11+0x6e/0x77
Dec 18 18:08:12 rtbgp05 kernel: [63943.791377]  [<ffffffff8153d281>] ?
pskb_may_pull+0x2d/0x2d
Dec 18 18:08:12 rtbgp05 kernel: [63943.791378]  [<ffffffff8153daae>]
ip_rcv+0x27e/0x2c0
Dec 18 18:08:12 rtbgp05 kernel: [63943.791379]  [<ffffffff815046a8>]
__netif_receive_skb_core+0x54f/0x592
Dec 18 18:08:12 rtbgp05 kernel: [63943.791381]  [<ffffffff815647a0>] ?
udp4_gro_receive+0x1be/0x1df
Dec 18 18:08:12 rtbgp05 kernel: [63943.791382]  [<ffffffff8156a993>] ?
inet_gro_receive+0x20f/0x238
Dec 18 18:08:12 rtbgp05 kernel: [63943.791383]  [<ffffffff810796de>] ?
timekeeping_get_ns+0x12/0x38
Dec 18 18:08:12 rtbgp05 kernel: [63943.791384]  [<ffffffff8150473d>]
__netif_receive_skb+0x52/0x57
Dec 18 18:08:12 rtbgp05 kernel: [63943.791385]  [<ffffffff815048db>]
netif_receive_skb_internal+0x6b/0x72
Dec 18 18:08:12 rtbgp05 kernel: [63943.791386]  [<ffffffff815052f2>]
napi_gro_receive+0x39/0x7f
Dec 18 18:08:12 rtbgp05 kernel: [63943.791388]  [<ffffffff81433c92>]
ixgbe_clean_rx_irq+0x689/0x700
Dec 18 18:08:12 rtbgp05 kernel: [63943.791389]  [<ffffffff8143470c>]
ixgbe_poll+0x48e/0x5d9
Dec 18 18:08:12 rtbgp05 kernel: [63943.791390]  [<ffffffff8106411b>] ?
__wake_up+0x3f/0x48
Dec 18 18:08:12 rtbgp05 kernel: [63943.791392]  [<ffffffff8103ee38>] ?
irq_exit+0x43/0x45
Dec 18 18:08:12 rtbgp05 kernel: [63943.791394]  [<ffffffff81504ed1>]
net_rx_action+0xdb/0x237
Dec 18 18:08:12 rtbgp05 kernel: [63943.791395]  [<ffffffff8103ebdf>]
__do_softirq+0xb3/0x1ac
Dec 18 18:08:12 rtbgp05 kernel: [63943.791396]  [<ffffffff8103ee2c>]
irq_exit+0x37/0x45
Dec 18 18:08:12 rtbgp05 kernel: [63943.791398]  [<ffffffff81004db2>]
do_IRQ+0xa4/0xbd
Dec 18 18:08:12 rtbgp05 kernel: [63943.791400]  [<ffffffff815eb1ff>]
common_interrupt+0x7f/0x7f
Dec 18 18:08:12 rtbgp05 kernel: [63943.791402]  <EOI>  [<ffffffff814d1178>] ?
cpuidle_enter_state+0x12a/0x180
Dec 18 18:08:12 rtbgp05 kernel: [63943.791402]  [<ffffffff814d113c>] ?
cpuidle_enter_state+0xee/0x180
Dec 18 18:08:12 rtbgp05 kernel: [63943.791403]  [<ffffffff814d11f0>]
cpuidle_enter+0x12/0x14
Dec 18 18:08:12 rtbgp05 kernel: [63943.791405]  [<ffffffff810645d2>]
cpu_startup_entry+0x12e/0x1a8
Dec 18 18:08:12 rtbgp05 kernel: [63943.791406]  [<ffffffff81027bee>]
start_secondary+0xd2/0xd6
Dec 18 18:08:12 rtbgp05 kernel: [63943.791407] ---[ end trace e32226e9e650123c
]---
Dec 18 18:08:12 rtbgp05 kernel: [63943.791413] ------------[ cut here
]------------

-- 
You are receiving this mail because:
You are the assignee for the bug.
