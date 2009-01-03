From: Arjan van de Ven <arjan@infradead.org>
Subject: Bug/Warning report for the week of January 3rd, 2009
Date: Sat, 3 Jan 2009 14:03:32 -0800
Message-ID: <20090103140332.74f39ade@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	x86@kernel.org, netdev@vger.kernel.org, tytso@mit.edu,
	eric@anholt.net, airlied@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44704 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbZACWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2009 17:01:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few high/lowlights this round:
* One if the used-to-be-hot Intel wireless issues is slowly going away as a result of
  a firmware update
* the i9xx GEM code is a high riser compared to the last report
* in general, networking is relatively high this report
* the long-fixed ext3 issues seem to still be with us



This week, a total of 6647 oopses and warnings have been reported,
compared to 6356 reports in the previous week. Only reports for version 2.6.27
and later are counted for this report.

Per file statistics
664	external/virtualbox/module
420	arch/x86/include/asm/mtrr.h
325	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
275	drivers/gpu/drm/i915/i915_gem.c
239	drivers/net/r8169.c
228	fs/jbd/journal.c
225	drivers/net/sis900.c
192	drivers/gpu/drm/radeon/radeon_cp.c
183	net/rfkill/rfkill.c
159	net/ipv4/tcp.c
153	drivers/net/wireless/iwlwifi/iwl-tx.c
132	drivers/staging/at76_usb/at76_usb.c


Rank 1: VBoxDrvLinuxIOCtl (warning)
	Reported 659 times (4906 total reports)
	[external] bug in the VirtualBox drivers
	This warning was last seen in version 2.6.28-rc9, and first seen in 2.6.25.11.
	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Rank 2: mtrr_trim_uncached_memory (warning)
	Reported 420 times (9816 total reports)
	BIOS bug (often in VMWare) where the MTRR's are set up incorrectly or not at all
	This warning was last seen in version 2.6.28, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Rank 3: rs_get_rate (warning)
	Reported 325 times (4226 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.28-rc7, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 4: dev_watchdog(r8169) (oops)
	Reported 239 times (3004 total reports)
	This oops was last seen in version 2.6.28, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 5: journal_update_superblock (warning)
	Reported 228 times (8546 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.29-rc0-git3, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 6: dev_watchdog(sis900) (oops)
	Reported 225 times (2595 total reports)
	This oops was last seen in version 2.6.28, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 7: i915_gem_idle (warning)
	Reported 189 times (646 total reports)
	Bug in the Intel 9xx 3D driver
	This warning was last seen in version 2.6.28, and first seen in 2.6.27-rc8-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_idle

Rank 8: rfkill_force_state (oops)
	Reported 183 times (958 total reports)
	[fixed] bug in the toshiba ACPI driver; fixed by 23d0a65cf229acd273b6f5a325c34d758a90d592
	This oops was last seen in version 2.6.28-rc8-git2, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=rfkill_force_state

Rank 9: radeon_cp_init_ring_buffer (oops)
	Reported 178 times (1209 total reports)
	drm.git bug in the radeon driver
	This oops was last seen in version 2.6.28-rc8-git2, and first seen in 2.6.25-rc8-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=radeon_cp_init_ring_buffer

Rank 10: tcp_recvmsg (warning)
	Reported 159 times (846 total reports)
	This warning was last seen in version 2.6.28-rc9-git1, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg

Rank 11: iwl_tx_cmd_complete (warning)
	Reported 153 times (4477 total reports)
	This warning was last seen in version 2.6.28, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 12: e1000_acquire_swflag_ich8lan (warning)
	Reported 123 times (544 total reports)
	Locking issue in the e1000 driver; recursive locking detected.
	This warning was last seen in version 2.6.28-rc7, and first seen in 2.6.26.5.
	More info: http://www.kerneloops.org/searchweek.php?search=e1000_acquire_swflag_ich8lan

Rank 13: dev_watchdog(via-rhine) (warning)
	Reported 118 times (605 total reports)
	This warning was last seen in version 2.6.28-rc9, and first seen in 2.6.26-rc8.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(via-rhine)

