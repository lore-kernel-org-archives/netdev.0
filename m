From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 71191] New: WARNING: CPU: 0 PID: 0 at
 net/sched/sch_generic.c:264 dev_watchdog+0x266/0x270()
Date: Wed, 26 Feb 2014 13:02:23 -0800
Message-ID: <20140226130223.49af845b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:64666 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaBZVC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 16:02:27 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so1534736pbb.0
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 13:02:26 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id vf7sm6466553pbc.5.2014.02.26.13.02.25
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 13:02:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 26 Feb 2014 12:59:21 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 71191] New: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 dev_watchdog+0x266/0x270()


https://bugzilla.kernel.org/show_bug.cgi?id=71191

            Bug ID: 71191
           Summary: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
                    dev_watchdog+0x266/0x270()
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.5
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mikhail.v.gavrilov@gmail.com
        Regression: No

Created attachment 127491
  --> https://bugzilla.kernel.org/attachment.cgi?id=127491&action=edit
kernel log

[ 3909.248291] ------------[ cut here ]------------
[ 3909.248297] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
dev_watchdog+0x266/0x270()
[ 3909.248298] NETDEV WATCHDOG: p4p1 (r8169): transmit queue 0 timed out
[ 3909.248299] Modules linked in: rfcomm nls_utf8 isofs fuse ip6t_rpfilter
ip6t_REJECT xt_conntrack cfg80211 ebtable_nat ebtable_broute bridge stp llc
ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6
nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter
ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
nf_conntrack iptable_mangle iptable_security iptable_raw bnep btusb bluetooth
hid_logitech_dj joydev rfkill usb_storage iTCO_wdt iTCO_vendor_support ppdev
snd_hda_codec_realtek x86_pkg_temp_thermal coretemp kvm_intel vfat kvm fat
snd_hda_codec_hdmi snd_hda_intel crct10dif_pclmul crc32_pclmul snd_hda_codec
crc32c_intel snd_hwdep ghash_clmulni_intel snd_seq snd_seq_device snd_pcm r8169
mii microcode mei_me mei snd_page_alloc snd_timer lpc_ich
[ 3909.248322]  shpchp snd i2c_i801 soundcore mfd_core serio_raw parport_pc
parport binfmt_misc i915 i2c_algo_bit drm_kms_helper drm i2c_core video
[ 3909.248329] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.5-200.fc20.x86_64
#1
[ 3909.248340] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H,
BIOS F9 01/20/2014
[ 3909.248341]  0000000000000009 ffff88083f203db0 ffffffff81686fdc
ffff88083f203df8
[ 3909.248343]  ffff88083f203de8 ffffffff8106d47d 0000000000000000
ffff8800b8848000
[ 3909.248344]  0000000000000001 0000000000000000 ffff8800b8848000
ffff88083f203e48
[ 3909.248346] Call Trace:
[ 3909.248347]  <IRQ>  [<ffffffff81686fdc>] dump_stack+0x45/0x56
[ 3909.248354]  [<ffffffff8106d47d>] warn_slowpath_common+0x7d/0xa0
[ 3909.248355]  [<ffffffff8106d4ec>] warn_slowpath_fmt+0x4c/0x50
[ 3909.248358]  [<ffffffff815a4a96>] dev_watchdog+0x266/0x270
[ 3909.248359]  [<ffffffff815a4830>] ? dev_graft_qdisc+0x80/0x80
[ 3909.248362]  [<ffffffff81078eb6>] call_timer_fn+0x36/0x100
[ 3909.248373]  [<ffffffff815a4830>] ? dev_graft_qdisc+0x80/0x80
[ 3909.248375]  [<ffffffff8107955a>] run_timer_softirq+0x1ea/0x290
[ 3909.248377]  [<ffffffff8107257c>] __do_softirq+0xec/0x280
[ 3909.248378]  [<ffffffff81072a1d>] irq_exit+0xbd/0xd0
[ 3909.248381]  [<ffffffff81698285>] smp_apic_timer_interrupt+0x45/0x60
[ 3909.248383]  [<ffffffff81696c1d>] apic_timer_interrupt+0x6d/0x80
[ 3909.248384]  <EOI>  [<ffffffff815317d2>] ? cpuidle_enter_state+0x52/0xc0
[ 3909.248387]  [<ffffffff815318f9>] cpuidle_idle_call+0xb9/0x1f0
[ 3909.248390]  [<ffffffff8101c8fe>] arch_cpu_idle+0xe/0x30
[ 3909.248393]  [<ffffffff810c05e5>] cpu_startup_entry+0xc5/0x290
[ 3909.248395]  [<ffffffff81678d27>] rest_init+0x77/0x80
[ 3909.248398]  [<ffffffff81d22f5c>] start_kernel+0x439/0x444
[ 3909.248399]  [<ffffffff81d2292c>] ? repair_env_string+0x5c/0x5c
[ 3909.248401]  [<ffffffff81d22120>] ? early_idt_handlers+0x120/0x120
[ 3909.248402]  [<ffffffff81d225de>] x86_64_start_reservations+0x2a/0x2c
[ 3909.248403]  [<ffffffff81d2271e>] x86_64_start_kernel+0x13e/0x14d
[ 3909.248404] ---[ end trace ec86fade884a2d17 ]---
[ 3909.322070] r8169 0000:02:00.0 p4p1: rtl_txcfg_empty_cond == 0 (loop: 666,
delay: 100).
[ 3909.324191] r8169 0000:02:00.0 p4p1: link up
[ 3963.292670] r8169 0000:02:00.0 p4p1: rtl_txcfg_empty_cond == 0 (loop: 666,
delay: 100).
[ 3963.294785] r8169 0000:02:00.0 p4p1: link up
[ 3986.303736] r8169 0000:02:00.0 p4p1: link down
[ 4017.856241] r8169 0000:02:00.0 p4p1: link up

-- 
You are receiving this mail because:
You are the assignee for the bug.
