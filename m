From: Arjan van de Ven <arjan@infradead.org>
Subject: kerneloops.org report for the week of October 11th 2009
Date: Sun, 11 Oct 2009 16:21:11 -0700
Message-ID: <20091011162111.2d784f01@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, netdev@vger.kernel.org, jbarnes@virtuousgeek.org,
	linux-acpi@vger.kernel.org, dri-devel@lists.sourceforge.net,
	torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <dri-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

A very clear distribution this time: the number one is almost 4 times
more frequently reported than the number 2. It's also an old time favorite,
with over *56 thousand* total reports..... time for the graphics team to fix the issue!
Other old timers are the ct_vm_map() function (over 11 thousand reports) as well as
various "your bios is broken" warnings.

There's also some recurring networking issues, with tcp_recvmsg and inet_sock_destruct
as main functions there.

New this time is a warning in the cpufreq code, which somehow now gets called
with interrupts off just when it wants to do a smp_call_function() during suspend resume;
also new is an interaction between ext4 and the quota code. Also new is an ioremap leak check
that might be a Fedora-only issue.


This week, a total of 16542 oopses and warnings have been reported,
compared to 14309 reports in the previous week.


Per file statistics
3779	drivers/gpu/drm/i915/i915_gem_tiling.c
844	drivers/pci/dmar.c
665	arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c
576	pci/ctxfi/ctvmem.c
426	arch/x86/kernel/cpu/mtrr/generic.c
347	net/ipv4/af_inet.c
263	net/ipv4/tcp.c
262	kernel/time.c
259	arch/x86/mm/ioremap.c
244	drivers/net/sis900.c
215	drivers/net/wireless/iwlwifi/iwl-sta.c
208	drivers/parport/procfs.c


Rank 1: i915_gem_set_tiling (warning)
	Reported 3779 times (56835 total reports)
	[gem] Failure in the tiling code
	This warning was last seen in version 2.6.31, and first seen in 2.6.29-rc2.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_set_tiling

Rank 2: suspend_test_finish(resume devices) (oops)
	Reported 1022 times (7869 total reports)
	This oops was last seen in version 2.6.31.1, and first seen in 2.6.28-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish(resume devices)

Rank 3: dmar_table_init (warning)
	Reported 845 times (8224 total reports)
	BIOS bug exposed via a WARN_ON
	This warning was last seen in version 2.6.31, and first seen in 2.6.29.
	More info: http://www.kerneloops.org/searchweek.php?search=dmar_table_init

Rank 4: get_cur_val (warning)
	Reported 665 times (2585 total reports)
	cpufreq gets called during suspend/resume and ends up calling smp_call_function with irqs off
	This warning was last seen in version 2.6.31, and first seen in 2.6.29-rc1.
	More info: http://www.kerneloops.org/searchweek.php?search=get_cur_val

Rank 5: ct_vm_map (warning)
	Reported 576 times (11868 total reports)
	Bug in the creative XFI driver (backported to Fedora)
	This warning was last seen in version 2.6.30.8, and first seen in 2.6.29-rc4-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=ct_vm_map

Rank 6: dquot_claim_space (oops)
	Reported 437 times (3257 total reports)
	Interaction between EXT4 and the quota code
	This oops was last seen in version 2.6.31, and first seen in 2.6.30.
	More info: http://www.kerneloops.org/searchweek.php?search=dquot_claim_space

Rank 7: generic_get_mtrr (warning)
	Reported 426 times (9303 total reports)
	BIOS bug where the MTRRs are not set up correctly
	This warning was last seen in version 2.6.31, and first seen in 2.6.25.3.
	More info: http://www.kerneloops.org/searchweek.php?search=generic_get_mtrr

Rank 8: inet_sock_destruct (warning)
	Reported 347 times (5453 total reports)
	This warning was last seen in version 2.6.31, and first seen in 2.6.27-rc2.
	More info: http://www.kerneloops.org/searchweek.php?search=inet_sock_destruct

Rank 9: tcp_recvmsg (oops)
	Reported 263 times (6206 total reports)
	fixed in 2.6.30 (commit 775273131810caa41dfc7f9e552ea5d8508caf40)
	This oops was last seen in version 2.6.31.3, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg

Rank 10: getnstimeofday (warning)
	Reported 262 times (18624 total reports)
	[suspend resume] getnstimeofday() is called before timekeeping is resumed
	This warning was last seen in version 2.6.31, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=getnstimeofday

Rank 11: check_early_ioremap_leak (warning)
	Reported 256 times (1101 total reports)
	This warning was last seen in version 2.6.31, and first seen in 2.6.24-rc8.
	More info: http://www.kerneloops.org/searchweek.php?search=check_early_ioremap_leak

Rank 12: dev_watchdog(sis900) (oops)
	Reported 244 times (11843 total reports)
	This oops was last seen in version 2.6.30.8, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 13: iwl_set_dynamic_key (warning)
	Reported 215 times (21737 total reports)
	no space for new kew"
	This warning was last seen in version 2.6.30, and first seen in 2.6.27.35.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_set_dynamic_key


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
--
