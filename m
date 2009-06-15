From: Arjan van de Ven <arjan@infradead.org>
Subject: kerneloops.org report for the week of June 14 2009
Date: Sun, 14 Jun 2009 17:33:31 -0700
Message-ID: <20090614173331.18f01123@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	tglx@tglx.de, alan@lxorguk.ukuu.org.uk, rjw@sisk.pl,
	netdev@vger.kernel.org, mingo@elte.hu, dwmw2@infradead.org,
	alsa-devel@alsa-project.org, dri-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33071 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbZFOAdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 20:33:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First, a word of thanks to the kernel.org team for helping to host the kerneloops.org database
on a real machine rather than a small virtualized host. Performance and continuity will be a lot
better in the new setup! 
(as a result of the transition and hosting issues on the original server, there was a downtime of 
two days, meaning that the total number of reports is lower than typical)


New sightings this report include the XFI driver, the i915 gem code and the DMAR code.


This week, a total of 4026 oopses and warnings have been reported
for kernels 2.6.29 and later. Reports for kernels earlier than 2.6.29
have been omitted from this report.

Per file statistics
830	drivers/gpu/drm/i915/i915_gem_tiling.c
470	drivers/net/wireless/iwlwifi/iwl-sta.c
303	kernel/time.c
276	drivers/parport/procfs.c
269	include/linux/slob_def.h
187	include/linux/hrtimer.h
138	arch/x86/kernel/cpu/mtrr/generic.c
120	drivers/pci/dmar.c
65	net/mac80211/rc80211_minstrel.c
62	drivers/net/r8169.c
37	net/ipv4/tcp.c
34	fs/cifs/cifssmb.c


Rank 1: i915_gem_set_tiling (warning)
	Reported 830 times (3700 total reports)
	[gem] Failure in the tiling code
	This warning was last seen in version 2.6.30, and first seen in 2.6.29-rc2.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_set_tiling

Rank 2: iwl_set_dynamic_key (warning)
	Reported 470 times (13682 total reports)
	"no space for new kew" message.
	This warning was last seen in version 2.6.30, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_set_dynamic_key

Rank 3: getnstimeofday (warning)
	Reported 309 times (2446 total reports)
	[suspend resume] getnstimeofday() is called before timekeeping is resumed
	This warning was last seen in version 2.6.29.4, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=getnstimeofday

Rank 4: ct_vm_map (warning) - sleeping in atomic context
	Reported 285 times (960 total reports)
	Bug in the creative XFI driver (backported to Fedora)
	This warning was last seen in version 2.6.29.4, and first seen in 2.6.29-rc4-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=ct_vm_map

Rank 5: parport_device_proc_unregister (warning)
	Reported 278 times (1810 total reports)
        Alan has a fix for this on LKML
	This warning was last seen in version 2.6.29.4, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_unregister

Rank 6: hres_timers_resume (warning)
	Reported 188 times (1024 total reports)
	[suspend resume] hres_timers_resume() is incorrectly called with interrupts on
	This warning was last seen in version 2.6.30-rc6, and first seen in 2.6.24.7.
	More info: http://www.kerneloops.org/searchweek.php?search=hres_timers_resume

Rank 7: generic_get_mtrr (warning)
	Reported 139 times (1009 total reports)
	BIOS bug where the MTRRs are not set up correctly
	This warning was last seen in version 2.6.30, and first seen in 2.6.25.3.
	More info: http://www.kerneloops.org/searchweek.php?search=generic_get_mtrr

Rank 8: dmar_table_init (warning)
	Reported 121 times (507 total reports)
	BIOS bug exposed via a WARN_ON
	This warning was last seen in version 2.6.30-rc8, and first seen in 2.6.29.
	More info: http://www.kerneloops.org/searchweek.php?search=dmar_table_init

Rank 9: minstrel_get_rate (warning)
	Reported 64 times (384 total reports)
	Issue with the ath5k driver
	This warning was last seen in version 2.6.30-rc3, and first seen in 2.6.27.12.
	More info: http://www.kerneloops.org/searchweek.php?search=minstrel_get_rate

Rank 10: dev_watchdog(r8169) (warning)
	Reported 62 times (9116 total reports)
	This warning was last seen in version 2.6.30-rc7, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 11: nv_tx_done_optimized (warning)
	Reported 61 times (2974 total reports)
	the NV ethernet driver is getting caught with the new DMA API checks
	This warning was last seen in version 2.6.30, and first seen in 2.6.29-rc3-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=nv_tx_done_optimized

Rank 12: tcp_recvmsg (warning)
	Reported 37 times (3797 total reports)
	fixed in 2.6.30 (commit 775273131810caa41dfc7f9e552ea5d8508caf40)
	This warning was last seen in version 2.6.30, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
