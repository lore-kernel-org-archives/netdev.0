From: Arjan van de Ven <arjan@linux.intel.com>
Subject: oops/warning report for the week of November 26, 2008
Date: Wed, 26 Nov 2008 15:11:14 -0800
Message-ID: <492DD792.6080302@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44407 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbYKZXLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 18:11:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In collecting this report, oopses and warnings with versions prior to 2.6.27 are ignored.
This week, a total of 5450 oopses and warnings have been reported of version 2.6.27+,
compared to 2198 reports in the previous week.

This report is a bit different than the previous weeks; all 2.6.26 and earlier issues are no
longer used, which means the top 12 has shuffled quite a bit, with some new star appearances.

Also I've reworked the "are these two backtraces the same" algorithm; the website should now
be presenting a more compact/concise view due to having the backtraces consolidated in a much
more logical (for the human) way.


Per file statistics
936	external/virtualbox/module
602	drivers/pci/slot.c
455	drivers/net/wireless/iwlwifi/iwl-tx.c
364	kernel/power/main.c
274	drivers/net/r8169.c
231	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
231	fs/jbd/journal.c
227	arch/x86/include/asm/mtrr.h
147	drivers/ata/libata-sff.c
137	drivers/net/sis900.c
71	net/ipv4/tcp.c
62	drivers/gpu/drm/radeon/radeon_cp.c


Rank 1: VBoxDrvLinuxIOCtl (warning)
	Reported 934 times (1635 total reports)
	[external] bug in the VirtualBox drivers
	This warning was last seen in version 2.6.28-rc3, and first seen in 2.6.25.11.
	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Rank 2: pci_create_slot (warning)
	Reported 603 times (639 total reports)
	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27-rc7-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=pci_create_slot

Rank 3: iwl_tx_cmd_complete (warning)
	Reported 455 times (693 total reports)
	Bug in the IWL wireless driver; partial fix available
	This warning was last seen in version 2.6.28-rc4, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 4: suspend_test_finish (warning)
	Reported 362 times (1202 total reports)
	Fedora is shipping with the suspend test on.. and it's failing everywhere.
	The patch to report what fails is in 2.6.28-rc6 and later
	This warning was last seen in version 2.6.28-rc1, and first seen in 2.6.27-rc0-git14.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish

Rank 5: dev_watchdog(r8169) (oops)
	Reported 274 times (1414 total reports)
	Network driver not handling timeouts itself.
	This oops was last seen in version 2.6.28-rc4, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 6: rs_get_rate (oops)
	Reported 232 times (1152 total reports)
	Bug in the Intel IWL wireless drivers
	This oops was last seen in version 2.6.27.5, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 7: journal_update_superblock (warning)
	Reported 231 times (6506 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27.7, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 8: mtrr_trim_uncached_memory (warning)
	Reported 227 times (619 total reports)
	There is a high number of machines where our MTRR checks trigger. I suspect we are too
	picky in accepting the MTRR configuration.
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Rank 9: __atapi_pio_bytes (warning)
	Reported 146 times (224 total reports)
	Alan said this was due to some other layer giving the libata drivers a weird
	scatter gather list. It just happens a lot, and somehow it mostly happens in
	virtualized environments
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=__atapi_pio_bytes

Rank 10: dev_watchdog(sis900) (oops)
	Reported 137 times (1538 total reports)
	This oops was last seen in version 2.6.27.6, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 11: tcp_recvmsg (warning)
	Reported 71 times (167 total reports)
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg

Rank 12: dev_watchdog(atl1) (oops)
	Reported 56 times (109 total reports)
	This oops was last seen in version 2.6.27.5, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(atl1)

Rank 13: nv_set_page_attrib_cached (warning)
	Reported 56 times (65 total reports)
	[external] bug in the binary nvidia driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27.5.
	More info: http://www.kerneloops.org/searchweek.php?search=nv_set_page_attrib_cached
