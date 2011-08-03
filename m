From: Rustam Afanasyev <cpulinker@yandex.ru>
Subject: Re: [Bugme-new] [Bug 39742] New: 2.6.39.3 crash ... 3.0.0 same trap
Date: Wed, 03 Aug 2011 18:49:41 +0400
Message-ID: <4E396005.60500@yandex.ru>
References: <bug-39742-10286@https.bugzilla.kernel.org/> <20110722144214.577718f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1.mail.yandex.net ([77.88.46.6]:49525 "EHLO
	forward1.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab1HCOtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 10:49:43 -0400
In-Reply-To: <20110722144214.577718f0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was trying using new kernel, but i have same bug and trap from the kernel:
------------------------------------------------
[98592.361121] ------------[ cut here ]------------
[98592.365040] kernel BUG at include/linux/skbuff.h:1189!
[98592.365040] invalid opcode: 0000 [#1] PREEMPT SMP
[98592.365040] CPU 1
[98592.365040] Modules linked in: cls_fw sch_sfq ip_set_hash_net 
ip_set_hash_ip arc4 ecb ppp_mppe xt_mark nf_conntrack_ipv
4 nf_defrag_ipv4 xt_state xt_TCPMSS ipt_LOG xt_recent xt_NOTRACK 
nf_conntrack xt_statistic ts_kmp xt_tcpudp xt_string xt_m
ultiport xt_set iptable_raw iptable_mangle iptable_filter ip_tables 
act_mirred act_skbedit cls_u32 sch_ingress ip_set nfne
tlink l2tp_ppp l2tp_netlink l2tp_core pptp pppox ppp_generic slhc gre 
ipt_ULOG x_tables 8021q garp stp cls_flow sch_htb if
b dm_multipath scsi_dh dm_mod tg3 i2c_i801 rtc_cmos psmouse pcspkr 
sr_mod ehci_hcd cdrom igb uhci_hcd evdev i2c_core sg se
rio_raw usbcore dca i3000_edac edac_core processor button ext3 jbd 
mbcache sd_mod crc_t10dif ide_pci_generic ide_core pata
_acpi ata_generic ata_piix libata scsi_mod
[98592.365040]
[98592.365040] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-un-def-alt2 
#1 ASUS RS100-E4/PI2/P5M2-M/RS100-E4
[98592.365040] RIP: 0010:[<ffffffff8136ca2b>]  [<ffffffff8136ca2b>] 
skb_pull+0x2b/0x30
[98592.365040] RSP: 0018:ffff88011fc83ab0  EFLAGS: 00010283
[98592.365040] RAX: 000000000000057e RBX: ffff880117f5f080 RCX: 
000000000000011f
[98592.365040] RDX: 000000000000011f RSI: 0000000000000002 RDI: 
ffff880117f5f080
[98592.365040] RBP: ffff88011fc83ab0 R08: 0000000000000000 R09: 
0000000000000102
[98592.365040] R10: 0000000000000000 R11: 0000000000000001 R12: 
ffff8800378bb000
[98592.365040] R13: ffff880117834c6e R14: 000000000000002f R15: 
ffffffff8168dd80
[98592.365040] FS:  0000000000000000(0000) GS:ffff88011fc80000(0000) 
knlGS:0000000000000000
[98592.365040] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[98592.365040] CR2: 00000000007ced6c CR3: 0000000117faa000 CR4: 
00000000000006e0
[98592.365040] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[98592.365040] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[98592.365040] Process kworker/0:0 (pid: 0, threadinfo ffff880118f5c000, 
task ffff880118f5a480)
[98592.365040] Stack:
[98592.365040]  ffff88011fc83ae0 ffffffffa027b7fa ffff88011fc83ae0 
ffff8800378bb000
[98592.365040]  ffff880117f5f080 ffff8800378bb050 ffff88011fc83b10 
ffffffff8136bddc
[98592.365040]  ffff88011fc83b40 ffff880117f5f080 ffff8800378bb000 
000000000c1a000a
[98592.365040] Call Trace:
[98592.365040]  <IRQ>
[98592.365040]  [<ffffffffa027b7fa>] pptp_rcv_core+0x21a/0x220 [pptp]
[98592.365040]  [<ffffffff8136bddc>] sk_receive_skb+0x13c/0x160
[98592.365040]  [<ffffffffa027b1be>] pptp_rcv+0x15e/0x1b0 [pptp]
[98592.365040]  [<ffffffffa0256133>] gre_rcv+0x73/0xa0 [gre]
[98592.365040]  [<ffffffff813af10d>] ip_local_deliver_finish+0xed/0x2c0
[98592.365040]  [<ffffffff813af360>] ip_local_deliver+0x80/0x90
[98592.365040]  [<ffffffff813ae959>] ip_rcv_finish+0x119/0x3b0
[98592.365040]  [<ffffffff813aef4d>] ip_rcv+0x21d/0x2f0
[98592.365040]  [<ffffffff8137cffc>] __netif_receive_skb+0x20c/0x6c0
[98592.365040]  [<ffffffff81141e15>] ? __kmalloc_node_track_caller+0x55/0x60
[98592.365040]  [<ffffffff8137dbcd>] netif_receive_skb+0xbd/0xd0
[98592.365040]  [<ffffffff8125fcfc>] ? is_swiotlb_buffer+0x3c/0x50
[98593.222041]  [<ffffffff8137dd30>] napi_skb_finish+0x50/0x70
[98593.222041]  [<ffffffff8137e315>] napi_gro_receive+0xc5/0xd0
[98593.222041]  [<ffffffffa01a8e0f>] igb_poll+0x6cf/0xb50 [igb]
[98593.222041]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[98593.222041]  [<ffffffff8137d004>] ? __netif_receive_skb+0x214/0x6c0
[98593.222041]  [<ffffffff8137f0d4>] net_rx_action+0x164/0x340
[98593.222041]  [<ffffffff810684b5>] __do_softirq+0xd5/0x270
[98593.222041]  [<ffffffff8143c89c>] call_softirq+0x1c/0x30
[98593.222041]  [<ffffffff8100e6c5>] do_softirq+0x95/0xe0
[98593.222041]  [<ffffffff81068305>] irq_exit+0xd5/0xf0
[98593.222041]  [<ffffffff8100dec1>] do_IRQ+0x61/0xd0
[98593.222041]  [<ffffffff81434753>] common_interrupt+0x13/0x13
[98593.222041]  <EOI>
[98593.222041]  [<ffffffff81015936>] ? mwait_idle+0xe6/0x2b0
[98593.222041]  [<ffffffff8101589a>] ? mwait_idle+0x4a/0x2b0
[98593.222041]  [<ffffffff8100bb76>] cpu_idle+0x66/0xd0
[98593.222041]  [<ffffffff8142c8f9>] start_secondary+0x1bf/0x1c4
[98593.222041] Code: 8b 47 68 55 48 89 e5 39 c6 77 1c 29 f0 3b 47 6c 89 
47 68 72 16 89 f0 48 03 87 e0 00 00 00 48 89 87 e0
  00 00 00 c9 c3 31 c0 c9 c3 <0f> 0b eb fe 90 55 39 77 68 48 89 e5 76 1c 
8b 47 6c 85 c0 75 17
[98593.532028] RIP  [<ffffffff8136ca2b>] skb_pull+0x2b/0x30
[98593.532028]  RSP <ffff88011fc83ab0>
[98593.582191] ---[ end trace 7eee6e2d8ae05a69 ]---
[98593.596115] Kernel panic - not syncing: Fatal exception in interrupt
[98593.596119] Pid: 0, comm: kworker/0:0 Tainted: G      D 
3.0.0-un-def-alt2 #1
------------------------------------------------
Have anybody some ideas?
