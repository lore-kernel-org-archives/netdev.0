From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.33-rc5: Reported regressions 2.6.31 -> 2.6.32
Date: Sun, 24 Jan 2010 23:15:02 +0100 (CET)
Message-ID: <pYFNu11z2aM.A.pJH.CZMXLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * This is worrisome.  Regressions from 2.6.31 are still being reported=
 and we
   are not fixing them.  Even the ones that have been bisected don't se=
em to
   be taken care of.]

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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15135
Subject		: Kernel 2.6.32.x hangs during boot process
Submitter	: Fran=C3=A7ois Figarola <francois.figarola-lUrpeit6/WqB4Ue4x7It+g@public.gmane.org>
Date		: 2010-01-16 9:58 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126363593817261&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15127
Subject		: Bluetooth: sleeping function called from invalid context
Submitter	: David John <davidjon-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
Date		: 2010-01-12 9:19 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D9e726b17422bade75fba94e625cd35fd1353e682
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126328727021949&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15096
Subject		: Resume lock up -- bisected, commit 3a1151e3f124fd1a2c54b8153=
f510f1a7c715369
Submitter	: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-20 23:15 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15071
Subject		: IBM/Lenovo Trackpoint speed, sensitivity reset after suspend=
 if set via sysfs
Submitter	: Marten Vance <kernel-srgEi2D3yJHR7s880joybQ@public.gmane.org>
Date		: 2010-01-16 16:19 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15042
Subject		: socket(PF_INET6 hangs when ipv6 not yet initialized
Submitter	: Marc Haber <mh+linux-kernel-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org>
Date		: 2010-01-10 14:28 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126313553029280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15021
Subject		: agpgart sometimes fails to initialize sometimes
Submitter	: Maciej Piechotka <uzytkownik2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-09 23:31 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15015
Subject		: blank screen at random times in laptop when sitting idle
Submitter	: Jithin Emmanuel <jithin1987-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-09 16:48 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15004
Subject		: i915: *ERROR* Execbuf while wedged
Submitter	: tomas m <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-07 18:53 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14998
Subject		: Caught 32-bit read from uninitialized memory in acpi_system_=
read_event
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-01-06 21:40 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14997
Subject		: Closing and re-opening the lid does not reactivate the backl=
ight
Submitter	: o. meijer <meijer.o-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-06 15:38 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14943
Subject		: nfs regression?
Submitter	: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date		: 2009-12-28 12:10 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126200276223524&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14939
Subject		: drm: random hang with i915
Submitter	: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date		: 2009-12-07 17:30 (49 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126020704125723&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14933
Subject		: OOM killer unexpectedly called
Submitter	: A. Boulan <arnaud.boulan-TDf4sKD1mxeHlu7OokbhRg@public.gmane.org>
Date		: 2009-12-24 23:42 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126169821317492&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14922
Subject		: 2.6.32 seemed to have broken nVidia MCP7A sata controller
Submitter	: Mike Cui <cuicui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-19 6:13 (37 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D126120323407742&w=3D4
Handled-By	: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
		  Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14898
Subject		: ksoftirqd problem
Submitter	: Nico <segfault2-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-12-13 19:05 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126073114325690&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14897
Subject		: i915: Commit 0e442c60 causes flickering
Submitter	: David John <davidjon-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
Date		: 2009-12-09 17:26 (47 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0e442c60dd39ac6924b11a20497734bd2303744c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126037889600769&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14895
Subject		: BUG in kernel 2.6.32 when using luks encrypted root and RAID=
0..
Submitter	: r4 <mk_4-aRb0bU7PRFPrBKCeMvbIDA@public.gmane.org>
Date		: 2009-12-03 18:24 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986664904751&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14894
Subject		: pohmelfs: NULL pointer dereference
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-02 1:11 (54 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125971633107940&w=3D=
4
Handled-By	: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14891
Subject		: Deadlock regression related to NFS root
Submitter	: Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org>
Date		: 2009-11-24 0:24 (62 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125902279909452&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14886
Subject		: Asus P2B-DS not detected as SMP moterboard
Submitter	: Lorenzo Buzzi <flinco-VGgt2q2+T+FeoWH0uzbU5w@public.gmane.org>
Date		: 2009-12-27 17:20 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14868
Subject		: flood of "don't try to register things with the same name in=
 the same directory." on upgrade to 2.6.32
Submitter	: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>
Date		: 2009-12-24 02:44 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14817
Subject		: When is system under load, then freeze/HD fail
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-15 11:12 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14783
Subject		: Unhandled IRQ on Thinkpad R61i: "irq 16: nobody cared"
Submitter	: Stefan Zegenhagen <sz-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-10 19:14 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14782
Subject		: Suspend hangs Lenovo SL300 after gdm login
Submitter	: Gary Trakhman <gary.trakhman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-10 18:53 (46 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D03ba3782e8dcc5b0e1efe440d33084f066e38cae


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14748
Subject		: e1000e NIC not working after reboot
Submitter	: Maciek Sitarz <macieks-yngNwrTfnRnVItvQsEIGlw@public.gmane.org>
Date		: 2009-12-06 13:04 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742
Subject		: 2.6.32 new menu idle governor causes very high CPU temp
Submitter	:  <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-05 17:24 (51 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14695
Subject		: regression in karmic thermal control
Submitter	: Bugie <public-ZA6dAAr5zYM@public.gmane.org>
Date		: 2009-11-26 08:45 (60 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14670
Subject		: i915: playing video via XVideo extension makes the screen fl=
icker
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2009-11-23 13:15 (63 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db42d4c5c6a872815d711e5d51a600f5122c38eee
References	: http://lkml.org/lkml/2010/1/11/150


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14667
Subject		: bisected 2.6.32 EC regression - Temperatures not correctly d=
etected after suspend - Dell Studio XPS 16 laptop
Submitter	: Federico Chiacchiaretta <federico.chia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-22 20:42 (64 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14657
Subject		: perf subsystem breakage in 2.6.32-rc7
Submitter	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date		: 2009-11-19 19:50 (67 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125866013419738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14656
Subject		: Oops at __rmqueue+0x98 with 2.6.32-rc6
Submitter	: Lucas C. Villa Real <lucasvr-9gmU7qdNRpmhPH1hqNUYSQ@public.gmane.org>
Date		: 2009-11-19 3:48 (67 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125860255229092&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14625
Subject		: Commit d451564 breaks ARM
Submitter	: Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Date		: 2009-11-13 15:11 (73 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd4515646699b6ad7b1a98ceb871296b957f3ef47
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125812520315835&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-12 4:58 (74 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-11-06 7:38 (80 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-10-28 23:49 (89 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-23 16:45 (94 days old)
References	: http://lkml.org/lkml/2009/10/23/252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex-L4GPcECwBoDe9xe1eoZjHA@public.gmane.org>
Date		: 2009-10-23 10:30 (94 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-10-20 01:52 (97 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm-GANU6spQydw@public.gmane.org>
Date		: 2009-10-17 09:29 (100 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14417
Subject		: [Regression] Wireless driver iwlagn+iwlcore doesn't work aft=
er resume (needs reloading)
Submitter	: Eddy Petri=C8=99or <eddy.petrisor+linbug-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-16 11:07 (101 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-06 14:38 (111 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 20:07 (117 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date		: 2009-09-30 15:11 (117 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15134
Subject		: gobi_loader hangs after commit 8e8dce065088
Submitter	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Date		: 2010-01-17 2:55 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126369696509502&w=3D=
4
Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
		  Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/73878/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15040
Subject		: High cpu temperature with 2.6.32
Submitter	: Dimitrios Apostolou <jimis-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-01-06 17:39 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279952723036&w=3D=
4
Handled-By	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/71962/


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
