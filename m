From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc2: Reported regressions 2.6.31 -> 2.6.32
Date: Tue, 29 Dec 2009 16:26:32 +0100 (CET)
Message-ID: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * I really hope that at least _some_ of the bugs below have been alrea=
dy
   fixed, but I didn't have the time to search through all of the histo=
ries.
   _Please_ let me know which of them can be closed.
 * If you close one of the bugs in this list, please do your best to pu=
t the
   hash of the fix commit into the Bugzilla entry.]

This message contains a list of some regressions introduced between 2.6=
=2E31 and
2.6.32, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
31
and 2.6.32, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-12-29      124       60          57
  2009-11-21       86       29          25
  2009-11-16       84       46          41
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14943
Subject		: nfs regression?
Submitter	: Nikola Ciprich <extmaillist@linuxbox.cz>
Date		: 2009-12-28 12:10 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126200276223524&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14939
Subject		: drm: random hang with i915
Submitter	: Arnd Bergmann <arnd@arndb.de>
Date		: 2009-12-07 17:30 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126020704125723&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14933
Subject		: OOM killer unexpectedly called
Submitter	: A. Boulan <arnaud.boulan@libertysurf.fr>
Date		: 2009-12-24 23:42 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126169821317492&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14922
Subject		: 2.6.32 seemed to have broken nVidia MCP7A sata controller
Submitter	: Mike Cui <cuicui@gmail.com>
Date		: 2009-12-19 6:13 (11 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D126120323407742&w=3D4
Handled-By	: Jeff Garzik <jeff@garzik.org>
		  Robert Hancock <hancockrwd@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14905
Subject		: kernel BUG at kernel/timer.c:951!
Submitter	: Bernard Pidoux <bernard.pidoux@upmc.fr>
Date		: 2009-12-19 13:38 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126122997831460&w=3D=
4
Handled-By	: Jarek Poplawski <jarkao2@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14903
Subject		: Kernel panic - not syncing: Attempted to kill init!
Submitter	: Zhiyong Wu <zwu.kernel@gmail.com>
Date		: 2009-12-18 4:08 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126110931124738&w=3D=
4
Handled-By	: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14902
Subject		: Boot ends not on tty1
Submitter	: Andreas Friedrich <andreas.friedrich@ts.fujitsu.com>
Date		: 2009-12-15 8:05 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126086495304263&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14898
Subject		: ksoftirqd problem
Submitter	: Nico <segfault2@hotmail.com>
Date		: 2009-12-13 19:05 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126073114325690&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14897
Subject		: i915: Commit 0e442c60 causes flickering
Submitter	: David John <davidjon@xenontk.org>
Date		: 2009-12-09 17:26 (21 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0e442c60dd39ac6924b11a20497734bd2303744c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126037889600769&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14896
Subject		: REGRESSION for RT2561/RT61 in 2.6.32, related to power savin=
g
Submitter	: Alan Stern <stern@rowland.harvard.edu>
Date		: 2009-12-06 22:12 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126013756829691&w=3D=
4
Handled-By	: Gertjan van Wingerde <gwingerde@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14895
Subject		: BUG in kernel 2.6.32 when using luks encrypted root and RAID=
0..
Submitter	: r4 <mk_4@centrum.cz>
Date		: 2009-12-03 18:24 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986664904751&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14894
Subject		: pohmelfs: NULL pointer dereference
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-12-02 1:11 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125971633107940&w=3D=
4
Handled-By	: Evgeniy Polyakov <zbr@ioremap.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14893
Subject		: Tasks stuck on I/O on armel with 2.6.32-rc8
Submitter	: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Date		: 2009-11-24 23:05 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125910438530554&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14892
Subject		: intel, KMS, suspend2ram resume, screen black
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2009-11-24 4:35 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125903731125558&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14891
Subject		: Deadlock regression related to NFS root
Submitter	: Stephen R. van den Berg <srb@cuci.nl>
Date		: 2009-11-24 0:24 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125902279909452&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust@netapp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14889
Subject		: System wakeup by time not working anymore
Submitter	: Malte Schr=C3=B6der <maltesch@gmx.de>
Date		: 2009-12-03 18:06 (27 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dabd6633c67925f90775bb74755f9c547e30f1f20
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986362631900&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14888
Subject		: 2.6.32-rc8 shuts down after reaching critical temperature - =
thinkpad T500
Submitter	: Christoph Hellwig <hch@lst.de>
Date		: 2009-11-25 10:28 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125914494713476&w=3D=
4
Handled-By	: Len Brown <lenb@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14862
Subject		: intel-agp breaks X, regression from 2.6.31
Submitter	: Zephaniah E. Hull. <warp-spam_kernel@aehallh.com>
Date		: 2009-12-22 22:59 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14841
Subject		: unable to enumerate USB device on port X after suspend/resum=
e
Submitter	: Fruhwirth Clemens <clemens@endorphin.org>
Date		: 2009-12-19 11:45 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14840
Subject		: X11 screen black after resume, only mouse pounter is seen
Submitter	: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
Date		: 2009-12-19 10:56 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14817
Subject		: When is system under load, then freeze/HD fail
Submitter	: okias <d.okias@gmail.com>
Date		: 2009-12-15 11:12 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14794
Subject		: IP address assigned by DHCP is dropped after ~40 seconds
Submitter	: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
Date		: 2009-12-13 08:59 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14786
Subject		: Regression in 9f15226e7 (x86, ucode-amd: Ensure ucode update=
 on suspend/resume after CPU off/online cycle)
Submitter	: Tomas Carnecky <tom@dbservice.com>
Date		: 2009-12-11 00:50 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14783
Subject		: Unhandled IRQ on Thinkpad R61i: "irq 16: nobody cared"
Submitter	: Stefan Zegenhagen <sz@emlix.com>
Date		: 2009-12-10 19:14 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14782
Subject		: Suspend hangs Lenovo SL300 after gdm login
Submitter	: Gary Trakhman <gary.trakhman@gmail.com>
Date		: 2009-12-10 18:53 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14781
Subject		: 181a533 is causing severe screen flickering on 965GM
Submitter	:  <benisty.e@gmail.com>
Date		: 2009-12-10 08:49 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14748
Subject		: e1000e NIC not working after reboot
Submitter	: Maciek Sitarz <macieks@freesco.pl>
Date		: 2009-12-06 13:04 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14743
Subject		: New rtl8187 rfkill support prevents using wlan completely.
Submitter	: Antti Kaijanm=C3=A4ki <antti@kaijanmaki.net>
Date		: 2009-12-05 20:10 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742
Subject		: 2.6.32 new menu idle governor causes very high CPU temp
Submitter	:  <akwatts@ymail.com>
Date		: 2009-12-05 17:24 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14740
Subject		: battery status info dissapears in 2.6.32 - MSI PR200
Submitter	: Leonid Podolny <leonidp.lists@gmail.com>
Date		: 2009-12-05 14:16 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14731
Subject		: rt61pci regression
Submitter	: tim blechmann <tim@klingt.org>
Date		: 2009-12-04 09:33 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14730
Subject		: sky2 won't work after suspend/resume cycle
Submitter	: Maciej J. Woloszyk <mat@esi.com.pl>
Date		: 2009-12-04 09:02 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14728
Subject		: Graphic corruption
Submitter	: Kornel Lugosi <coornail@gmail.com>
Date		: 2009-12-03 21:27 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14727
Subject		: livelock in futex_wait_setup
Submitter	: Stas Sergeev <stsp@aknet.ru>
Date		: 2009-12-03 20:55 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14670
Subject		: i915: playing video via XVideo extension makes the screen fl=
icker
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2009-11-23 13:15 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14667
Subject		: bisected 2.6.32 regression - Temperatures not correctly dete=
cted after suspend - Dell Studio XPS 16 laptop
Submitter	: Federico Chiacchiaretta <federico.chia@gmail.com>
Date		: 2009-11-22 20:42 (38 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14657
Subject		: perf subsystem breakage in 2.6.32-rc7
Submitter	: Arjan van de Ven <arjan@infradead.org>
Date		: 2009-11-19 19:50 (41 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125866013419738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14656
Subject		: Oops at __rmqueue+0x98 with 2.6.32-rc6
Submitter	: Lucas C. Villa Real <lucasvr@gobolinux.org>
Date		: 2009-11-19 3:48 (41 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125860255229092&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14655
Subject		: swapper generated call trace in 2.6.32-rc7
Submitter	: Peter Teoh <htmldeveloper@gmail.com>
Date		: 2009-11-18 8:09 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125853179413679&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14627
Subject		: i915: *ERROR* Execbuf while wedged
Submitter	: Michael <schnitzelkuchen@googlemail.com>
Date		: 2009-11-15 10:48 (45 days old)
References	: http://lkml.org/lkml/2009/11/15/40


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14625
Subject		: Commit d451564 breaks ARM
Submitter	: Russell King <rmk+lkml@arm.linux.org.uk>
Date		: 2009-11-13 15:11 (47 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd4515646699b6ad7b1a98ceb871296b957f3ef47
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125812520315835&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-11-12 4:58 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2009-11-06 7:38 (54 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14538
Subject		: Unable to associate with AP after resume since 2.6.32-rc6
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-11-03 22:07 (57 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd50bae33d1358b909ade05ae121d83d3a60ab63f


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi@niif.hu>
Date		: 2009-10-28 23:49 (63 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock@gmail.com>
Date		: 2009-10-23 16:45 (68 days old)
References	: http://lkml.org/lkml/2009/10/23/252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14485
Subject		: System lockup running "cat /sys/kernel/debug/dri/0/i915_regs=
"
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-10-26 4:00 (65 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125652968117713&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex@digriz.org.uk>
Date		: 2009-10-23 10:30 (68 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2009-10-20 01:52 (71 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14436
Subject		: Computer becomes unusable without any apparent reason
Submitter	: Pitxyoki <Pitxyoki@gmail.com>
Date		: 2009-10-18 18:32 (73 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm@free.fr>
Date		: 2009-10-17 09:29 (74 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14417
Subject		: [Regression] Wireless driver iwlagn+iwlcore doesn't work aft=
er resume (needs reloading)
Submitter	: Eddy Petri=C8=99or <eddy.petrisor+linbug@gmail.com>
Date		: 2009-10-16 11:07 (75 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14406
Subject		: uvcvideo stopped work on Toshiba
Submitter	: okias <d.okias@gmail.com>
Date		: 2009-10-14 19:08 (77 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster@gmail.com>
Date		: 2009-10-06 14:38 (85 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14331
Subject		: Radeon XPRESS 200M: System hang with radeon DRI and Fedora 1=
0 userspace unless DRI=3Doff
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2009-10-06 00:29 (85 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-09-30 20:07 (91 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer@pengutronix.de>
Date		: 2009-09-30 15:11 (91 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14926
Subject		: ucc_geth broken
Submitter	: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Date		: 2009-12-23 17:40 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126159003430429&w=3D=
4
Handled-By	: Anton Vorontsov <avorontsov@ru.mvista.com>
Patch		: http://patchwork.kernel.org/patch/69585/
		  http://patchwork.kernel.org/patch/69600/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14630
Subject		: sched_rt_periodic_timer vs cpu hotplug
Submitter	: Heiko Carstens <heiko.carstens@de.ibm.com>
Date		: 2009-11-11 10:18 (49 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125793470309588&w=3D=
4
Handled-By	: Peter Zijlstra <peterz@infradead.org>
Patch		: http://patchwork.kernel.org/patch/60250/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14483
Subject		: Interrupts enabled after irqrouter_resume - iMac9,1
Submitter	: Justin Mattock <justinmattock@gmail.com>
Date		: 2009-10-25 19:58 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650070420168&w=3D=
4
Handled-By	: Xiaotian Feng <dfeng@redhat.com>
Patch		: http://patchwork.kernel.org/patch/64771/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.31 and 2.6.32, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14230

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
