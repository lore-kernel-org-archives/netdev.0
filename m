From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Warning/Oops report of the week of August 7th, 2008
Date: Thu, 07 Aug 2008 08:41:19 -0700
Message-ID: <489B179F.1080704@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Jones <davej@redhat.com>, NetDev <netdev@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:54872 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751397AbYHGPlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 11:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This week, a total of 2871 oopses and warnings have been reported,
compared to 2826 reports in the previous week.

The biggest visible change this time is that the proprietary madwifi driver (which has been
splattered all over the top 10 for months) finally fixed their sysctl bug, and they've now
mostly dropped out of this report. A few new 2.6.27-rc bugs are quite visible in this report.

I'm hoping that Fedora will update to a 2.6.26 codebase soon, at which point I'll start
dropping all reports from 2.6.25 and earlier from this report.




Rank 1: journal_update_superblock (warning)
	Reported 235 times (2464 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27-rc1-git3, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 2: parport_device_proc_register (warning)
	Reported 219 times (2990 total reports)
	Duplicate /proc registration in the parport driver
	This warning was last seen in version 2.6.26, and first seen in 2.6.24-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_register

Rank 3: sysfs_add_one (warning)
	Reported 216 times (2800 total reports)
	Duplicate sysfs registration; mostly in USB audio
	This warning was last seen in version 2.6.27-rc1, and first seen in 2.6.24-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=sysfs_add_one

Rank 4: (tainted) firegl_ioctl (warning)
	Reported 187 times (1658 total reports)
	[external] Bug in the proprietary fireglx driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.14, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=firegl_ioctl

Rank 5: sched_mc_power_savings_store (oops)
	Reported 79 times (201 total reports)
	[fixed] Bug in the scheduler sysfs initialization code
	This oops was last seen in version 2.6.27, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=sched_mc_power_savings_store

Rank 6: ata_altstatus (warning)
	Reported 73 times (315 total reports)
	[fixed] Bug in the ATA layer triggered by the ata pnp driver
	This warning was last seen in version 2.6.25.3, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_altstatus

Rank 7: nf_conntrack_acct_fini (warning)
	Reported 67 times
	Bug in the netfilter procfs code exposed by Al's recent cleanups
	This warning was last seen in version 2.6.27-rc2, and first seen in 2.6.27-rc1.
	More info: http://www.kerneloops.org/searchweek.php?search=nf_conntrack_acct_fini

Rank 8: ext3_commit_super (warning)
	Reported 64 times (649 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27-rc0-git8, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super

Rank 9: tick_broadcast_oneshot_control (softlockup)
	Reported 63 times (1024 total reports)
	Some interaction betwee tickless and system with an AMD CPU and an ATI chipset
	This softlockup was last seen in version 2.6.25.11, and first seen in 2.6.24-rc4.
	More info: http://www.kerneloops.org/searchweek.php?search=tick_broadcast_oneshot_control

Rank 10: ata_hsm_move (oops)
	Reported 59 times (448 total reports)
	This oops was last seen in version 2.6.25.11, and first seen in 2.6.25-rc9-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_hsm_move

Rank 11: ssb_tmslow_reject_bitmask (warning)
	Reported 55 times (116 total reports)
	This warning was last seen in version 2.6.25.10, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ssb_tmslow_reject_bitmask

Rank 12: __netif_schedule (warning)
	Reported 52 times (148 total reports)
	[fixed] issue as a result of the multiqueue feature, fixed for 2.6.27-rc1
	This warning was last seen in version 2.6.26-git11, and first seen in 2.6.26-rc8-git.
	More info: http://www.kerneloops.org/searchweek.php?search=__netif_schedule

Rank 13: (tainted) ath_dynamic_sysctl_register (warning)
	Reported 52 times (5388 total reports)
	[external] Bug in the proprietary madwifi driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ath_dynamic_sysctl_register

