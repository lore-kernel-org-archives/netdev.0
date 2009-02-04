From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc3-git6: Reported regressions from 2.6.28
Date: Wed,  4 Feb 2009 11:21:25 +0100 (CET)
Message-ID: <kkuKoQJIW-D.A.61C.auYiJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * Sorry for the delay, I had to take care of my own bugs first.
 * Some of the bugs below are fixed, but I wasn't able to track the fix=
es down.
 * There probably are some duplicates (mostly in the DRI area), but I w=
asn't
   100% sure.]

This message contains a list of some regressions from 2.6.28, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let=
 me know
either and I'll add them to the list.  Also, please let me know if any =
of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10



Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12618
Subject		: hackbench [pthread mode] regression with 2.6.29-rc3
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2009-02-01 7:30 (4 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D490dea45d00f01847ebebd007685d564aaf2cd98
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123347347726527&w=3D=
4
Handled-By	: Peter Zijlstra <peterz@infradead.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12617
Subject		: unable to compile e100 firmware into kernel
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2009-01-31 15:59 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123341764915181&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12616
Subject		: boot hang: async vs. kexec
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2009-01-29 13:15 (7 days old)
References	: http://lkml.org/lkml/2009/1/29/359


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12615
Subject		: boot hangs while bringing up gianfar ethernet
Submitter	: Ira Snyder <iws@ovro.caltech.edu>
Date		: 2009-01-29 19:41 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123325817201665&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12613
Subject		: [Suspend regression][DRM, RADEON]
Submitter	: etienne <etienne.basset@numericable.fr>
Date		: 2009-01-28 22:00 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Da9d51a5ad1154b5b20add1e8d30a5564f8aabbe9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123318030419558&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123334865404574&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12611
Subject		: kernel BUG at kernel/cgroup.c:398!
Submitter	: Bharata B Rao <bharata@linux.vnet.ibm.com>
Date		: 2009-01-28 15:49 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123315721707796&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12610
Subject		: sync-Regression in 2.6.28.2?
Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
Date		: 2009-01-27 9:35 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123304977706620&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12608
Subject		: 2.6.29-rc powerpc G5 Xorg legacy_mem regression
Submitter	: Hugh Dickins <hugh@veritas.com>
Date		: 2009-01-21 21:12 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd3a54014e2a94bd37b7dee5e76e03f7bc4fab49a
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123257250431870&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12606
Subject		: fb_mmap: circular locking dependency on hibernation
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2009-01-27 18:37 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123308162731408&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12604
Subject		: Commit 31a12666d8f0c22235297e1c1575f82061480029 slows down B=
erkeley DB
Submitter	: Jan Kara <jack@suse.cz>
Date		: 2009-01-30 1:23 (6 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D31a12666d8f0c22235297e1c1575f82061480029
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123327862901800&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12602
Subject		: CRED changes causing setuid failures
Submitter	: David Smith <dsmith@redhat.com>
Date		: 2009-01-29 21:35 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd84f4f992cbd76e8f39c488cf0c5d123843923b1
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123326501813668&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12601
Subject		: virt-manager broken on 2.6.29-rc2
Submitter	: Stephen Hemminger <shemminger@vyatta.com>
Date		: 2009-01-29 5:21 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123320655819589&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12600
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Date		: 2009-01-13 23:17 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188898423532&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12599
Subject		: dri /dev node disappeared with 2.6.29-rc1
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2009-01-15 13:42 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123202701026647&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12591
Subject		: NULL pointer dereference in blk_queue_io_stat
Submitter	: Petr Vandrovec <vandrove@vc.cvut.cz>
Date		: 2009-01-31 23:58 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dbc58ba9468d94d62c56ab9b47173583ec140b165
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12574
Subject		: possible circular locking dependency detected
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2009-01-29 11:35 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12571
Subject		: Suspend-resume on Dell Latitude D410 newly broken in 2.6.29-=
rc*
Submitter	: Ross Boswell <drb@med.co.nz>
Date		: 2009-01-29 03:46 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12551
Subject		: end_request: I/O error, dev cciss/c0d0, sector 87435720
Submitter	: Ralf Hildebrandt <ralf.hildebrandt@charite.de>
Date		: 2009-01-27 06:51 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12518
Subject		: BUG: using smp_processor_id() in preemptible [00000000] code=
:  dellWirelessCtl/...
Submitter	: Alex Riesen <fork0@users.sf.net>
Date		: 2009-01-21 14:21 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12511
Subject		: WARNING: at drivers/dma/dmaengine.c:352
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-19 21:31 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123240070614443&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12510
Subject		: 2.6.29-rc2 dies on startup
Submitter	: Ferenc Wagner <wferi@niif.hu>
Date		: 2009-01-19 12:53 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123236969321703&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12508
Subject		: "powerpc/pci: Reserve legacy regions on PCI" broke my G3
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-01-17 22:46 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc1f343028d35ba4e88cd4a3c44e0d8b8a84264ee
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123223247325452&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12506
Subject		: Undefined symbols when CONFIG_MFD_PCF50633 is enabled
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan@pardus.org.tr>
Date		: 2009-01-17 10:56 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123218991104592&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12505
Subject		: 2.6.29-rc1 Firefox crashing on page load
Submitter	: Justin Madru <jdm64@gawab.com>
Date		: 2009-01-16 20:56 (20 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D4217458dafaa57d8e26a46f5d05ab8c53cf64191
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123213941914274&w=3D=
4
Handled-By	: Justin P. Mattock <justinmattock@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12503
Subject		: [slab corruption] BUG key_jar: Poison overwritten
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-15 18:16 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123204353425825&w=3D=
4
Handled-By	: David Howells <dhowells@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12502
Subject		: pipe_read oops on sh
Submitter	: Adrian McMenamin <lkmladrian@gmail.com>
Date		: 2009-01-15 9:48 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123201298005600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12501
Subject		: build bug in eeepc-laptop.c
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-14 17:25 (22 days old)
References	: http://lkml.org/lkml/2009/1/14/315


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-01-13 18:34 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123187185426236&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12497
Subject		: new barrier warnings in 2.6.29-rc1
Submitter	: Christoph Hellwig <hch@lst.de>
Date		: 2009-01-12 15:46 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123177528217154&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12494
Subject		: Sony backlight regression from 2.6.28 to 29-rc
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2009-01-19 8:14 (17 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D123235286829512&w=3D4
Handled-By	: Mattia Dongili <malattia@linux.it>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12491
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Date		: 2009-01-13 23:17 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188898423532&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123174591509586&w=3D=
4
Handled-By	: Bob Copeland <me@bobcopeland.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12444
Subject		: X hangs following switch from radeonfb console - Bisected
Submitter	: Graham Murray <graham@gmurray.org.uk>
Date		: 2009-01-13 14:03 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12441
Subject		: Xorg can't use dri on radeon X1950 AGP
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2009-01-13 05:20 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen@cn.fujitsu.com>
Date		: 2009-01-08 14:11 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123142399720125&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-01-07 22:43 (29 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123136836213319&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12417
Subject		: glx performance drop with: "x86: PAT: implement track/untrac=
k of pfnmap regions for x86 - v3"
Submitter	: Alexey Fisher <bug-track@fisher-privat.net>
Date		: 2009-01-06 18:46 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D5899329b19100c0b82dc78e9b21ed8b920c9ffb3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123126782822696&w=3D=
4
Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
		  Ingo Molnar <mingo@elte.hu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12415
Subject		: WARNING: at drivers/net/wireless/iwlwifi/iwl-sta.c:689
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-05 10:36 (31 days old)
References	: http://marc.info/?l=3Dlinux-wireless&m=3D123115178019082&w=
=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-05 4:13 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123112882127823&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12621
Subject		: Resume broken on iBook
Submitter	: Andreas Schwab <schwab@suse.de>
Date		: 2009-02-01 16:54 (4 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Daa8c6c93747f7b55fa11e1624fec8ca33763a805
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
		  Benjamin Herrenschmidt <benh@kernel.crashing.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D20085&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12609
Subject		: v2.6.29-rc2 libata sff 32bit PIO regression
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2009-01-23 23:52 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123275478111406&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123254501314058&w=3D4
Handled-By	: Mikael Pettersson <mikpe@it.uu.se>
		  Hugh Dickins <hugh@veritas.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123254501314058&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12605
Subject		: Suspend regression, hang after matroxfb
Submitter	: Eric Sesterhenn <snakebyte@gmx.de>
Date		: 2009-01-29 12:58 (7 days old)
References	: http://thread.gmane.org/gmane.linux.power-management.gener=
al/12640
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123335902122029&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12598
Subject		: tg3 dead after resume
Submitter	: Parag Warudkar <parag.lkml@gmail.com>
Date		: 2009-01-29 0:14 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123318968501524&w=3D=
4
Handled-By	: Linus Torvalds <torvalds@linux-foundation.org>
		  Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123365342301877&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12538
Subject		: xfs_fsr fails on 2.6.29-rc kernels
Submitter	: Paul Martin <pm@debian.org>
Date		: 2009-01-25 13:02 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D743bb4650da9e2595d6cedd01c680b5b9398c74a
Handled-By	: Eric Sandeen <sandeen@sandeen.net>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D19986&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12509
Subject		: lockdep report. fb_mmap vs sys_mmap2
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2009-01-17 18:19 (19 days old)
References	: http://lkml.org/lkml/2009/1/17/176
Handled-By	: Andrea Righi <righi.andrea@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123231032115956&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12496
Subject		: swsusp cannot find resume device (sometimes)
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2009-01-09 12:24 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123150395731165&w=3D=
4
Handled-By	: Arjan van de Ven <arjan@infradead.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123156441218358&w=3D4
		  http://marc.info/?t=3D123156453100002&r=3D1&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12495
Subject		: thinkpad problems during resume
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-17 15:48 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De39ad415ac15116df213dfa2aa2a4f1b0857af9c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123220746125479&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123170361827197&w=3D4
Handled-By	: Mike Travis <travis@sgi.com>
Patch		: http://lkml.org/lkml/2009/1/16/375
		  http://lkml.org/lkml/2009/1/16/376
		  http://lkml.org/lkml/2009/1/16/378


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12493
Subject		: ACPI related kernel panic when booting 2.6.29-rc2
Submitter	: Peter Klotz <peter.klotz@aon.at>
Date		: 2009-01-17 20:47 (19 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D123222565017047&w=3D4
Handled-By	: Alexey Starikovskiy <aystarik@gmail.com>
		  Tero Roponen <tero.roponen@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-acpi&m=3D123223261225680&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12427
Subject		: cpumask change causes sparc build bustage
Submitter	: David Miller <davem@davemloft.net>
Date		: 2009-01-11 8:31 (25 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D588235bb53f2c215f0d4b08fd30b461fedc3338e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123166268013838&w=3D=
4
Handled-By	: David Miller <davem@davemloft.net>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123167571525706&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12416
Subject		: Recent change to kernel spikes out ccache/distcc
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2009-01-06 15:15 (30 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123125495000603&w=3D=
4
Patch		: http://lkml.org/lkml/2009/1/20/78


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12400
Subject		: git-latest: kernel oops in IOMMU setup
Submitter	: Dirk Hohndel <hohndel@infradead.org>
Date		: 2009-01-08 20:05 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123144520124853&w=3D=
4
Handled-By	: Dirk Hohndel <hohndel@infradead.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123152033725557&w=3D4


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D12398

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
