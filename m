From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.30-rc8-git4: Reported regressions 2.6.28 -> 2.6.29
Date: Sun,  7 Jun 2009 12:02:54 +0200 (CEST)
Message-ID: <sIiXQlfwS3D.A.81.dj7KKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions introduced between 2.6.28 and
2.6.29, for which there are no fixes in the mainline I know of.  If any of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.28
and 2.6.29, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-06-07      169       27          25
  2009-05-31      167       27          26
  2009-05-25      165       27          25
  2009-05-17      162       27          25
  2009-04-26      160       29          27
  2009-04-06      142       37          31
  2009-03-21      128       29          26
  2009-03-14      124       36          32
  2009-03-03      108       33          28
  2009-02-24       95       32          24
  2009-02-14       85       33          27
  2009-02-08       82       45          36
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13463
Subject		: Poor SSD performance
Submitter	: Jake <ellowitz@uchicago.edu>
Date		: 2009-06-05 17:37 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13411
Subject		: Barscanner (USB HID Keyboard) stopped functioning in kernels >= 2.6.28
Submitter	: Guido <bugzilla.kernel.org@starbase12.cjb.net>
Date		: 2009-05-31 12:21 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13375
Subject		: Kernel crash with 2.6.29 + nfs + xfs (radix-tree)
Submitter	: Alex Samad <alex@samad.com.au>
Date		: 2009-05-20 0:37 (19 days old)
References	: http://marc.info/?l=linux-kernel&m=124278675503699&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13371
Subject		: s2disk hangs with e100, kernel 2.6.29 and later
Submitter	: Richard Atterer <richard@2009.atterer.net>
Date		: 2009-05-16 22:51 (23 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=Unknown
References	: http://marc.info/?l=linux-kernel&m=124251446428166&w=4
		  http://lkml.org/lkml/2009/5/25/253
Handled-By	: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13339
Subject		: rtable leak in ipv4/route.c
Submitter	: Alexander V. Lukyanov <lav@yar.ru>
Date		: 2009-05-18 14:10 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13294
Subject		: i915: drm: xorg leaks drm objects massively
Submitter	: Sergei Trofimovich <slyich@gmail.com>
Date		: 2009-05-10 19:56 (29 days old)
References	: http://marc.info/?l=linux-kernel&m=124198547027903&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13269
Subject		: WARNING: at kernel/hrtimer.c:625 hres_timers_resume+0x3c/0x48() when resuming
Submitter	: cedric <cedric@belbone.be>
Date		: 2009-05-08 08:48 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13232
Subject		: ext3/4 with synchronous writes gets wedged by Postfix
Submitter	: David Watson <kernel-nospam@dbwatson.ukfsn.org>
Date		: 2009-05-03 19:46 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13225
Subject		: [2.6.29 regression] Software suspend no longer works
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2009-05-02 21:41 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13178
Subject		: Booting very slow
Submitter	: Martin Knoblauch <spamtrap@knobisoft.de>
Date		: 2009-04-24 12:45 (45 days old)
References	: http://marc.info/?l=linux-kernel&m=124057716231773&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13148
Subject		: resume after suspend-to-ram broken on Sony Vaio VGN-SR19VN when sony-laptop driver present
Submitter	: fanderay <fanderay4@googlemail.com>
Date		: 2009-04-22 14:39 (47 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13144
Subject		: resume from suspend fails using video card i915
Submitter	: C Sights <csights@fastmail.fm>
Date		: 2009-04-21 17:03 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13100
Subject		: can't anymore even do a s2ram-s2disk-s2ram cycle on acer aspire 5720G
Submitter	: Maxim Levitsky <maximlevitsky@gmail.com>
Date		: 2009-04-06 23:52 (63 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a0d4922da2e4ccb0973095d8d29f36f6b1b5f703
References	: http://marc.info/?l=linux-kernel&m=123906202829074&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13074
Subject		: gspca_stv06xx doesn't work with Logitech QuickCam Express (046d:0840)
Submitter	: Paulo Matias <matias@archlinux-br.org>
Date		: 2009-04-12 14:10 (57 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13072
Subject		: forcedeth seems to switch off eth on shutdown
Submitter	: Daniel Bierstedt <daniel.bierstedt@gmx.de>
Date		: 2009-04-12 07:00 (57 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13025
Subject		: After upgrading to kernel 2.6.29, pulseaudio stopped with some strange error
Submitter	: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Date		: 2009-04-06 19:47 (63 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13024
Subject		: nozomi: pppd fails on kernel 2.6.29
Submitter	: Mark Karpeles <mark@hell.ne.jp>
Date		: 2009-04-06 19:12 (63 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13017
Subject		: ATA bus errors on resume
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-03-25 5:19 (75 days old)
References	: http://marc.info/?l=linux-kernel&m=123795841615989&w=4
Handled-By	: Tejun Heo <htejun@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13001
Subject		: PCI-DMA: Out of IOMMU space
Submitter	:  <optimusgd@gmail.com>
Date		: 2009-04-03 09:30 (66 days old)
References	: http://lkml.org/lkml/2009/4/28/133


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12980
Subject		: lockup in X.org
Submitter	: Marcus Better <marcus@better.se>
Date		: 2009-03-31 08:58 (69 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12971
Subject		: "tg3 transmit timed out" when transmitting at high bitrate
Submitter	: Nikolay <dobrev666@gmail.com>
Date		: 2009-03-29 18:02 (71 days old)
Handled-By	: Matt Carlson <mcarlson@broadcom.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12909
Subject		: boot/kernel init duration regression from 2.6.28
Submitter	: CaT <cat@zip.com.au>
Date		: 2009-03-16 10:25 (84 days old)
References	: http://marc.info/?l=linux-kernel&m=123720083515950&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12899
Subject		: Crash in i915.ko: i915_driver_irq_handler
Submitter	: Helge Bahmann <helge.bahmann@secunet.com>
Date		: 2009-03-20 07:13 (80 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213@schottelius.org>
Date		: 2009-02-13 9:33 (115 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e806b4957412bf472d826bd8cc571da041248799
References	: http://marc.info/?l=linux-kernel&m=123451768406825&w=4
		  http://marc.info/?l=linux-kernel&m=123479975503827&w=2
Handled-By	: Eric Anholt <eric@anholt.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj@bk.ru>
Date		: 2009-02-09 13:01 (119 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cfe62c8010ac56e1bd3827e30386a87cc2f3594
Handled-By	: Alexey Starikovskiy <astarikovskiy@suse.de>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe@yahoo.com>
Date		: 2009-02-21 15:38 (107 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=14d200c5e5bd19219d930bbb9a5a22758c8f5bec
References	: http://marc.info/?l=linux-kernel&m=123523074304955&w=4
		  http://lkml.org/lkml/2009/4/27/317
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>
Patch		: http://patchwork.kernel.org/patch/20197/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (147 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
		  http://lkml.org/lkml/2009/4/6/527
Handled-By	: Bob Copeland <me@bobcopeland.com>
Patch		: http://patchwork.kernel.org/patch/28210/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.28 and 2.6.29, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=12398

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael
