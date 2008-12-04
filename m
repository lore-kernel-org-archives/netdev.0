From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops/Warning report for the week of December 3rd, 2008
Date: Wed, 3 Dec 2008 18:46:52 -0800
Message-ID: <20081203184652.0601b86b@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, x86@kernel.org, tytso@mit.edu,
	akpm@linux-foundation.org, alan@redhat.com, airlied@redhat.com,
	greg@kroah.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This week, a total of 11349 oopses and warnings have been reported,
compared to 4327 reports in the previous week.


Per file statistics
1224	drivers/pci/slot.c
1029	drivers/net/wireless/iwlwifi/iwl-tx.c
795	arch/x86/include/asm/mtrr.h
657	external/virtualbox/module
634	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
380	arch/x86/kernel/hpet.c
356	fs/jbd/journal.c
349	drivers/net/r8169.c
287	drivers/ata/libata-sff.c
225	drivers/gpu/drm/radeon/radeon_cp.c
212	drivers/net/sis900.c
199	drivers/staging/at76_usb/at76_usb.c


Rank 1: pci_create_slot (warning)
	Reported 1224 times (1662 total reports)
	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27-rc7-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=pci_create_slot

Rank 2: iwl_tx_cmd_complete (warning)
	Reported 1214 times (1757 total reports)
	Bug in the IWL wireless driver; partial fix available
	This warning was last seen in version 2.6.28-rc6, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 3: mtrr_trim_uncached_memory (warning)
	Reported 909 times (3058 total reports)
	This warning was last seen in version 2.6.28-rc7, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Rank 4: rs_get_rate (warning)
	Reported 811 times (1921 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.27.7, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 5: VBoxDrvLinuxIOCtl (warning)
	Reported 756 times (2332 total reports)
	[external] bug in the VirtualBox drivers
	This warning was last seen in version 2.6.28-rc3, and first seen in 2.6.25.11.
	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Rank 6: journal_update_superblock (warning)
	Reported 422 times (6983 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.27.7, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 7: hpet_legacy_next_event (warning)
	Reported 410 times (429 total reports)
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=hpet_legacy_next_event

Rank 8: dev_watchdog(r8169) (oops)
	Reported 402 times (1795 total reports)
	This oops was last seen in version 2.6.28-rc6, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 9: __atapi_pio_bytes (warning)
	Reported 331 times (555 total reports)
	This warning was last seen in version 2.6.27.7, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=__atapi_pio_bytes

Rank 10: radeon_cp_init_ring_buffer (oops)
	Reported 249 times (482 total reports)
	drm.git bug in the radeon driver
	This oops was last seen in version 2.6.27.5, and first seen in 2.6.25-rc8-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=radeon_cp_init_ring_buffer

Rank 11: dev_watchdog(sis900) (oops)
	Reported 230 times (1801 total reports)
	This oops was last seen in version 2.6.27.6, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 12: tcp_recvmsg (warning)
	Reported 211 times (363 total reports)
	This warning was last seen in version 2.6.27.5, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg

Rank 13: rfkill_force_state (oops)
	Reported 209 times (260 total reports)
	This oops was last seen in version 2.6.28-rc2, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=rfkill_force_state

Rank 14: sysfs_add_one (oops)
	Reported 195 times (213 total reports)
	Duplicate sysfs registration; mostly in USB audio
	This oops was last seen in version 2.6.27.5, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=sysfs_add_one



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
