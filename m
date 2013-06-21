From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60011] New: kernel panic on host
Date: Fri, 21 Jun 2013 08:50:29 -0700
Message-ID: <20130621085029.4a25e7b0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:42718 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161367Ab3FUPue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 11:50:34 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so7965226pac.26
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 08:50:33 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id br1sm5355239pbb.4.2013.06.21.08.50.32
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 21 Jun 2013 08:50:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 20 Jun 2013 23:04:51 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60011] New: kernel panic on host


https://bugzilla.kernel.org/show_bug.cgi?id=60011

           Summary: kernel panic on host
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39.4-64bit
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: 2steve@naver.com
        Regression: No


Hi I'am using Inline server that uses bridge and 1000mbps fiber port.
Kernel panic occurs several times a day.
The kernel version is 2.6.39.4-64bit and this is panic message.

BUG: unable to handle kernel paging request at ffffffff94c4aa03
[56777.802451] IP: [<ffffffffa01d6d83>] e1000_xmit_frame+0x9f/0x935 [e1000e]
[56777.809306] PGD 1605067 PUD 1609063 PMD 0
[56777.813473] Oops: 0000 [#1] SMP
[56777.816749] last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.3/i2c-0/0-0026/bypass0
[56777.824706] CPU 0
[56777.826577] Modules linked in: privacycenter network_bypass w83627hf_wdt
nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack bridge stp loop evdev psmouse
i2c_i801 i2c_core processor tpm_tis button tpm video serio_raw

tpm_bios ext3 jbd mbcache sd_mod crc_t10dif ata_generic ata_piix libata e1000e
scsi_mod ehci_hcd usbcore igb thermal dca fan thermal_sys [last unloaded:
privacycenter]
[56777.860974]
[56777.862483] Pid: 0, comm: swapper Tainted: G        W   2.6.39.4 #28 To be
filled by O.E.M. To be filled by O.E.M./CARLOW
[56777.873584] RIP: 0010:[<ffffffffa01d6d83>]  [<ffffffffa01d6d83>]
e1000_xmit_frame+0x9f/0x935 [e1000e]
[56777.882923] RSP: 0018:ffff88011e203450  EFLAGS: 00010202
[56777.888296] RAX: 00000000ffff8801 RBX: ffff880113b08bc0 RCX:
ffffffff94c4a9f7
[56777.895507] RDX: ffffffff81141dd7 RSI: ffff880113b08aa0 RDI:
ffff880113b08bc0
[56777.902680] RBP: ffff88011e2034f0 R08: ffff8801132a909c R09:
ffff8800d4da8440
[56777.909865] R10: ffff88011e203580 R11: ffff88011e203350 R12:
0000000013b1041f
[56777.917073] R13: 000000000000000d R14: ffff88011397c700 R15:
ffff88011397c000
[56777.924316] FS:  0000000000000000(0000) GS:ffff88011e200000(0000)
knlGS:0000000000000000
[56777.932481] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[56777.938286] CR2: ffffffff94c4aa03 CR3: 0000000113400000 CR4:
00000000000406f0
[56777.945450] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[56777.952703] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[56777.959903] Process swapper (pid: 0, threadinfo ffffffff81600000, task
ffffffff8160b020)
[56777.968067] Stack:
[56777.970086]  ffff880102a70d00 0000000000000001 0000000000000003
ffffe8ffffc9c018
[56777.977616]  0000000000000000 0000000000000000 ffff88011e203490
ffffffff810407e8
[56777.985111]  ffff88011321c780 ffffffff81035f3b ffff88011397c000
ffffe8ffffc9c030
[56777.992642] Call Trace:
[56777.995126]  <IRQ>
[56777.997262]  [<ffffffff810407e8>] ? default_wake_function+0xd/0xf
[56778.003421]  [<ffffffff81035f3b>] ? __wake_up_common+0x49/0x7f
[56778.009340]  [<ffffffff812769bc>] dev_hard_start_xmit+0x490/0x559
[56778.022319]  [<ffffffff81290539>] sch_direct_xmit+0x66/0x142
[56778.028046]  [<ffffffff81276db1>] dev_queue_xmit+0x32c/0x4f2
[56778.033769]  [<ffffffffa0299256>] br_dev_queue_push_xmit+0x8f/0x95 [bridge]
[56778.040766]  [<ffffffff81023a26>] ? native_apic_msr_write+0x32/0x36
[56778.047093]  [<ffffffffa029e4c5>] br_nf_dev_queue_xmit+0x7e/0x82 [bridge]
[56778.053983]  [<ffffffffa029e447>] ? br_parse_ip_options+0x199/0x199 [bridge]
[56778.061121]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.067447]  [<ffffffffa029e003>] ? nf_bridge_pull_encap_header+0x2f/0x3c
[bridge]
[56778.075056]  [<ffffffffa029e228>] br_nf_post_routing+0x1cb/0x1e0 [bridge]
[56778.081891]  [<ffffffff81062191>] ? hrtimer_interrupt+0x105/0x1ae
[56778.088068]  [<ffffffff8129ac4a>] nf_iterate+0x43/0x7e
[56778.093243]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.099924]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.106613]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56778.112046]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.118753]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.124914]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.131594]  [<ffffffffa029929d>] T.923+0x41/0x53 [bridge]
[56778.137113]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.143257]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.149418]  [<ffffffffa029939d>] br_forward_finish+0x1e/0x20 [bridge]
[56778.156056]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.162390]  [<ffffffffa029e4f8>] ? nf_bridge_push_encap_header+0x2f/0x3c
[bridge]
[56778.170049]  [<ffffffffa029e6ee>] br_nf_forward_finish+0xbc/0xc5 [bridge]
[56778.176893]  [<ffffffffa029e632>] ? br_nf_forward_arp+0x12d/0x12d [bridge]
[56778.183861]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.190161]  [<ffffffffa029e95a>] br_nf_forward_ip+0x219/0x238 [bridge]
[56778.196892]  [<ffffffff8129ac4a>] nf_iterate+0x43/0x7e
[56778.202048]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.208193]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.214351]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56778.219820]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.225982]  [<ffffffff81279c8a>] ? dev_forward_skb+0xc7/0xc7
[56778.231813]  [<ffffffff81279c8a>] ? dev_forward_skb+0xc7/0xc7
[56778.237635]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.243795]  [<ffffffffa029929d>] T.923+0x41/0x53 [bridge]
[56778.249326]  [<ffffffffa029941c>] __br_forward+0x7d/0x7f [bridge]
[56778.255537]  [<ffffffffa02986fd>] ? __br_fdb_get+0x15/0x95 [bridge]
[56778.261854]  [<ffffffffa0299453>] br_forward+0x35/0x4a [bridge]
[56778.267825]  [<ffffffffa029a0c5>] br_handle_frame_finish+0x15e/0x1c5
[bridge]
[56778.275034]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.280744]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.287087]  [<ffffffffa029e4f8>] ? nf_bridge_push_encap_header+0x2f/0x3c
[bridge]
[56778.294772]  [<ffffffffa029f2b3>] br_nf_pre_routing_finish+0x227/0x236
[bridge]
[56778.302148]  [<ffffffff8100ac00>] ? handle_irq+0x22/0x2a
[56778.307519]  [<ffffffffa029f08c>] ? br_nf_pre_routing+0x535/0x535 [bridge]
[56778.314469]  [<ffffffffa029f08c>] ? br_nf_pre_routing+0x535/0x535 [bridge]
[56778.321426]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.327761]  [<ffffffffa029e723>] ? nf_bridge_alloc+0x2c/0x4a [bridge]
[56778.334380]  [<ffffffffa029f06f>] br_nf_pre_routing+0x518/0x535 [bridge]
[56778.341165]  [<ffffffff8129ac4a>] nf_iterate+0x43/0x7e
[56778.346322]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.352048]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.357792]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56778.363261]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.368980]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.374715]  [<ffffffffa0299f55>] T.905+0x41/0x53 [bridge]
[56778.380244]  [<ffffffffa029a2d7>] br_handle_frame+0x1ab/0x1c0 [bridge]
[56778.386830]  [<ffffffffa029a12c>] ? br_handle_frame_finish+0x1c5/0x1c5
[bridge]
[56778.394211]  [<ffffffff812797fa>] __netif_receive_skb+0x2fc/0x4cb
[56778.400365]  [<ffffffff81279cf1>] netif_receive_skb+0x67/0x6e
[56778.406187]  [<ffffffff81270696>] ? __netdev_alloc_skb+0x1d/0x3b
[56778.412217]  [<ffffffff81279dd6>] napi_skb_finish+0x24/0x3b
[56778.417868]  [<ffffffff8127a248>] napi_gro_receive+0x2a/0x2f
[56778.423605]  [<ffffffffa01d2ad1>] e1000_receive_skb+0x62/0x6d [e1000e]
[56778.430224]  [<ffffffffa01d4ccf>] e1000_clean_rx_irq+0x1fb/0x28d [e1000e]
[56778.437053]  [<ffffffffa01d5196>] e1000_clean+0x75/0x23b [e1000e]
[56778.443222]  [<ffffffff811a1222>] ? timerqueue_add+0x81/0x9f
[56778.448938]  [<ffffffff8127a371>] net_rx_action+0xaa/0x20e
[56778.454469]  [<ffffffff8104a7b9>] __do_softirq+0xc7/0x1a2
[56778.459911]  [<ffffffff8133c55c>] call_softirq+0x1c/0x30
[56778.465301]  [<ffffffff8100aba1>] do_softirq+0x41/0x7e
[56778.470505]  [<ffffffff8104a58e>] irq_exit+0x3f/0x9e
[56778.475541]  [<ffffffff8100a4c7>] do_IRQ+0x98/0xaf
[56778.480385]  [<ffffffff81334ed3>] common_interrupt+0x13/0x13
[56778.486093]  <EOI>
[56778.488226]  [<ffffffff8100fd26>] ? mwait_idle+0x9f/0xd2
[56778.493583]  [<ffffffff8100fcd3>] ? mwait_idle+0x4c/0xd2
[56778.498954]  [<ffffffff81008e17>] cpu_idle+0xad/0xe3
[56778.503980]  [<ffffffff8131ea19>] rest_init+0x6d/0x6f
[56778.509048]  [<ffffffff81691c76>] start_kernel+0x3cc/0x3d7
[56778.514569]  [<ffffffff816912cd>] x86_64_start_reservations+0xb8/0xbc
[56778.521077]  [<ffffffff816913d2>] x86_64_start_kernel+0x101/0x110
[56778.527219] Code: 00 00 b9 00 20 00 00 0f 46 4d c8 89 4d c8 83 c9 ff 48 8b
b7 e0 00 00 00 44 0f bd 6d c8 44 0f 44 e9 8b 8f c0 00 00 00 48 8d 0c 0a <8a> 51
0c c0 ea 04 85 c0 0f 84 80 08 00 00 29 f1 8d 14 91 0f b6
[56778.547303] RIP  [<ffffffffa01d6d83>] e1000_xmit_frame+0x9f/0x935 [e1000e]
[56778.554261]  RSP <ffff88011e203450>
[56778.557772] CR2: ffffffff94c4aa03
[56778.561466] ---[ end trace d3aae3e5a095a8e8 ]---
[56778.566117] Kernel panic - not syncing: Fatal exception in interrupt
[56778.572529] Pid: 0, comm: swapper Tainted: G      D W   2.6.39.4 #28
[56778.578947] Call Trace:
[56778.581402]  <IRQ>  [<ffffffff81332df4>] panic+0x8c/0x195
[56778.586896]  [<ffffffff81335cc7>] oops_end+0xb2/0xc2
[56778.591921]  [<ffffffff8102df93>] no_context+0x1f7/0x206
[56778.597277]  [<ffffffff8102e12a>] __bad_area_nosemaphore+0x188/0x1ab
[56778.611002]  [<ffffffff8102e15b>] bad_area_nosemaphore+0xe/0x10
[56778.616996]  [<ffffffff81337c79>] do_page_fault+0x1c6/0x386
[56778.622631]  [<ffffffffa02991e1>] ? br_dev_queue_push_xmit+0x1a/0x95
[bridge]
[56778.629840]  [<ffffffffa02992a8>] ? T.923+0x4c/0x53 [bridge]
[56778.635558]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.641754]  [<ffffffffa029939d>] ? br_forward_finish+0x1e/0x20 [bridge]
[56778.648557]  [<ffffffffa02992a8>] ? T.923+0x4c/0x53 [bridge]
[56778.654328]  [<ffffffffa029934c>] ? __br_deliver+0x9d/0xa2 [bridge]
[56778.660677]  [<ffffffff81335195>] page_fault+0x25/0x30
[56778.665850]  [<ffffffff81141dd7>] ? stat_open+0x93/0x93
[56778.671121]  [<ffffffffa01d6d83>] ? e1000_xmit_frame+0x9f/0x935 [e1000e]
[56778.677913]  [<ffffffff810407e8>] ? default_wake_function+0xd/0xf
[56778.684037]  [<ffffffff81035f3b>] ? __wake_up_common+0x49/0x7f
[56778.689913]  [<ffffffff812769bc>] dev_hard_start_xmit+0x490/0x559
[56778.702918]  [<ffffffff81290539>] sch_direct_xmit+0x66/0x142
[56778.708630]  [<ffffffff81276db1>] dev_queue_xmit+0x32c/0x4f2
[56778.714342]  [<ffffffffa0299256>] br_dev_queue_push_xmit+0x8f/0x95 [bridge]
[56778.721384]  [<ffffffff81023a26>] ? native_apic_msr_write+0x32/0x36
[56778.727720]  [<ffffffffa029e4c5>] br_nf_dev_queue_xmit+0x7e/0x82 [bridge]
[56778.734608]  [<ffffffffa029e447>] ? br_parse_ip_options+0x199/0x199 [bridge]
[56778.741755]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.748081]  [<ffffffffa029e003>] ? nf_bridge_pull_encap_header+0x2f/0x3c
[bridge]
[56778.755742]  [<ffffffffa029e228>] br_nf_post_routing+0x1cb/0x1e0 [bridge]
[56778.762568]  [<ffffffff81062191>] ? hrtimer_interrupt+0x105/0x1ae
[56778.768722]  [<ffffffff8129ac4a>] nf_iterate+0x43/0x7e
[56778.773904]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.780593]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.787299]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56778.792768]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.799482]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.805634]  [<ffffffffa02991c7>] ? br_flood_deliver+0x14/0x14 [bridge]
[56778.812317]  [<ffffffffa029929d>] T.923+0x41/0x53 [bridge]
[56778.817844]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.824014]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.830165]  [<ffffffffa029939d>] br_forward_finish+0x1e/0x20 [bridge]
[56778.836760]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.843111]  [<ffffffffa029e4f8>] ? nf_bridge_push_encap_header+0x2f/0x3c
[bridge]
[56778.850754]  [<ffffffffa029e6ee>] br_nf_forward_finish+0xbc/0xc5 [bridge]
[56778.857653]  [<ffffffffa029e632>] ? br_nf_forward_arp+0x12d/0x12d [bridge]
[56778.864557]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0fffffa029937f>] ?
br_deliver+0x2e/0x2e [bridge]
[56778.888861]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.895038]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56778.900481]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.906624]  [<ffffffff81279c8a>] ? dev_forward_skb+0xc7/0xc7
[56778.912455]  [<ffffffff81279c8a>] ? dev_forward_skb+0xc7/0xc7
[56778.918253]  [<ffffffffa029937f>] ? br_deliver+0x2e/0x2e [bridge]
[56778.924431]  [<ffffffffa029929d>] T.923+0x41/0x53 [bridge]
[56778.930020]  [<ffffffffa029941c>] __br_forward+0x7d/0x7f [bridge]
[56778.936172]  [<ffffffffa02986fd>] ? __br_fdb_get+0x15/0x95 [bridge]
[56778.942507]  [<ffffffffa0299453>] br_forward+0x35/0x4a [bridge]
[56778.948495]  [<ffffffffa029a0c5>] br_handle_frame_finish+0x15e/0x1c5
[bridge]
[56778.955679]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56778.961431]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56778.967783]  [<ffffffffa029e4f8>] ? nf_bridge_push_encap_header+0x2f/0x3c
[bridge]
[56778.975443]  [<ffffffffa029f2b3>] br_nf_pre_routing_finish+0x227/0x236
[bridge]
[56778.982806]  [<ffffffff8100ac00>] ? handle_irq+0x22/0x2a
[56778.988144]  [<ffffffffa029f08c>] ? br_nf_pre_routing+0x535/0x535 [bridge]
[56778.995105]  [<ffffffffa029f08c>] ? br_nf_pre_routing+0x535/0x535 [bridge]
[56779.002069]  [<ffffffffa029e056>] NF_HOOK_THRESH+0x46/0x4d [bridge]
[56779.008388]  [<ffffffffa029e723>] ? nf_bridge_alloc+0x2c/0x4a [bridge]
[56779.014964]  [<ffffffffa029f06f>] br_nf_pre_routing+0x518/0x535 [bridge]
[56779.021749]  [<ffffffff8129ac4a>] nf_iterate+0x43/0x7e
[56779.026956]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56779.032692]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56779.038428]  [<ffffffff8129acf2>] nf_hook_slow+0x6d/0x108
[56779.043887]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56779.049589]  [<ffffffffa0299f67>] ? T.905+0x53/0x53 [bridge]
[56779.055317]  [<ffffffffa0299f55>] T.905+0x41/0x53 [bridge]
[56779.060854]  [<ffffffffa029a2d7>] br_handle_frame+0x1ab/0x1c0 [bridge]
[56779.067421]  [<ffffffffa029a12c>] ? br_handle_frame_finish+0x1c5/0x1c5
[bridge]
[56779.074856]  [<ffffffff812797fa>] __netif_receive_skb+0x2fc/0x4cb
[56779.080983]  [<ffffffff81279cf1>] netif_receive_skb+0x67/0x6e
[56779.086830]  [<ffffffff81270696>] ? __netdev_alloc_skb+0x1d/0x3b
[56779.092887]  [<ffffffff81279dd6>] napi_skb_finish+0x24/0x3b
[56779.098511]  [<ffffffff8127a248>] napi_gro_receive+0x2a/0x2f
[56779.104214]  [<ffffffffa01d2ad1>] e1000_receive_skb+0x62/0x6d [e1000e]
[56779.110810]  [<ffffffffa01d4ccf>] e1000_clean_rx_irq+0x1fb/0x28d [e1000e]
[56779.117673]  [<ffffffffa01d5196>] e1000_clean+0x75/0x23b [e1000e]
[56779.123839]  [<ffffffff811a1222>] ? timerqueue_add+0x81/0x9f
[56779.129541]  [<ffffffff8127a371>] net_rx_action+0xaa/0x20e
[56779.135095]  [<ffffffff8104a7b9>] __do_softirq+0xc7/0x1a2
[56779.140546]  [<ffffffff8133c55c>] call_softirq+0x1c/0x30
[56779.145908]  [<ffffffff8100aba1>] do_softirq+0x41/0x7e
[56779.151098]  [<ffffffff8104a58e>] irq_exit+0x3f/0x9e
[56779.156115]  [<ffffffff8100a4c7>] do_IRQ+0x98/0xaf
[56779.160941]  [<ffffffff81334ed3>] common_interrupt+0x13/0x13
[56779.166653]  <EOI>  [<ffffffff8100fd26>] ? mwait_idle+0x9f/0xd2
[56779.172675]  [<ffffffff8100fcd3>] ? mwait_idle+0x4c/0xd2
[56779.178038]  [<ffffffff81008e17>] cpu_idle+0xad/0xe3
[56779.183029]  [<ffffffff8131ea19>] rest_init+0x6d/0x6f
[56779.188151]  [<ffffffff81691c76>] start_kernel+0x3cc/0x3d7
[56779.193678]  [<ffffffff816912cd>] x86_64_start_reservations+0xb8/0xbc
[56779.200134]  [<ffffffff816913d2>] x86_64_start_kernel+0x101/0x110
[56779.206306] Rebooting in 1 seconds..

--
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
