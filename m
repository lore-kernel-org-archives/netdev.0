From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc6: Reported regressions 2.6.31 -> 2.6.32
Date: Mon,  1 Feb 2010 01:38:34 +0100 (CET)
Message-ID: <UgwvXSBS_tM.A.alD.1EiZLB@chimera>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:50510 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754195Ab0BAAwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 19:52:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NOTE:
 * Still growing faster than we're fixing them.]

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
  2010-02-01      149       50          45
  2010-01-24      140       45          43
  2010-01-10      130       44          40
  2009-12-29      124       60          57
  2009-11-21       86       29          25
  2009-11-16       84       46          41
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15193
Subject		: kswapd continuously active
Submitter	: Jan Engelhardt <jengelh@medozas.de>
Date		: 2010-01-22 23 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126420434519039&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15158
Subject		: oops related to i915_gem_object_save_bit_17_swizzle
Submitter	: Werner Lemberg <wl@gnu.org>
Date		: 2010-01-28 08:26 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15156
Subject		: 2.6.32.6 hang at boot with ati x1600
Submitter	: Alexey Kuznetsov <ak@axet.ru>
Date		: 2010-01-28 05:02 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15127
Subject		: Bluetooth: sleeping function called from invalid context
Submitter	: David John <davidjon@xenontk.org>
Date		: 2010-01-12 9:19 (20 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D9e726b17422bade75fba94e625cd35fd1353e682
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126328727021949&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15108
Subject		: Blank screen with KMS enabled (on clevo M5xN laptop)
Submitter	: J=C3=A9r=C3=A9my Lal <kapouer@melix.org>
Date		: 2010-01-22 20:30 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15100
Subject		: X11 is black after resume from s2ram if my T400 was previous=
 in docking station before
Submitter	: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
Date		: 2010-01-21 08:56 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc1c7af60892070e4b82ad63bbfb95ae745056de0


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15096
Subject		: Resume lock up -- bisected, commit 3a1151e3f124fd1a2c54b8153=
f510f1a7c715369
Submitter	: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Date		: 2010-01-20 23:15 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D3a1151e3f124fd1a2c54b8153f510f1a7c715369


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15071
Subject		: IBM/Lenovo Trackpoint speed, sensitivity reset after suspend
Submitter	: Marten Vance <kernel@mv.so36.net>
Date		: 2010-01-16 16:19 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15042
Subject		: socket(PF_INET6 hangs when ipv6 not yet initialized
Submitter	: Marc Haber <mh+linux-kernel@zugschlus.de>
Date		: 2010-01-10 14:28 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126313553029280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15021
Subject		: agpgart sometimes fails to initialize sometimes
Submitter	: Maciej Piechotka <uzytkownik2@gmail.com>
Date		: 2010-01-09 23:31 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15015
Subject		: blank screen at random times in laptop when sitting idle
Submitter	: Jithin Emmanuel <jithin1987@gmail.com>
Date		: 2010-01-09 16:48 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15004
Subject		: i915: *ERROR* Execbuf while wedged
Submitter	: tomas m <tmezzadra@gmail.com>
Date		: 2010-01-07 18:53 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15000
Subject		: Thinkpad dock button no longer works
Submitter	: Paul Martin <pm@debian.org>
Date		: 2010-01-07 02:11 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14998
Subject		: Caught 32-bit read from uninitialized memory in acpi_system_=
read_event -- 2.6.31 regression
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-01-06 21:40 (26 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Deca6f534e61919b28fb21aafbd1c2983deae75be


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14997
Subject		: Closing and re-opening the lid does not reactivate the backl=
ight
Submitter	: o. meijer <meijer.o@gmail.com>
Date		: 2010-01-06 15:38 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14943
Subject		: nfs regression?
Submitter	: Nikola Ciprich <extmaillist@linuxbox.cz>
Date		: 2009-12-28 12:10 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126200276223524&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14939
Subject		: drm: random hang with i915
Submitter	: Arnd Bergmann <arnd@arndb.de>
Date		: 2009-12-07 17:30 (56 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126020704125723&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14922
Subject		: 2.6.32 seemed to have broken nVidia MCP7A sata controller
Submitter	: Mike Cui <cuicui@gmail.com>
Date		: 2009-12-19 6:13 (44 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D126120323407742&w=3D4
Handled-By	: Jeff Garzik <jeff@garzik.org>
		  Robert Hancock <hancockrwd@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14898
Subject		: ksoftirqd problem
Submitter	: Nico <segfault2@hotmail.com>
Date		: 2009-12-13 19:05 (50 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126073114325690&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14895
Subject		: BUG in kernel 2.6.32 when using luks encrypted root and RAID=
0..
Submitter	: r4 <mk_4@centrum.cz>
Date		: 2009-12-03 18:24 (60 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986664904751&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14894
Subject		: pohmelfs: NULL pointer dereference
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-12-02 1:11 (61 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125971633107940&w=3D=
4
Handled-By	: Evgeniy Polyakov <zbr@ioremap.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14891
Subject		: Deadlock regression related to NFS root
Submitter	: Stephen R. van den Berg <srb@cuci.nl>
Date		: 2009-11-24 0:24 (69 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125902279909452&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust@netapp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14886
Subject		: Asus P2B-DS not detected as SMP moterboard
Submitter	: Lorenzo Buzzi <flinco@libero.it>
Date		: 2009-12-27 17:20 (36 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De5b8fc6ac158f65598f58dba2c0d52ba3b412f52


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14868
Subject		: flood of "don't try to register things with the same name in=
 the same directory." on upgrade to 2.6.32
Submitter	: Rich Ercolani <rercola@acm.jhu.edu>
Date		: 2009-12-24 02:44 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14817
Subject		: When is system under load, then freeze/HD fail
Submitter	: okias <d.okias@gmail.com>
Date		: 2009-12-15 11:12 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14783
Subject		: Unhandled IRQ on Thinkpad R61i: "irq 16: nobody cared"
Submitter	: Stefan Zegenhagen <sz@emlix.com>
Date		: 2009-12-10 19:14 (53 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14782
Subject		: Suspend hangs Lenovo SL300 after gdm login
Submitter	: Gary Trakhman <gary.trakhman@gmail.com>
Date		: 2009-12-10 18:53 (53 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D03ba3782e8dcc5b0e1efe440d33084f066e38cae


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14748
Subject		: e1000e NIC not working after reboot
Submitter	: Maciek Sitarz <macieks@freesco.pl>
Date		: 2009-12-06 13:04 (57 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742
Subject		: 2.6.32 new menu idle governor causes very high CPU temp
Submitter	:  <akwatts@ymail.com>
Date		: 2009-12-05 17:24 (58 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14695
Subject		: regression in karmic thermal control
Submitter	: Bugie <public@bugie.de>
Date		: 2009-11-26 08:45 (67 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14670
Subject		: i915: playing video via XVideo extension makes the screen fl=
icker
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2009-11-23 13:15 (70 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db42d4c5c6a872815d711e5d51a600f5122c38eee
References	: http://lkml.org/lkml/2010/1/11/150


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14668
Subject		: Resume from disk hangs in acpi_ex_acquire_global_lock
Submitter	: Maxim Levitsky <maximlevitsky@gmail.com>
Date		: 2009-11-22 21:25 (71 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14667
Subject		: bisected 2.6.32 EC regression - Temperatures not correctly d=
etected after suspend - Dell Studio XPS 16 laptop
Submitter	: Federico Chiacchiaretta <federico.chia@gmail.com>
Date		: 2009-11-22 20:42 (71 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D6a63b06f3c494cc87eade97f081300bda60acec7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14657
Subject		: perf subsystem breakage in 2.6.32-rc7
Submitter	: Arjan van de Ven <arjan@infradead.org>
Date		: 2009-11-19 19:50 (74 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125866013419738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14656
Subject		: Oops at __rmqueue+0x98 with 2.6.32-rc6
Submitter	: Lucas C. Villa Real <lucasvr@gobolinux.org>
Date		: 2009-11-19 3:48 (74 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125860255229092&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-11-12 4:58 (81 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2009-11-06 7:38 (87 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi@niif.hu>
Date		: 2009-10-28 23:49 (96 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock@gmail.com>
Date		: 2009-10-23 16:45 (101 days old)
References	: http://lkml.org/lkml/2009/10/23/252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex@digriz.org.uk>
Date		: 2009-10-23 10:30 (101 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2009-10-20 01:52 (104 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm@free.fr>
Date		: 2009-10-17 09:29 (107 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster@gmail.com>
Date		: 2009-10-06 14:38 (118 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-09-30 20:07 (124 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer@pengutronix.de>
Date		: 2009-09-30 15:11 (124 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dba15ab0e8de0d4439a91342ad52d55ca9e313f3d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15197
Subject		: padlock_sha1 and hmac broken?
Submitter	: Wolfgang Walter <wolfgang.walter@stwm.de>
Date		: 2010-01-29 23:44 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126480912924283&w=3D=
4
Handled-By	: Herbert Xu <herbert@gondor.apana.org.au>
Patch		: http://patchwork.kernel.org/patch/75959/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15135
Subject		: Kernel 2.6.32.x hangs during boot process
Submitter	: Fran=C3=A7ois Figarola <francois.figarola@i-consult.fr>
Date		: 2010-01-16 9:58 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126363593817261&w=3D=
4
Handled-By	: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Patch		: http://patchwork.kernel.org/patch/75560/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15134
Subject		: gobi_loader hangs after commit 8e8dce065088
Submitter	: Matthew Garrett <mjg59@srcf.ucam.org>
Date		: 2010-01-17 2:55 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126369696509502&w=3D=
4
Handled-By	: Oliver Neukum <oliver@neukum.org>
		  Alan Cox <alan@lxorguk.ukuu.org.uk>
Patch		: http://patchwork.kernel.org/patch/73878/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15040
Subject		: High cpu temperature with 2.6.32 - bisected to cpuidle menu =
update
Submitter	: Dimitrios Apostolou <jimis@gmx.net>
Date		: 2010-01-06 17:39 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279952723036&w=3D=
4
Handled-By	: Arjan van de Ven <arjan@infradead.org>
Patch		: http://patchwork.kernel.org/patch/71962/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14897
Subject		: i915: Commit 0e442c60 causes flickering
Submitter	: David John <davidjon@xenontk.org>
Date		: 2009-12-09 17:26 (54 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0e442c60dd39ac6924b11a20497734bd2303744c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126037889600769&w=3D=
4
Handled-By	: David John <davidjon@xenontk.org>
Patch		: http://patchwork.kernel.org/patch/75423/


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

