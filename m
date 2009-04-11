From: Arjan van de Ven <arjan@infradead.org>
Subject: kerneloops.org oops/warning report for the week of April 11 2009
Date: Sat, 11 Apr 2009 09:31:53 -0700
Message-ID: <20090411093153.0a70e08f@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, greg@kroah.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36146 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbZDKQaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 12:30:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This week seems to be a networking special, with many of the networking
drivers either being just buggy/chatty or getting caught in the iommu
checking code...

This week, a total of 12130 oopses and warnings have been reported,
compared to 14579 reports in the previous week.


Per file statistics
1183	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
975	drivers/net/wireless/iwlwifi/iwl-sta.c
444	drivers/net/forcedeth.c
405	arch/x86/include/asm/mtrr.h
371	drivers/net/tg3.c
348	drivers/net/r8169.c
331	drivers/gpu/drm/i915/i915_gem.c
306	drivers/usb/core/endpoint.c
250	drivers/net/wireless/iwlwifi/iwl-tx.c
241	drivers/mtd/maps/ck804xrom.c
240	drivers/net/e1000e/netdev.c
228	drivers/net/e1000/e1000_main.c


Rank 1: rs_get_rate (warning)
	Reported 1183 times (21447 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.29-rc2, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 2: iwl_set_dynamic_key (warning)
	Reported 975 times (7558 total reports)
        Another Intel IWL wireless bug
	This warning was last seen in version 2.6.29.1, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_set_dynamic_key

Rank 3: mtrr_trim_uncached_memory (warning)
	Reported 405 times (41995 total reports)
	BIOS bug (often in VMWare) where the MTRR's are set up incorrectly or not at all
	This warning was last seen in version 2.6.29.1, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Rank 4: nv_tx_done_optimized (warning)
	Caught by the IOMMU debugging code
	Reported 389 times (2042 total reports)
	This warning was last seen in version 2.6.29.1, and first seen in 2.6.29-rc3-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=nv_tx_done_optimized

Rank 5: tg3_poll (warning)
	Caught by the IOMMU debugging code
	Reported 357 times (3326 total reports)
	This warning was last seen in version 2.6.29.1, and first seen in 2.6.22.10.
	More info: http://www.kerneloops.org/searchweek.php?search=tg3_poll

Rank 6: dev_watchdog(r8169) (warning)
	Reported 348 times (7138 total reports)
	This oops was last seen in version 2.6.29.1, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 7: i915_gem_leavevt_ioctl (warning)
	Reported 323 times (4028 total reports)
	This warning was last seen in version 2.6.29, and first seen in 2.6.27.7.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_leavevt_ioctl

Rank 8: usb_create_ep_files (warning)
	Reported 303 times (1730 total reports)
	This warning was last seen in version 2.6.29-rc0-git7, and first seen in 2.6.25-rc8.
	More info: http://www.kerneloops.org/searchweek.php?search=usb_create_ep_files

Rank 9: iwl_tx_cmd_complete (warning)
	Reported 250 times (7231 total reports)
	This warning was last seen in version 2.6.30-rc0-git8, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 10: e1000_put_txbuf (warning)
	Caught by the IOMMU debugging code
	Reported 240 times (2837 total reports)
	This warning was last seen in version 2.6.29.1, and first seen in 2.6.29-rc3-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=e1000_put_txbuf



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
