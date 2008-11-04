From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops/warning report for the week of November 4th, 2008
Date: Tue, 04 Nov 2008 09:58:48 -0800
Message-ID: <49108D58.1010908@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, linux-scsi@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>, tglx@tglx.de
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Reports prior to 2.6.26 have been omitted in collecting the top 10)

This week, a total of 3780 oopses and warnings have been reported,
compared to 3157 reports in the previous week.

Per file statistics
277	drivers/net/r8169.c
239	fs/jbd/journal.c
190	drivers/parport/procfs.c
189	drivers/net/sis900.c
156	external/fireglx/binary (P)
137	drivers/base/power/main.c
124	kernel/timer.c
115	net/sched/sch_generic.c
90	include/linux/pagemap.h
86	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
80	kernel/power/main.c
65	drivers/usb/serial/usb-serial.c


Items with unmerged fix available
---------------------------------
Rank 2: journal_update_superblock (warning)
	Reported 233 times (5565 total reports)
	Fix is in the -mm tree but not yet in mainline
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 14: ext3_commit_super (warning)
	Reported 50 times (1425 total reports)
	Fix is in the -mm tree but not yet in mainline
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super


Unfixed items
-------------
Rank 1: dev_watchdog(r8169) (warning)
	Reported 277 times (483 total reports)
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 3: dev_watchdog(sis900) (warning)
	Reported 189 times (987 total reports)
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

	Rank 5: kas_GetExecutionLevel (warning)
	Reported 140 times (331 total reports)
	[external] Bug in the proprietary fireglx driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.27, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=kas_GetExecutionLevel

Rank 6: run_timer_softirq (oops)
	Reported 117 times (669 total reports)
	softlockup
	This oops was last seen in version 2.6.27.4, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=run_timer_softirq

Rank 10: rs_get_rate (warning)
	Reported 85 times (695 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 11: suspend_test_finish (warning)
	Reported 80 times (321 total reports)
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.27-rc0-git14.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish

Rank 12: dev_watchdog(cdc_ether) (warning)
	Reported 59 times (78 total reports)
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(cdc_ether)

Rank 13: ___free_dma_mem_cluster (warning)
	Reported 55 times (242 total reports)
	[known issue] bug in the sym53c8xx_2 scsi driver; harmless on x86
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.24-rc8-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=___free_dma_mem_cluster


Fixed items
-----------
Rank 8: device_pm_add (warning)
	Reported 103 times (683 total reports)
	This warning was last seen in version 2.6.27-rc4, and first seen in 2.6.26-rc5.
	"Fixed" by removing the warning to hide the bug.
	More info: http://www.kerneloops.org/searchweek.php?search=device_pm_add

Rank 9: lock_page (warning)
	Reported 90 times (362 total reports)
	The hwclock program causes the kernel to fault due to disabling irqs in userspace
	Fixed in 2.6.28-rc, should probably be backported to -stable
	This warning was last seen in version 2.6.27.4, and first seen in 2.6.27-rc1-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=lock_page




