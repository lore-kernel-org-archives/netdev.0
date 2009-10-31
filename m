From: Arjan van de Ven <arjan@infradead.org>
Subject: kerneloops.org report for the week of October 31 2009
Date: Sat, 31 Oct 2009 16:03:51 -0700
Message-ID: <20091031160351.26fcc6c5@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-acpi@vger.kernel.org, tytso@mit.edu, netdev@vger.kernel.org,
	Eric Paris <eparis@redhat.com>, akpm@linux-foundation.org,
	Matt Domsch <Matt_Domsch@dell.com>
To: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This week, a total of 18023 oopses and warnings have been reported,
compared to 5816 reports in the previous week. This number and this
report only includes kernel 2.6.31 and later.

This week, the Ubuntu 9.10 distribution got released, which includes
kerneloops.org integration in the quality feedback system. I'd like
to thank the Ubuntu team for their effort in helping to get the quality
feedback about the kernel integrated into kerneloops.org.


One thing to note is that the Ubuntu 9.10 release ships with the kernel
debug option CONFIG_PM_TEST_SUSPEND enabled, causing many warnings to 
be submitted. This huge volume triggered me to split these reports, as well
as the check_bios_for_corruption() reports into a per machine entry.

The top 5 machines for which the suspend test fails:
   319 | suspend_test_finish(Latitude D830)
   231 | suspend_test_finish(XPS M1530)
   225 | suspend_test_finish(MacBook2,1)
   171 | suspend_test_finish(Compaq Presario CQ60 Notebook PC)
   157 | suspend_test_finish(Studio XPS 1340)

and there is also the very elegant 
   267 | suspend_test_finish(To Be Filled By O.E.M)


The top 5 machines where the BIOS corrupts memory:
    80 | check_for_bios_corruption(HP Compaq nx6110)
    69 | check_for_bios_corruption(HP Compaq nc6120)
    62 | check_for_bios_corruption(HP Pavilion dv6700 Notebook PC)
    49 | check_for_bios_corruption(HP Pavilion dv2700 Notebook PC)
    32 | check_for_bios_corruption(Compaq Presario F700 Notebook PC)


The report this week looks different from previous reports; the version
cut-off has moved to 2.6.31 so that a lot of older bugs now dropped out of the report.

New this week are some inotify bugs, that have been fixed in Linus' git tree after -rc5.
There's also an ext2 warning for when the user unplugs a USB stick, as well as the
usual binary and external kernel modules.

If you have (better) descriptions for some of these, let me know and I can add them to the
database.




Rank 1: suspend_test_finish(System Product Name) (warning)
	Reported 930 times (1510 total reports)
	This warning was last seen in version 2.6.31, and first seen in 2.6.27.15.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish(System Product Name)

Rank 2: acpi_idle_enter_bm (oops)
	Reported 783 times (1924 total reports)
	This oops was last seen in version 2.6.32, and first seen in 2.6.23.8.
	More info: http://www.kerneloops.org/searchweek.php?search=acpi_idle_enter_bm

Rank 3: dev_watchdog(sis900) (warning)
	Reported 514 times (19593 total reports)
	This warning was last seen in version 2.6.31, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 4: suspend_test_finish(Unknown) (oops)
	Reported 431 times (5580 total reports)
	This oops was last seen in version 2.6.31, and first seen in 2.6.27.15.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish(Unknown)

Rank 5: tcp_recvmsg (oops)
	Reported 372 times (7133 total reports)
	This oops was last seen in version 2.6.31.3, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg

Rank 6: inotify_remove_from_idr (oops)
	Reported 369 times (942 total reports)
	Fixed in commit 9f0d793b52eb
	This oops was last seen in version 2.6.32, and first seen in 2.6.31-rc8.
	More info: http://www.kerneloops.org/searchweek.php?search=inotify_remove_from_idr

Rank 7: ext2_sync_fs (warning)
	Reported 265 times (508 total reports)
	Caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.32-rc5, and first seen in 2.6.30.
	More info: http://www.kerneloops.org/searchweek.php?search=ext2_sync_fs

Rank 8: ieee80211_scan_completed (oops)
	Reported 264 times (1494 total reports)
	This oops was last seen in version 2.6.32-rc2, and first seen in 2.6.27.29.
	More info: http://www.kerneloops.org/searchweek.php?search=ieee80211_scan_completed

Rank 9: wl_pci_probe (warning)
	Reported 216 times (251 total reports)
	[Ubuntu] Bug in a binary driver shipped by Ubuntu
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.31, and first seen in 2.6.30.8.
	More info: http://www.kerneloops.org/searchweek.php?search=wl_pci_probe

Rank 10: apparmor_bprm_set_creds (oops)
	Reported 201 times (324 total reports)
	NULL pointer dereference in AppArmor
	This oops was last seen in version 2.6.31, and first seen in 2.6.31.
	More info: http://www.kerneloops.org/searchweek.php?search=apparmor_bprm_set_creds

Rank 11: KCL_MEM_AllocContiguousPageFrames (warning)
	Reported 188 times (256 total reports)
	[tainted] The AMD binary graphics driver uses GFP_NOWARN on a high order allocation
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.31, and first seen in 2.6.31.
	More info: http://www.kerneloops.org/searchweek.php?search=KCL_MEM_AllocContiguousPageFrames

Rank 12: idr_callback (warning)
	Reported 174 times (638 total reports)
	Fixed in commit 9f0d793b52eb before 2.6.32-rc6
	This warning was last seen in version 2.6.32, and first seen in 2.6.31-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=idr_callback


--
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
