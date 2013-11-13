From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 63321] tcp_fastretrans_alert
Date: Tue, 12 Nov 2013 17:26:15 -0800
Message-ID: <20131112172615.498b3ac9@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36777 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab3KMB0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:26:21 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so2648071pab.33
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 17:26:21 -0800 (PST)
Received: from samsung-9 ([170.173.0.21])
        by mx.google.com with ESMTPSA id pl1sm40433372pbb.20.2013.11.12.17.26.20
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 12 Nov 2013 17:26:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 12 Nov 2013 08:43:45 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 63321] tcp_fastretrans_alert


https://bugzilla.kernel.org/show_bug.cgi?id=63321

--- Comment #3 from root@securitydot.net ---
Once again someone is delaying a fix for a major issue causing a lot of
trouble. Please fix it...

WARNING: CPU: 2 PID: 0 at net/ipv4/tcp_input.c:2711
tcp_fastretrans_alert+0x56c/0x580()
Modules linked in: iptable_filter ip_tables autofs4 bonding ipv6 xt_LOG
ipt_REJECT xt_multiport xfs libcrc32c gpio_ich iTCO_wdt iTCO_vendor_support
joydev raid0 microcode pcspkr serio_raw sg lpc_ich hpilo hpwdt e1000e ptp
pps_core freq_table mperf ext4 jbd2 mbcache xts gf128mul dm_crypt raid1 sd_mod
crc_t10dif ahci libahci mgag200 ttm drm_kms_helper sysimgblt sysfillrect
syscopyarea dm_mirror dm_region_hash dm_log dm_mod
CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W    3.11.6-1.el6.elrepo.x86_64
#1
Hardware name: HP ProLiant DL120 G7, BIOS J01 02/01/2012
 0000000000000a97 ffff88020b4438e0 ffffffff815f7f89 0000000000000a97
 0000000000000000 ffff88020b443920 ffffffff8106705c ffff880200138000
 ffff8800beb7c880 0000000000000009 0000000000004120 0000000000000001
Call Trace:
 <IRQ>  [<ffffffff815f7f89>] dump_stack+0x49/0x60
 [<ffffffff8106705c>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff810670aa>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8158425c>] tcp_fastretrans_alert+0x56c/0x580
 [<ffffffff81585d3f>] tcp_ack+0x34f/0x7d0
 [<ffffffff81586e5a>] tcp_rcv_established+0x2ca/0x700
 [<ffffffff81590309>] tcp_v4_do_rcv+0x169/0x290
 [<ffffffff81591c81>] tcp_v4_rcv+0x601/0x760
 [<ffffffff8156ce90>] ? ip_rcv+0x350/0x350
 [<ffffffff8156325d>] ? nf_hook_slow+0x7d/0x150
 [<ffffffff8156ce90>] ? ip_rcv+0x350/0x350
 [<ffffffff8156cf5e>] ip_local_deliver_finish+0xce/0x250
 [<ffffffff8156d168>] ip_local_deliver+0x88/0x90
 [<ffffffff8150a01f>] ? __alloc_and_insert_iova_range+0x17f/0x1f0
 [<ffffffff8156c7b9>] ip_rcv_finish+0x119/0x360
 [<ffffffff8156cdad>] ip_rcv+0x26d/0x350
 [<ffffffffa0383880>] ? bond_hw_addr_swap+0x120/0x120 [bonding]
 [<ffffffff81536f4e>] __netif_receive_skb_core+0x53e/0x6f0
 [<ffffffff81537127>] __netif_receive_skb+0x27/0x70
 [<ffffffff8153739d>] netif_receive_skb+0x2d/0x90
 [<ffffffff81537fa8>] napi_gro_receive+0xb8/0x140
 [<ffffffffa019745a>] e1000_receive_skb+0x7a/0xf0 [e1000e]
 [<ffffffffa019a900>] e1000_clean_rx_irq+0x2a0/0x4a0 [e1000e]
 [<ffffffffa019d1ed>] e1000e_poll+0xbd/0x2d0 [e1000e]
 [<ffffffff81537ab2>] net_rx_action+0x112/0x290
 [<ffffffff814df346>] ? cpuidle_enter_state+0x56/0xd0
 [<ffffffff8106c147>] __do_softirq+0xf7/0x270
 [<ffffffff81606adc>] call_softirq+0x1c/0x30
 [<ffffffff81015885>] do_softirq+0x65/0xa0
 [<ffffffff8106be75>] irq_exit+0xc5/0xd0
 [<ffffffff816073e6>] do_IRQ+0x66/0xe0
 [<ffffffff815fc6ed>] common_interrupt+0x6d/0x6d
 <EOI>  [<ffffffff814df346>] ? cpuidle_enter_state+0x56/0xd0
 [<ffffffff814df33f>] ? cpuidle_enter_state+0x4f/0xd0
 [<ffffffff814df79d>] cpuidle_idle_call+0xcd/0x160
 [<ffffffff8101c70e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810bb109>] cpu_idle_loop+0x69/0x210
 [<ffffffff810bb320>] cpu_startup_entry+0x70/0x80
 [<ffffffff810437bd>] start_secondary+0xcd/0xd0
---[ end trace 858cf267ca4ce6b0 ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
