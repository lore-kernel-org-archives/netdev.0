From: Arjan van de Ven <arjan@infradead.org>
Subject: Oops/Warning report for the week of November 19th, 2008
Date: Wed, 19 Nov 2008 08:01:06 -0800
Message-ID: <20081119080106.23943160@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, x86@vger.kernel.org, tytso@mit.edu,
	linux-ide@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This week, a total of 4488 oopses and warnings have been reported,
compared to 3926 reports in the previous week.
(Reports prior to 2.6.26 have been omitted in collecting the top 10)

I'd like to point specifically at numbers 7 and 8 this week, they are new in 
the top 10 out of nowhere...


Per file statistics
463	external/virtualbox/module
399	kernel/power/main.c
324	drivers/net/r8169.c
235	fs/jbd/journal.c
164	drivers/net/sis900.c
152	drivers/parport/procfs.c
150	drivers/ata/libata-sff.c
99	drivers/net/wireless/iwlwifi/iwl-tx.c
97	drivers/base/power/main.c
90	net/sched/sch_generic.c
77	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
75	kernel/timer.c


Fix availble
------------
Rank 4: journal_update_superblock (warning)
	Reported 239 times (6187 total reports)
	Likely caused by the user removing a USB stick while mounted
	Fix available in the -mm tree
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 6: parport_device_proc_register (warning)
	Reported 143 times (5957 total reports)
	Duplicate /proc registration in the parport driver
	Alan has a patch that fixes most cases
	This warning was last seen in version 2.6.27-rc7-git1, and first seen in 2.6.24-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_register

Rank 14: ext3_commit_super (warning)
	Reported 45 times (1555 total reports)
	Likely caused by the user removing a USB stick while mounted
	A fix for this issue is in the -mm tree
	This warning was last seen in version 2.6.27.6, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super

Not yet fixed
-------------
Rank 1: VBoxDrvLinuxIOCtl (warning)
	Reported 460 times (747 total reports)
	[external] bug in the VirtualBox drivers
	This warning was last seen in version 2.6.28-rc3, and first seen in 2.6.25.11.
	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Rank 2: suspend_test_finish (warning)
	Suspend resume test finds drivers that take too long.
	Linus merged a patch to show which driver it was recently.
	Reported 408 times (874 total reports)
	This warning was last seen in version 2.6.28-rc1, and first seen in 2.6.27-rc0-git14.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish

Rank 3: dev_watchdog(r8169) (network timeout)
	Reported 326 times (1113 total reports)
	This driver has been consistently high in the reports
	This timeout was last seen in version 2.6.28-rc2-git7, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 5: dev_watchdog(sis900) (warning)
	Reported 166 times (1337 total reports)
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 7: __atapi_pio_bytes (warning)
	Reported 108 times
	This is a new entry this week that started showing up
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=__atapi_pio_bytes

Rank 8: iwl_tx_cmd_complete (warning)
	Reported 99 times (240 total reports)
	This appears to be a recent regression in the iwlwifi driver
	This warning was last seen in version 2.6.28-rc4, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 10: rs_get_rate (warning)
	Reported 78 times (894 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 11: run_timer_softirq (soft lockup)
	Reported 62 times (834 total reports)
	The hope is that the timer rework in 2.6.28 fixes these
	This oops was last seen in version 2.6.27.5, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=run_timer_softirq

Rank 12: device_pm_add (warning)
	Reported 61 times (840 total reports)
	This got "fixed" by removing the warning
	This warning was last seen in version 2.6.27-rc4, and first seen in 2.6.26-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=device_pm_add

Rank 13: dev_watchdog(cdc_ether) (oops)
	Reported 59 times (206 total reports)
	This oops was last seen in version 2.6.27.6, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(cdc_ether)



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
