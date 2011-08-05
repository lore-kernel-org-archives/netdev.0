From: Rustam Afanasyev <cpulinker@yandex.ru>
Subject: Re: [Bugme-new] [Bug 39742] New:  3.0.0 (2.6.39.3 also) kernel BUG
 at include/linux/skbuff.h:1189!
Date: Fri, 05 Aug 2011 16:55:10 +0400
Message-ID: <4E3BE82E.1060405@yandex.ru>
References: <bug-39742-10286@https.bugzilla.kernel.org/> <20110722144214.577718f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward16.mail.yandex.net ([95.108.253.141]:44435 "EHLO
	forward16.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756152Ab1HEMzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 08:55:12 -0400
In-Reply-To: <20110722144214.577718f0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New kernel, with "gre: fix improper error handling" applied - result 
same. Please Help! Which new git tree you recommend me to testing?
------------------------------------------------
[ 4081.605966] ------------[ cut here ]------------
[ 4081.609919] kernel BUG at include/linux/skbuff.h:1189!
[ 4081.609919] invalid opcode: 0000 [#1] PREEMPT SMP
[ 4081.609919] CPU 1
[ 4081.609919] Modules linked in: cls_fw sch_sfq arc4 ecb ppp_mppe 
act_mirred act_skbedit cls_u32 sch_ingress l2tp_ppp l2t
p_netlink l2tp_core pptp pppox ppp_generic slhc gre 8021q garp stp 
cls_flow sch_htb ifb ipt_NETFLOW xt_mark nf_conntrack_i
pv4 nf_defrag_ipv4 xt_state xt_TCPMSS ipt_LOG xt_recent xt_NOTRACK 
nf_conntrack xt_statistic ts_kmp xt_tcpudp xt_string xt
_multiport xt_set iptable_raw iptable_mangle iptable_filter ip_tables 
x_tables ip_set_hash_ip ip_set_hash_net ip_set nfnet
link dm_multipath scsi_dh dm_mod psmouse sr_mod evdev pcspkr rtc_cmos 
cdrom sg serio_raw i2c_i801 ehci_hcd tg3 uhci_hcd i2
c_core i3000_edac igb usbcore edac_core dca processor button ext3 jbd 
mbcache sd_mod crc_t10dif ide_pci_generic ide_core p
ata_acpi ata_generic ata_piix libata scsi_mod
[ 4081.609919]
[ 4081.609919] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-un-def-alt2 
#1 ASUS RS100-E4/PI2/P5M2-M/RS100-E4
[ 4081.609919] RIP: 0010:[<ffffffff8136ca2b>]  [<ffffffff8136ca2b>] 
skb_pull+0x2b/0x30
[ 4081.609919] RSP: 0018:ffff88011fc83ab0  EFLAGS: 00010283
[ 4081.609919] RAX: 000000000000057e RBX: ffff88011378db80 RCX: 
0000000000000179
[ 4081.609919] RDX: 0000000000000179 RSI: 0000000000000002 RDI: 
ffff88011378db80
[ 4081.609919] RBP: ffff88011fc83ab0 R08: 0000000000000000 R09: 
0000000000000102
[ 4081.609919] R10: 0000000000000000 R11: 0000000000000001 R12: 
ffff88010d0a8800
[ 4081.609919] R13: ffff88010dc4186e R14: 000000000000002f R15: 
ffffffff8168dd80
[ 4081.609919] FS:  0000000000000000(0000) GS:ffff88011fc80000(0000) 
knlGS:0000000000000000
[ 4081.609919] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4081.609919] CR2: 0000000000fc10fc CR3: 0000000001625000 CR4: 
00000000000006e0
[ 4081.609919] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 4081.609919] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 4081.609919] Process kworker/0:0 (pid: 0, threadinfo ffff880118f5c000, 
task ffff880118f5a480)
[ 4081.609919] Stack:
[ 4081.609919]  ffff88011fc83ae0 ffffffffa03267fa ffff88011fc83ae0 
ffff88010d0a8800
[ 4081.609919]  ffff88011378db80 ffff88010d0a8850 ffff88011fc83b10 
ffffffff8136bddc
[ 4081.609919]  ffff88011fc83b40 ffff88011378db80 ffff88010d0a8800 
000000008b55000a
[ 4081.609919] Call Trace:
[ 4081.609919]  <IRQ>
[ 4081.609919]  [<ffffffffa03267fa>] pptp_rcv_core+0x21a/0x220 [pptp]
[ 4081.609919]  [<ffffffff8136bddc>] sk_receive_skb+0x13c/0x160
[ 4081.609919]  [<ffffffffa03261be>] pptp_rcv+0x15e/0x1b0 [pptp]
[ 4081.609919]  [<ffffffffa03080e3>] gre_rcv+0x73/0xa0 [gre]
[ 4081.609919]  [<ffffffff813af10d>] ip_local_deliver_finish+0xed/0x2c0
[ 4081.609919]  [<ffffffff813af360>] ip_local_deliver+0x80/0x90
[ 4081.609919]  [<ffffffff813ae959>] ip_rcv_finish+0x119/0x3b0
[ 4081.609919]  [<ffffffff813aef4d>] ip_rcv+0x21d/0x2f0
[ 4081.609919]  [<ffffffff8137cffc>] __netif_receive_skb+0x20c/0x6c0
[ 4081.609919]  [<ffffffff8137dbcd>] netif_receive_skb+0xbd/0xd0
[ 4081.609919]  [<ffffffff8125fcfc>] ? is_swiotlb_buffer+0x3c/0x50
[ 4081.609919]  [<ffffffff8137dd30>] napi_skb_finish+0x50/0x70
[ 4081.609919]  [<ffffffff8137e315>] napi_gro_receive+0xc5/0xd0
[ 4081.609919]  [<ffffffffa01dbe0f>] igb_poll+0x6cf/0xb50 [igb]
[ 4081.609919]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[ 4081.609919]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[ 4081.609919]  [<ffffffff8137f0d4>] net_rx_action+0x164/0x340
[ 4081.609919]  [<ffffffff810684b5>] __do_softirq+0xd5/0x270
[ 4081.609919]  [<ffffffff8143c89c>] call_softirq+0x1c/0x30
[ 4081.609919]  [<ffffffff8100e6c5>] do_softirq+0x95/0xe0
[ 4081.609919]  [<ffffffff81068305>] irq_exit+0xd5/0xf0
[ 4081.609919]  [<ffffffff8100dec1>] do_IRQ+0x61/0xd0
[ 4081.609919]  [<ffffffff81434753>] common_interrupt+0x13/0x13
[ 4081.609919]  <EOI>
[ 4081.609919]  [<ffffffff8108af60>] ? sched_clock_cpu+0xd0/0x140
[ 4081.609919]  [<ffffffff81015936>] ? mwait_idle+0xe6/0x2b0
[ 4081.609919]  [<ffffffff8101589a>] ? mwait_idle+0x4a/0x2b0
[ 4081.609919]  [<ffffffff8100bb76>] cpu_idle+0x66/0xd0
[ 4081.609919]  [<ffffffff8142c8f9>] start_secondary+0x1bf/0x1c4
[ 4081.609919] Code: 8b 47 68 55 48 89 e5 39 c6 77 1c 29 f0 3b 47 6c 89 
47 68 72 16 89 f0 48 03 87 e0 00 00 00 48 89 87 e0
  00 00 00 c9 c3 31 c0 c9 c3 <0f> 0b eb fe 90 55 39 77 68 48 89 e5 76 1c 
8b 47 6c 85 c0 75 17
[ 4081.609919] RIP  [<ffffffff8136ca2b>] skb_pull+0x2b/0x30
[ 4081.609919]  RSP <ffff88011fc83ab0>
[ 4082.825070] ---[ end trace d6baf8611ae0f359 ]---
[ 4082.838992] Kernel panic - not syncing: Fatal exception in interrupt
[ 4082.858102] Pid: 0, comm: kworker/0:0 Tainted: G      D 
3.0.0-un-def-alt2 #1
[ 4082.881241] Call Trace:
[ 4082.888651]  <IRQ>  [<ffffffff81430b2a>] panic+0x96/0x1bb
[ 4082.904981]  [<ffffffff8143577a>] oops_end+0x10a/0x120
[ 4082.920451]  [<ffffffff8100fbf6>] die+0x56/0x90
[ 4082.934102]  [<ffffffff81434e64>] do_trap+0xc4/0x170
[ 4082.949051]  [<ffffffff8100d801>] do_invalid_op+0xa1/0xb0
[ 4082.965301]  [<ffffffff8136ca2b>] ? skb_pull+0x2b/0x30
[ 4082.980772]  [<ffffffff8106837c>] ? local_bh_enable+0x5c/0xc0
[ 4082.998067]  [<ffffffffa026935a>] ? ipt_do_table+0x22a/0x640 [ip_tables]
[ 4083.018212]  [<ffffffff8143c61b>] invalid_op+0x1b/0x20
[ 4083.033683]  [<ffffffff8136ca2b>] ? skb_pull+0x2b/0x30
[ 4083.049153]  [<ffffffffa03267fa>] pptp_rcv_core+0x21a/0x220 [pptp]
[ 4083.067742]  [<ffffffff8136bddc>] sk_receive_skb+0x13c/0x160
[ 4083.084774]  [<ffffffffa03261be>] pptp_rcv+0x15e/0x1b0 [pptp]
[ 4083.102064]  [<ffffffffa03080e3>] gre_rcv+0x73/0xa0 [gre]
[ 4083.118314]  [<ffffffff813af10d>] ip_local_deliver_finish+0xed/0x2c0
[ 4083.137425]  [<ffffffff813af360>] ip_local_deliver+0x80/0x90
[ 4083.154453]  [<ffffffff813ae959>] ip_rcv_finish+0x119/0x3b0
[ 4083.171223]  [<ffffffff813aef4d>] ip_rcv+0x21d/0x2f0
[ 4083.186174]  [<ffffffff8137cffc>] __netif_receive_skb+0x20c/0x6c0
[ 4083.204504]  [<ffffffff8137dbcd>] netif_receive_skb+0xbd/0xd0
[ 4083.221795]  [<ffffffff8125fcfc>] ? is_swiotlb_buffer+0x3c/0x50
[ 4083.239605]  [<ffffffff8137dd30>] napi_skb_finish+0x50/0x70
[ 4083.256374]  [<ffffffff8137e315>] napi_gro_receive+0xc5/0xd0
[ 4083.273412]  [<ffffffffa01dbe0f>] igb_poll+0x6cf/0xb50 [igb]
[ 4083.290436]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[ 4083.309286]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[ 4083.328136]  [<ffffffff8137f0d4>] net_rx_action+0x164/0x340
[ 4083.344906]  [<ffffffff810684b5>] __do_softirq+0xd5/0x270
[ 4083.361157]  [<ffffffff8143c89c>] call_softirq+0x1c/0x30
[ 4083.377147]  [<ffffffff8100e6c5>] do_softirq+0x95/0xe0
[ 4083.392618]  [<ffffffff81068305>] irq_exit+0xd5/0xf0
[ 4083.407565]  [<ffffffff8100dec1>] do_IRQ+0x61/0xd0
[ 4083.421998]  [<ffffffff81434753>] common_interrupt+0x13/0x13
[ 4083.439027]  <EOI>  [<ffffffff8108af60>] ? sched_clock_cpu+0xd0/0x140
[ 4083.458477]  [<ffffffff81015936>] ? mwait_idle+0xe6/0x2b0
[ 4083.474725]  [<ffffffff8101589a>] ? mwait_idle+0x4a/0x2b0
[ 4083.490976]  [<ffffffff8100bb76>] cpu_idle+0x66/0xd0
[ 4083.505927]  [<ffffffff8142c8f9>] start_secondary+0x1bf/0x1c4
[ 4083.523225] Rebooting in 30 seconds..
------------------------------------------------

