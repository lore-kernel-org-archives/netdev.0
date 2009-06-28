From: Arjan van de Ven <arjan@infradead.org>
Subject: kerneloops.org report for the week
Date: Sun, 28 Jun 2009 09:10:55 -0700
Message-ID: <20090628091055.12a4fb9e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, x86@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60977 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbZF1QJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few "highlights" this week
* mem_cgroup_add_lru_list (rank 2) is a high rising issue;
  it's list corruption, question is why this is new
* rank 13 (memcmp in the raid code) is also new
* the warning in get_free_pages that has been discussed on lkml is dropping
  from the ranks again


This week, a total of 15273 oopses and warnings have been reported,
compared to 13384 reports in the previous week.


Rank 1: i915_gem_set_tiling (warning)
	Reported 2754 times (8928 total reports)
	[gem] Failure in the tiling code
	This warning was last seen in version 2.6.31-rc0-git15, and first seen in 2.6.29-rc2.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_set_tiling

Rank 2: mem_cgroup_add_lru_list (warn)
	Reported 1554 times (1622 total reports)
	List corruption in the VM code
	This oops was last seen in version 2.6.30-git19, and first seen in 2.6.29.
	More info: http://www.kerneloops.org/searchweek.php?search=mem_cgroup_add_lru_list

Rank 3: getnstimeofday (warning)
	Reported 1319 times (4893 total reports)
	[suspend resume] getnstimeofday() is called before timekeeping is resumed
	This oops was last seen in version 2.6.30, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=getnstimeofday

Rank 4: iwl_set_dynamic_key (warning)
	Reported 825 times (16074 total reports)
	no space for new kew"
	This warning was last seen in version 2.6.30, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_set_dynamic_key

Rank 5: ct_vm_map (warning)
	Reported 773 times (2362 total reports)
	Fedora: Bug in the creative XFI driver backport 
	This warning was last seen in version 2.6.29.5, and first seen in 2.6.29-rc4-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=ct_vm_map

Rank 6: parport_device_proc_unregister (warning)
	Reported 766 times (3660 total reports)
	Alan has a fix for this
	This warning was last seen in version 2.6.29.4, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_unregister

Rank 7: hres_timers_resume (warning)
	Reported 763 times (2368 total reports)
	[suspend resume] hres_timers_resume() is incorrectly called with interrupts on
	This warning was last seen in version 2.6.30, and first seen in 2.6.24.7.
	More info: http://www.kerneloops.org/searchweek.php?search=hres_timers_resume

Rank 8: generic_get_mtrr (warning)
	Reported 544 times (2061 total reports)
	BIOS bug where the MTRRs are not set up correctly
	This warning was last seen in version 2.6.30, and first seen in 2.6.25.3.
	More info: http://www.kerneloops.org/searchweek.php?search=generic_get_mtrr

Rank 9: dmar_table_init (warning)
	Reported 346 times (1206 total reports)
	BIOS bug exposed via a WARN_ON
	This warning was last seen in version 2.6.31-rc0-git18, and first seen in 2.6.29.
	More info: http://www.kerneloops.org/searchweek.php?search=dmar_table_init

Rank 10: minstrel_get_rate (warning)
	Reported 228 times (796 total reports)
	Issue with the ath5k driver
	This warning was last seen in version 2.6.30-rc3, and first seen in 2.6.27.12.
	More info: http://www.kerneloops.org/searchweek.php?search=minstrel_get_rate

Rank 11: dev_watchdog(r8169) (oops)
	Reported 206 times (9616 total reports)
	This oops was last seen in version 2.6.30, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 12: ath_get_rate (warning)
	Reported 145 times (1051 total reports)
	This warning was last seen in version 2.6.30, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=ath_get_rate

Rank 13: memcmp (oops)
	Reported 131 times (273 total reports)
	memcmp trips up in the raid code
	This oops was last seen in version 2.6.29.4, and first seen in 2.6.21-rc3.
	More info: http://www.kerneloops.org/searchweek.php?search=memcmp


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
