From: Arjan van de Ven <arjan@infradead.org>
Subject: Warning/Oops report of the week of September 16th, 2008
Date: Tue, 16 Sep 2008 09:22:06 -0700
Message-ID: <20080916092206.6342c498@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	tglx@tglx.de, mingo@elte.hu, linux-acpi@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the first report where I've dropped oopses that happened to 2.6.25 or earlier kernels.
I've also changed the format of the report to split it in "fixed" and "not yet fixed" sections;
I hope that makes the report more useful for developers.



This week, a total of 1730 oopses and warnings have been reported,
compared to 626 reports in the previous week.


Per file statistics
266	net/sched/sch_generic.c
260	kernel/timer/tglx.c
167	drivers/ata/libata-sff.c
154	external/utrace
80	net/core/dev.c
62	drivers/parport/procfs.c
54	external/fireglx/binary (P)
45	fs/jbd/journal.c
38	kernel/timer.c
34	drivers/base/power/main.c
27	lib/scatterlist.c
25	kernel/sched.c
23	include/asm-x86/irqflags.h


Not yet fixed issues
====================

Rank 1: dev_watchdog (warning)
	Reported 263 times (495 total reports)
	Network card timeout; this error is currently not specific enough, a patch
	is pending to get this reported per driver, with some luck this gets merged soon.
	This warning was last seen in version 2.6.27-rc6, and first seen in 2.6.26-rc3.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog

Rank 4: utrace_control (oops)
	Reported 149 times (152 total reports)
	[fedora] Fedora merged a broken utrace patch
	This oops was last seen in version 2.6.26.3, and first seen in 2.6.26.1.
	More info: http://www.kerneloops.org/searchweek.php?search=utrace_control

Rank 6: parport_device_proc_register (warning)
	Reported 62 times (3942 total reports)
	Duplicate /proc registration in the parport driver
	This warning was last seen in version 2.6.26.3, and first seen in 2.6.24-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_register

Rank 7: firegl_ioctl (warning)
	Reported 50 times (2479 total reports)
	[external] Bug in the proprietary fireglx driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.26.5, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=firegl_ioctl

Rank 8: journal_update_superblock (warning)
	Reported 44 times (3767 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27-rc6, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 9: run_timer_softirq (oops)
	Reported 36 times (76 total reports)
	softlockup; might be fixed by Thomas' HPET fixes
	This oops was last seen in version 2.6.27-rc1-git4, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=run_timer_softirq

Rank 10: device_pm_add (warning)
	Reported 29 times (122 total reports)
	This warning was last seen in version 2.6.27-rc4, and first seen in 2.6.26-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=device_pm_add

Rank 12: native_safe_halt (oops)
	Reported 23 times (122 total reports)
	This oops was last seen in version 2.6.27-rc5, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=native_safe_halt

Rank 13: account (warning)
	Reported 13 times (16 total reports)
	This warning was last seen in version 2.6.26.3, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=account

Rank 14: lock_page (warning)
	Reported 12 times (31 total reports)
	This warning was last seen in version 2.6.27-rc6, and first seen in 2.6.27-rc1-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=lock_page

Fixed issues
============


Rank 2: tick_dev_program_event (warning)
	Reported 260 times (282 total reports)
	[debug] temporary WARN_ON() inserted in -rc5 for diagnostics purposes, removed for -rc6
	This warning was last seen in version 2.6.27-rc5-git10, and first seen in 2.6.27-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=tick_dev_program_event

Rank 3: ata_sff_hsm_move (warning)
	Reported 167 times (300 total reports)
	[fixed] redundant WARN_ON; fixed in 9c2676b61a5a4b6d99e65fb2f438fb3914302eda
	This warning was last seen in version 2.6.27-rc2-git1, and first seen in 2.6.25.4.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_sff_hsm_move

Rank 5: __netif_schedule (warning)
	Reported 74 times (559 total reports)
	[fixed] issue as a result of the multiqueue feature, fixed for 2.6.27-rc1
	This warning was last seen in version 2.6.27-rc0-git11, and first seen in 2.6.26-rc8-git.
	More info: http://www.kerneloops.org/searchweek.php?search=__netif_schedule

Rank 11: sg_copy_buffer (warning)
	Reported 27 times (29 total reports)
	[fixed] by making the locks _irqsave (and backported to -stable)
	This warning was last seen in version 2.6.26.5, and first seen in 2.6.26-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=sg_copy_buffer



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
