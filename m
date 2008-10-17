From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops/Warning report for the week October 17th, 2008
Date: Fri, 17 Oct 2008 08:28:58 -0700
Message-ID: <48F8AF3A.1040306@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, tglx@tglx.de,
	Theodore Ts'o <tytso@mit.edu>, Ingo Molnar <mingo@elte.hu>,
	Greg KH <greg@kroah.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:19645 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755014AbYJQP3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 11:29:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This week, a total of 2786 oopses and warnings have been reported,
compared to 2955 reports in the previous week.
(Reports from 2.6.25 or earlier are ignored for this report)


Per file statistics
159	net/sched/sch_generic.c
41	fs/jbd/journal.c
28	drivers/base/power/main.c
26	kernel/timer.c
22	drivers/parport/procfs.c
19	arch/x86/mm/pageattr.c
15	drivers/usb/serial/usb-serial.c
15	mm/memory.c
15	drivers/net/wireless/ath5k/hw.c
14	external/utrace
13	fs/ext3/super.c
13	external/fireglx/binary (P)


Rank 1: dev_watchdog() (warning)
	Reported 391 times (1881 total reports)
	[These are the reports we can't map back to a driver yet]
	Top 10 of identified issues is:
  count |          guilty
-------+---------------------------
    575 | dev_watchdog(sis900)
    154 | dev_watchdog(usbnet)
    131 | dev_watchdog(via-rhine)
    113 | dev_watchdog(8390)
     73 | dev_watchdog(r8169)
     64 | dev_watchdog(orinoco)
     57 | dev_watchdog(8139too)
     44 | dev_watchdog(via_rhine)
     33 | dev_watchdog(3c59x)
     27 | dev_watchdog(fealnx)

	This warning was last seen in version 2.6.27-rc6-git2, and first seen in 2.6.26-rc3.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog()

Rank 2: journal_update_superblock (warning)
	Reported 181 times (4869 total reports)
	Likely caused by the user removing a USB stick while mounted
	Ted has a fix, it's in -mm and on route to 2.6.28-rc1
	This warning was last seen in version 2.6.27, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 4: dev_watchdog(sis900) (warning)
	Reported 136 times (575 total reports)
	This warning was last seen in version 2.6.27, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 5: device_pm_add (warning)
	Reported 91 times (445 total reports)
	2.6.28-rc will be able to tell us which drivers cause this
	This warning was last seen in version 2.6.27-rc4, and first seen in 2.6.26-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=device_pm_add

Rank 6: run_timer_softirq (oops)
	Reported 86 times (428 total reports)
	softlockup.. mostly seen before Thomas fixed the hpet/timer code.
	This oops was last seen in version 2.6.27-rc8, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=run_timer_softirq

Rank 7: ext3_commit_super (warning)
	Reported 54 times (1251 total reports)
	Likely caused by the user removing a USB stick while mounted
	Ted has a fix, it's in -mm and on route to 2.6.28-rc1	
	This warning was last seen in version 2.6.27, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super

Rank 9: suspend_test_finish (warning)
	Reported 50 times (173 total reports)
	The automatic suspend/resume test
	This warning was last seen in version 2.6.27, and first seen in 2.6.27-rc0-git14.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish

Rank 10: kas_GetExecutionLevel (warning)
	Reported 46 times (125 total reports)
	[external] Bug in the proprietary fireglx driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.27, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=kas_GetExecutionLevel

Rank 11: dev_watchdog(via_rhine) (warning)
	Reported 44 times
	This warning was last seen in version 2.6.26.5, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(via_rhine)

Rank 14: rs_get_rate (warning)
	Reported 34 times (478 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.27, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Fixed issues
============
Rank 8: sg_copy_buffer (warning)
	Reported 51 times (165 total reports)
	[fixed] by making the locks _irqsave (and backported to -stable)
	This warning was last seen in version 2.6.26.5, and first seen in 2.6.26-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=sg_copy_buffer

Rank 12: lock_page (warning)
	Reported 37 times (211 total reports)
	The hwclock program causes a pagefault with interrupts off (done from userspace)
	This warning was last seen in version 2.6.27, and first seen in 2.6.27-rc1-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=lock_page

Rank 13: ata_sff_hsm_move (oops)
	Reported 37 times (1199 total reports)
	[fixed] redundant WARN_ON; fixed in 9c2676b61a5a4b6d99e65fb2f438fb3914302eda
	This oops was last seen in version 2.6.27-rc2-git1, and first seen in 2.6.25.4.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_sff_hsm_move
