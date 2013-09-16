From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 61441] New: Network stop working ( (bnx2): transmit queue
 0 timed out)
Date: Mon, 16 Sep 2013 08:53:20 -0700
Message-ID: <20130916085320.4f5b494d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:42656 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab3IPPxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 11:53:23 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so5491831pab.39
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 08:53:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 16 Sep 2013 03:58:45 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 61441] New: Network stop working ( (bnx2): transmit queue 0 timed out)


https://bugzilla.kernel.org/show_bug.cgi?id=61441

            Bug ID: 61441
           Summary: Network stop working ( (bnx2): transmit queue 0 timed
                    out)
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.61
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: javibarroso@gmail.com
        Regression: No

Hello,

Do you have any hint to solve this problem ?

We have a NAS server (openfiler) with the latest 2.6.32 (.61) available kernel
compiled. Every 1/2 days the server stop serving.

The next message is show in messages:

Uhhuh. NMI received for unknown reason b1 on CPU 0.
You have some hardware problem, likely on the PCI bus.
Dazed and confused, but trying to continue
------------[ cut here ]------------
WARNING: at /usr/src/linux-2.6.32.61/net/sched/sch_generic.c:261
dev_watchdog+0x247/0x260()
Hardware name: ProLiant BL460c G1
NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
Modules linked in: autofs4 nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs fuse
8021q garp stp llc bonding ipv6 dm_round_robin dm_multipath ext4 jbd2 dm_mirror
dm_region_hash dm_log dm_snapshot dm_mod i5000_edac edac_core i5k_amb ipmi_si
sd_mod iTCO_wdt iTCO_vendor_support bnx2 sg tg3 serio_raw hwmon ipmi_msghandler
pcspkr hpilo crc_t10dif usb_storage qla2xxx scsi_transport_fc scsi_tgt shpchp
cciss ext3 jbd mbcache radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core
[last unloaded: microcode]
Pid: 0, comm: swapper Not tainted 2.6.32.61-SAE #2
Call Trace:
 <IRQ>  [<ffffffff81067bbb>] warn_slowpath_common+0x7b/0xc0
 [<ffffffff81067c61>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff813f6c37>] dev_watchdog+0x247/0x260
 [<ffffffff8101a1b3>] ? native_sched_clock+0x13/0x80
 [<ffffffff81079d45>] ? internal_add_timer+0xb5/0x110
 [<ffffffff81079e24>] ? cascade+0x84/0xb0
 [<ffffffff8107a956>] run_timer_softirq+0x196/0x340
 [<ffffffff81097447>] ? ktime_get+0x57/0xd0
 [<ffffffff81070305>] __do_softirq+0xd5/0x200
 [<ffffffff81091006>] ? hrtimer_interrupt+0x146/0x260
 [<ffffffff8101424c>] call_softirq+0x1c/0x30
 [<ffffffff81015bf5>] do_softirq+0x65/0xa0
 [<ffffffff810700e5>] irq_exit+0x85/0x90
 [<ffffffff8149c771>] smp_apic_timer_interrupt+0x71/0x9c
 [<ffffffff81013c13>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8101b94f>] ? mwait_idle+0x6f/0xd0
 [<ffffffff8149a53a>] ? atomic_notifier_call_chain+0x1a/0x20
 [<ffffffff81011e66>] ? cpu_idle+0xb6/0x110
 [<ffffffff8148e7e7>] ? start_secondary+0x1fc/0x23f
---[ end trace 177d1288aad2a52a ]---
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!
bnx2: Chip reset did not complete
bnx2: eth0: BUG! Tx ring full when queue awake!

No log is found at:

# ipmitool  sel
SEL Information
Version          : 1.5 (v1.5, v2 compliant)
Entries          : 0
Free Space       : 1024 bytes
Percent Used     : 0%
Last Add Time    : Not Available
Last Del Time    : 08/02/2007 14:23:47
Overflow         : false
Supported Cmds   : None
pear in ipmi:

Can we configure bnx2 module to mitigate that BUG ?

Thank you very much

-- 
You are receiving this mail because:
You are the assignee for the bug.
