From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.30-rc7: Reported regressions 2.6.28 -> 2.6.29
Date: Sun, 24 May 2009 21:27:36 +0200 (CEST)
Message-ID: <GtY7d2eWpoK.A.ioC.MQcGKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13375
Subject		: Kernel crash with 2.6.29 + nfs + xfs (radix-tree)
Submitter	: Alex Samad <alex@samad.com.au>
Date		: 2009-05-20 0:37 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=124278675503699&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13371
Subject		: s2disk hangs with kernel 2.6.29 and later, SATA, Gigabyte EG45M-DS2H
Submitter	: Richard Atterer <richard@2009.atterer.net>
Date		: 2009-05-16 22:51 (9 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=295f00042aaf6b553b5f37348f89bab463d4a469
References	: http://marc.info/?l=linux-kernel&m=124251446428166&w=4
Handled-By	: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13294
Subject		: i915: drm: xorg leaks drm objects massively
Submitter	: Sergei Trofimovich <slyich@gmail.com>
Date		: 2009-05-10 19:56 (15 days old)
References	: http://marc.info/?l=linux-kernel&m=124198547027903&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13271
Subject		: ath9k stop working since 2.6.29
Submitter	: lyman <lymanrb@gmail.com>
Date		: 2009-05-10 01:58 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13269
Subject		: WARNING: at kernel/hrtimer.c:625 hres_timers_resume+0x3c/0x48() when resuming
Submitter	: cedric <cedric@belbone.be>
Date		: 2009-05-08 08:48 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13232
Subject		: ext3/4 with synchronous writes gets wedged by Postfix
Submitter	: David Watson <kernel-nospam@dbwatson.ukfsn.org>
Date		: 2009-05-03 19:46 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13225
Subject		: [2.6.29 regression] Software suspend no longer works
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2009-05-02 21:41 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13183
Subject		: forcedeth: no link during initialization
Submitter	: Harald Dunkel <harald.dunkel@t-online.de>
Date		: 2009-04-23 13:02 (32 days old)
References	: http://marc.info/?l=linux-kernel&m=124049180309233&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13178
Subject		: Booting very slow
Submitter	: Martin Knoblauch <spamtrap@knobisoft.de>
Date		: 2009-04-24 12:45 (31 days old)
References	: http://marc.info/?l=linux-kernel&m=124057716231773&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13175
Subject		: sata_nv incompatible with async scsi scan
Submitter	: Benny Halevy <bhalevy@panasas.com>
Date		: 2009-04-21 7:03 (34 days old)
References	: http://marc.info/?l=linux-kernel&m=124029746431777&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13144
Subject		: resume from suspend fails using video card i915
Submitter	: C Sights <csights@fastmail.fm>
Date		: 2009-04-21 17:03 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13100
Subject		: can't anymore even do a s2ram-s2disk-s2ram cycle on acer aspire 5720G
Submitter	: Maxim Levitsky <maximlevitsky@gmail.com>
Date		: 2009-04-06 23:52 (49 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a0d4922da2e4ccb0973095d8d29f36f6b1b5f703
References	: http://marc.info/?l=linux-kernel&m=123906202829074&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13074
Subject		: gspca_stv06xx doesn't work with Logitech QuickCam Express (046d:0840)
Submitter	: Paulo Matias <matias@archlinux-br.org>
Date		: 2009-04-12 14:10 (43 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13072
Subject		: forcedeth seems to switch off eth on shutdown
Submitter	: Daniel Bierstedt <daniel.bierstedt@gmx.de>
Date		: 2009-04-12 07:00 (43 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13025
Subject		: After upgrading to kernel 2.6.29, pulseaudio stopped with some strange error
Submitter	: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Date		: 2009-04-06 19:47 (49 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13024
Subject		: nozomi: pppd fails on kernel 2.6.29
Submitter	: Mark Karpeles <mark@hell.ne.jp>
Date		: 2009-04-06 19:12 (49 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13001
Subject		: PCI-DMA: Out of IOMMU space
Submitter	:  <optimusgd@gmail.com>
Date		: 2009-04-03 09:30 (52 days old)
References	: http://lkml.org/lkml/2009/4/28/133


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12980
Subject		: lockup in X.org
Submitter	: Marcus Better <marcus@better.se>
Date		: 2009-03-31 08:58 (55 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12971
Subject		: "tg3 transmit timed out" when transmitting at high bitrate
Submitter	: Nikolay <dobrev666@gmail.com>
Date		: 2009-03-29 18:02 (57 days old)
Handled-By	: Matt Carlson <mcarlson@broadcom.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12947
Subject		: r128: system hangs when X is started with DRI enabled
Submitter	: Jos van der Ende <seraph@xs4all.nl>
Date		: 2009-03-26 16:14 (60 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12909
Subject		: boot/kernel init duration regression from 2.6.28
Submitter	: CaT <cat@zip.com.au>
Date		: 2009-03-16 10:25 (70 days old)
References	: http://marc.info/?l=linux-kernel&m=123720083515950&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12899
Subject		: Crash in i915.ko: i915_driver_irq_handler
Submitter	: Helge Bahmann <helge.bahmann@secunet.com>
Date		: 2009-03-20 07:13 (66 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213@schottelius.org>
Date		: 2009-02-13 9:33 (101 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e806b4957412bf472d826bd8cc571da041248799
References	: http://marc.info/?l=linux-kernel&m=123451768406825&w=4
		  http://marc.info/?l=linux-kernel&m=123479975503827&w=2
Handled-By	: Eric Anholt <eric@anholt.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj@bk.ru>
Date		: 2009-02-09 13:01 (105 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cfe62c8010ac56e1bd3827e30386a87cc2f3594
Handled-By	: Alexey Starikovskiy <astarikovskiy@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (133 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
		  http://lkml.org/lkml/2009/4/6/527
Handled-By	: Bob Copeland <me@bobcopeland.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13186
Subject		: cpufreq timer teardown problem
Submitter	: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date		: 2009-04-23 14:00 (32 days old)
References	: http://marc.info/?l=linux-kernel&m=124049523515036&w=4
Handled-By	: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Patch		: http://patchwork.kernel.org/patch/19754/
		  http://patchwork.kernel.org/patch/19753/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe@yahoo.com>
Date		: 2009-02-21 15:38 (93 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=14d200c5e5bd19219d930bbb9a5a22758c8f5bec
References	: http://marc.info/?l=linux-kernel&m=123523074304955&w=4
		  http://lkml.org/lkml/2009/4/27/317
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>
Patch		: http://patchwork.kernel.org/patch/20197/


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

