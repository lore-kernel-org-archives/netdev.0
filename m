From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc4: Reported regressions from 2.6.28
Date: Sun,  8 Feb 2009 20:05:59 +0100 (CET)
Message-ID: <AIghyjFgMFP.A.uZD._10jJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.28, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-02-08       82       45          36
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12671
Subject		: uvc_status_cleanup(): undefined reference to `input_unregister_device'
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-02-08 14:58 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123410529909318&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12670
Subject		: BUG: unable to handle kernel paging request at pin_to_kill+0x21
Submitter	: Alessandro Bono <alessandro.bono@gmail.com>
Date		: 2009-02-08 11:04 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123409113223833&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12669
Subject		: 2.6.28.4 regression: mmap fails if mlockall used
Submitter	: Sami Farin <safari-kernel@safari.iki.fi>
Date		: 2009-02-08 10:52 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123409037423068&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12668
Subject		: USB flash disk surprise disconnect
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2009-02-08 10:21 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123408851821292&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12667
Subject		: Badness at kernel/time/timekeeping.c:98 in pmud (timekeeping_suspended)
Submitter	: Paul Collins <paul@burly.ondioline.org>
Date		: 2009-01-21 7:15 (19 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1c5745aa380efb6417b5681104b007c8612fb496
References	: http://marc.info/?l=linux-kernel&m=123252215315106&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12666
Subject		: Build failure with latest -git: btrfs on ppc64
Submitter	: Chuck Ebbert <cebbert@redhat.com>
Date		: 2009-02-07 20:50 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=123404002114219&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12664
Subject		: viafb triggers BUG at mm/vmalloc.c:294
Submitter	: wixor <wixorpeek@gmail.com>
Date		: 2009-02-07 19:44 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=123403591109515&w=4
Handled-By	: Alexey Dobriyan <adobriyan@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12661
Subject		: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-02-05 14:41 (4 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=64ff3b938ec6782e6585a83d5459b98b0c3f6eb8
References	: http://marc.info/?l=linux-kernel&m=123384496107361&w=4
Handled-By	: Herbert Xu <herbert@gondor.apana.org.au>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12660
Subject		: Linux 2.6.28.3 freezing on a 32-bits x86 Thinkpad T43p
Submitter	: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date		: 2009-02-04 21:11 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=123378196022258&w=4
Handled-By	: Ingo Molnar <mingo@elte.hu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12659
Subject		: Failure to resume two Sandisk USB flash drives attached to a Belkin USB Busport Mobile (F5U022).
Submitter	: 2.6.29-rc3-git3 -- Failure to resume two Sandisk USB flash drives
Date		: 2009-02-03 4:58 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=123363718614763&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12656
Subject		: iwl3945 broken after hibernation: Wait for START_ALIVE timeout after 2000ms.
Submitter	: Alex Riesen <fork0@users.sf.net>
Date		: 2009-02-08 01:52 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12650
Subject		: Strange load average and ksoftirqd behavior with 2.6.29-rc2-git1
Submitter	: Damien Wyart <damien.wyart@free.fr>
Date		: 2009-01-20 16:25 (20 days old)
References	: http://marc.info/?l=linux-kernel&m=123246937207675&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12649
Subject		: Early crash with 2.6.29-rc3
Submitter	: Andrew McMillan <andrew@morphoss.com>
Date		: 2009-02-04 20:03 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=123377840816097&w=4
Handled-By	: Len Brown <lenb@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12617
Subject		: unable to compile e100 firmware into kernel
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2009-01-31 15:59 (9 days old)
References	: http://marc.info/?l=linux-kernel&m=123341764915181&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12615
Subject		: boot hangs while bringing up gianfar ethernet
Submitter	: Ira Snyder <iws@ovro.caltech.edu>
Date		: 2009-01-29 19:41 (11 days old)
References	: http://marc.info/?l=linux-kernel&m=123325817201665&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12613
Subject		: [Suspend regression][DRM, RADEON]
Submitter	: etienne <etienne.basset@numericable.fr>
Date		: 2009-01-28 22:00 (12 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a9d51a5ad1154b5b20add1e8d30a5564f8aabbe9
References	: http://marc.info/?l=linux-kernel&m=123318030419558&w=4
		  http://marc.info/?l=linux-kernel&m=123334865404574&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12610
Subject		: sync-Regression in 2.6.28.2?
Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
Date		: 2009-01-27 9:35 (13 days old)
References	: http://marc.info/?l=linux-kernel&m=123304977706620&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12608
Subject		: 2.6.29-rc powerpc G5 Xorg legacy_mem regression
Submitter	: Hugh Dickins <hugh@veritas.com>
Date		: 2009-01-21 21:12 (19 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d3a54014e2a94bd37b7dee5e76e03f7bc4fab49a
References	: http://marc.info/?l=linux-kernel&m=123257250431870&w=4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12604
Subject		: Commit 31a12666d8f0c22235297e1c1575f82061480029 slows down Berkeley DB
Submitter	: Jan Kara <jack@suse.cz>
Date		: 2009-01-30 1:23 (10 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=31a12666d8f0c22235297e1c1575f82061480029
References	: http://marc.info/?l=linux-kernel&m=123327862901800&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12600
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Date		: 2009-01-13 23:17 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=123188898423532&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12574
Subject		: possible circular locking dependency detected
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2009-01-29 11:35 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12571
Subject		: Suspend-resume on Dell Latitude D410 newly broken in 2.6.29-rc*
Submitter	: Ross Boswell <drb@med.co.nz>
Date		: 2009-01-29 03:46 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12551
Subject		: end_request: I/O error, dev cciss/c0d0, sector 87435720
Submitter	: Ralf Hildebrandt <ralf.hildebrandt@charite.de>
Date		: 2009-01-27 06:51 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12510
Subject		: 2.6.29-rc2 dies on startup
Submitter	: Ferenc Wagner <wferi@niif.hu>
Date		: 2009-01-19 12:53 (21 days old)
References	: http://marc.info/?l=linux-kernel&m=123236969321703&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12508
Subject		: "powerpc/pci: Reserve legacy regions on PCI" broke my G3
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-01-17 22:46 (23 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=c1f343028d35ba4e88cd4a3c44e0d8b8a84264ee
References	: http://marc.info/?l=linux-kernel&m=123223247325452&w=4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12503
Subject		: [slab corruption] BUG key_jar: Poison overwritten
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-15 18:16 (25 days old)
References	: http://marc.info/?l=linux-kernel&m=123204353425825&w=4
Handled-By	: David Howells <dhowells@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12502
Subject		: pipe_read oops on sh
Submitter	: Adrian McMenamin <lkmladrian@gmail.com>
Date		: 2009-01-15 9:48 (25 days old)
References	: http://marc.info/?l=linux-kernel&m=123201298005600&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12501
Subject		: build bug in eeepc-laptop.c
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-14 17:25 (26 days old)
References	: http://lkml.org/lkml/2009/1/14/315


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-01-13 18:34 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=123187185426236&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12497
Subject		: new barrier warnings in 2.6.29-rc1
Submitter	: Christoph Hellwig <hch@lst.de>
Date		: 2009-01-12 15:46 (28 days old)
References	: http://marc.info/?l=linux-kernel&m=123177528217154&w=4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12494
Subject		: Sony backlight regression from 2.6.28 to 29-rc
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2009-01-19 8:14 (21 days old)
References	: http://marc.info/?l=linux-acpi&m=123235286829512&w=4
Handled-By	: Mattia Dongili <malattia@linux.it>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (28 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
Handled-By	: Bob Copeland <me@bobcopeland.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12444
Subject		: X hangs following switch from radeonfb console - Bisected
Submitter	: Graham Murray <graham@gmurray.org.uk>
Date		: 2009-01-13 14:03 (27 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen@cn.fujitsu.com>
Date		: 2009-01-08 14:11 (32 days old)
References	: http://marc.info/?l=linux-kernel&m=123142399720125&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-01-07 22:43 (33 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=linux-kernel&m=123136836213319&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-05 4:13 (35 days old)
References	: http://marc.info/?l=linux-kernel&m=123112882127823&w=4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12663
Subject		: Commit 8c7e58e690ae60ab4215b025f433ed4af261e103 breaks resume
Submitter	: Jiri Slaby <jirislaby@gmail.com>
Date		: 2009-02-07 18:40 (2 days old)
References	: http://lkml.org/lkml/2009/2/7/100
Handled-By	: Brian Gerst <brgerst@gmail.com>
Patch		: http://lkml.org/lkml/2009/2/7/100
		  http://lkml.org/lkml/2009/2/8/59


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12662
Subject		: linux 2.6.29-rc3 kernel failure with mptsas
Submitter	: Morten P.D. Stevens <mstevens@win-professional.com>
Date		: 2009-02-05 22:29 (4 days old)
References	: http://marc.info/?l=linux-kernel&m=123387302729741&w=4
Handled-By	: Andrew Morton <akpm@linux-foundation.org>
Patch		: http://marc.info/?l=linux-kernel&m=123396429501103&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12618
Subject		: hackbench [pthread mode] regression with 2.6.29-rc3
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2009-02-01 7:30 (8 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=490dea45d00f01847ebebd007685d564aaf2cd98
References	: http://marc.info/?l=linux-kernel&m=123347347726527&w=4
Handled-By	: Peter Zijlstra <peterz@infradead.org>
Patch		: http://marc.info/?l=linux-kernel&m=123383366122146&w=4
		  http://marc.info/?l=linux-kernel&m=123383366222152&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12609
Subject		: v2.6.29-rc2 libata sff 32bit PIO regression
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2009-01-23 23:52 (17 days old)
References	: http://marc.info/?l=linux-kernel&m=123275478111406&w=4
		  http://marc.info/?l=linux-kernel&m=123254501314058&w=4
Handled-By	: Mikael Pettersson <mikpe@it.uu.se>
		  Hugh Dickins <hugh@veritas.com>
		  Sergei Shtylyov <sshtylyov@ru.mvista.com>
Patch		: http://marc.info/?l=linux-kernel&m=123412278730735&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12606
Subject		: fb_mmap: circular locking dependency on hibernation
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2009-01-27 18:37 (13 days old)
References	: http://marc.info/?l=linux-kernel&m=123308162731408&w=4
Handled-By	: Andrea Righi <righi.andrea@gmail.com>
Patch		: http://marc.info/?l=linux-kernel&m=123365581406194&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12496
Subject		: swsusp cannot find resume device (sometimes)
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2009-01-09 12:24 (31 days old)
References	: http://marc.info/?l=linux-kernel&m=123150395731165&w=4
Handled-By	: Arjan van de Ven <arjan@infradead.org>
Patch		: http://marc.info/?l=linux-kernel&m=123156441218358&w=4
		  http://marc.info/?t=123156453100002&r=1&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12491
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Date		: 2009-01-13 23:17 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=123188898423532&w=4
Handled-By	: Roland Dreier <rolandd@cisco.com>
Patch		: http://marc.info/?l=linux-kernel&m=123378709730700&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12441
Subject		: Xorg can't use dri on radeon X1950 AGP
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2009-01-13 05:20 (27 days old)
Handled-By	: Dave Airlie <airlied@linux.ie>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=20032&action=view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12415
Subject		: WARNING: at drivers/net/wireless/iwlwifi/iwl-sta.c:689
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-05 10:36 (35 days old)
References	: http://marc.info/?l=linux-wireless&m=123115178019082&w=4
Handled-By	: Reinette Chatre <reinette.chatre@intel.com>
Patch		: http://marc.info/?l=linux-wireless&m=123316414222201&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=12398

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

