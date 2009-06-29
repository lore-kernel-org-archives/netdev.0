From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc1-git3: Reported regressions 2.6.29 -> 2.6.30
Date: Mon, 29 Jun 2009 02:26:46 +0200 (CEST)
Message-ID: <etTXaRqGgAC.A.SaE.6iASKB@chimera>
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
 * I hope you notice the jump of the number of reported regressions aft=
er 2.6.30
   was released.
 * Please let me know which of these bugs have been fixed already (idea=
lly
   please also provide the name of the fix commit).
 * The post-2.6.30 reports were flooded by the megre window noise that =
made
   them very difficult to track.]

This message contains a list of some regressions introduced between 2.6=
=2E29 and
2.6.30, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
29
and 2.6.30, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-06-29      133       46          43
  2009-06-07      110       35          31
  2009-05-31      100       32          27
  2009-05-24       92       34          27
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13669
Subject		: Kernel bug with dock driver
Submitter	: Joerg Platte <jplatte-v18Uk5sXZWJeoWH0uzbU5w@public.gmane.org>
Date		: 2009-06-14 21:00 (15 days old)
References	: http://lkml.org/lkml/2009/6/14/216
Handled-By	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13668
Subject		: Can't boot 2.6.30 powerpc kernel under qemu.
Submitter	: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Date		: 2009-06-27 18:08 (2 days old)
References	: http://lkml.org/lkml/2009/6/27/159


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13660
Subject		: Crashes during boot on 2.6.30 / 2.6.31-rc, random programs
Submitter	: Joao Correia <joaomiguelcorreia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-27 16:07 (2 days old)
References	: http://lkml.org/lkml/2009/6/27/95


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13651
Subject		: Anyone know what happened with PC speaker in 2.6.30?
Submitter	: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Date		: 2009-06-15 14:41 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124507695427817&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13649
Subject		: Bad page state in process with various applications
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-20 15:27 (9 days old)
References	: http://marc.info/?l=3Dlinux-mm&m=3D124551168828090&w=3D4
Handled-By	: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13648
Subject		: nfsd: page allocation failure
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2009-06-22 12:08 (7 days old)
References	: http://lkml.org/lkml/2009/6/22/309


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13647
Subject		: fb/mmap lockdep report.
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-06-21 13:33 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D513adb58685615b0b1d47a3f0d40f5352beff189
References	: http://lkml.org/lkml/2009/6/21/90
		  http://lkml.org/lkml/2009/6/21/122


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13646
Subject		: warn_on tty_io.c, broken bluetooth
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-06-19 17:05 (10 days old)
References	: http://lkml.org/lkml/2009/6/19/187


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13644
Subject		: hibernation/swsusp lockup due to acpi-cpufreq
Submitter	: Johannes Stezenbach <js-FF7aIK3TAVNeoWH0uzbU5w@public.gmane.org>
Date		: 2009-06-16 01:27 (13 days old)
References	: http://lkml.org/lkml/2009/6/15/630
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13634
Subject		: [drm:drm_wait_vblank] failed to acquire vblank counter
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml-VIXq6x/3rUk@public.gmane.org>
Date		: 2009-06-27 07:02 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13624
Subject		: usb: wrong autosuspend initialization
Submitter	:  <list-2tUql6aCh3Vfq8cQ1yknNg@public.gmane.org>
Date		: 2009-06-25 18:18 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13621
Subject		: xfs hangs with assertion failed
Submitter	: Johannes Engel <jcnengel-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-06-25 10:07 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13620
Subject		: acpi_enforce_resources broken - conflicting i2c module loade=
d on some EeePCs
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-06-25 08:31 (4 days old)
References	: <http://lists.alioth.debian.org/pipermail/debian-eeepc-dev=
el/2009-June/002316.html>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13613
Subject		: lockups with JFS (inconsistent lock state)
Submitter	: Jan &quot;Yenya&quot; Kasprzak <kas-0hYGf3jDe+XrBKCeMvbIDA@public.gmane.org>
Date		: 2009-06-24 09:35 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13581
Subject		: ath9k doesn't work with newer kernels
Submitter	: Matteo <rootkit85-whZMOeQn8C0@public.gmane.org>
Date		: 2009-06-19 12:04 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13558
Subject		: Tracelog during resume
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml-VIXq6x/3rUk@public.gmane.org>
Date		: 2009-06-17 11:32 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13554
Subject		: linux-image-2.6.30-1-686, KMS enabled: black screen, no X wi=
ndow
Submitter	: Jos van Wolput <wolput-kN7GrHn7egj0B9fh5IxImPP6llvjuJOh@public.gmane.org>
Date		: 2009-06-17 06:28 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13528
Subject		: au0828: major drop in reception quality between 2.6.29.4 and=
 2.6.30 on HVR-950q
Submitter	: Jim Faulkner <jfaulkne-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>
Date		: 2009-06-13 19:34 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13518
Subject		: slab grows with NFS write activity.
Submitter	: Andrew Randrianasulu <randrik-JGs/UdohzUI@public.gmane.org>
Date		: 2009-06-12 09:51 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13514
Subject		: acer_wmi causes stack corruption
Submitter	: Rus <harbour-K87ZgELTUEPsG83rWm+8vg@public.gmane.org>
Date		: 2009-06-12 08:13 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13512
Subject		: D43 on 2.6.30 doesn't suspend anymore
Submitter	: Daniel Smolik <marvin-0pWKB23IDFjrBKCeMvbIDA@public.gmane.org>
Date		: 2009-06-11 20:12 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13502
Subject		: GPE storm causes polling mode, which causes /proc/acpi/batte=
ry read to take 4 seconds - MacBookPro4,1
Submitter	:  <sveina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-10 20:04 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13472
Subject		: Oops with minicom and USB serial
Submitter	: Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Date		: 2009-06-05 1:37 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124416901026700&w=3D=
4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13471
Subject		: Loading parport_pc kills the keyboard if ACPI is enabled
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Date		: 2009-06-04 9:12 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124410667532558&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13424
Subject		: possible deadlock when doing governor switching
Submitter	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-31 16:36 (29 days old)
References	: http://www.spinics.net/lists/cpufreq/msg00711.html
Handled-By	: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13408
Subject		: Performance regression in 2.6.30-rc7
Submitter	: Diego Calleja <diegocg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-30 18:51 (30 days old)
References	: http://lkml.org/lkml/2009/5/30/146


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13407
Subject		: adb trackpad disappears after suspend to ram
Submitter	: Jan Scholz <scholz-wOpdxP1gw6Cc+IqHO83+wjjhTm2NLCe8@public.gmane.org>
Date		: 2009-05-28 7:59 (32 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ed8d2b3a81bdbb0418301628ccdb008ac9f40b7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124349762314976&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13401
Subject		: pktcdvd writing is really slow with CFQ scheduler (bisected)
Submitter	: Laurent Riffard <laurent.riffard-GANU6spQydw@public.gmane.org>
Date		: 2009-05-28 18:43 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13374
Subject		: reiserfs blocked for more than 120secs
Submitter	: Harald Dunkel <harald.dunkel-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2009-05-23 8:52 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124306880410811&w=3D=
4
		  http://lkml.org/lkml/2009/5/29/389


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13373
Subject		: fbcon, intelfb, i915: INFO: possible circular locking depend=
ency detected
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-23 5:08 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124305538130702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13362
Subject		: rt2x00: slow wifi with correct basic rate bitmap
Submitter	: Alejandro Riveira <ariveira-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-22 13:32 (38 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13351
Subject		: 2.6.30 corrupts my system after suspend resume with readonly=
 mounted hard disk
Submitter	:  <unggnu-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-05-20 14:09 (40 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78a8b35bc7abf8b8333d6f625e08c0f7cc1c3742
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick-nxAOmsU53hB6lmGzAMPh1A@public.gmane.org>
Date		: 2009-05-19 09:08 (41 days old)
Handled-By	: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13337
Subject		: [post 2.6.29 regression] hang during suspend of b44/b43 modu=
les
Submitter	: Tomas Janousek <tomi-YoqI/XImC7s@public.gmane.org>
Date		: 2009-05-18 10:59 (42 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-03 16:22 (57 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2009-04-29 21:01 (61 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
		  http://lkml.org/lkml/2009/6/7/136
Handled-By	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-30 8:51 (60 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2009-05-14 09:34 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13277
Subject		: 2.6.30 regression - hang on 2nd resume - bisected - Thinkpad=
 X40
Submitter	: Daniel Vetter <daniel-/w4YWyX8dFk@public.gmane.org>
Date		: 2009-05-11 10:08 (49 days old)
Handled-By	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13219
Subject		: Intel 440GX: Since kernel 2.6.30-rc1, computers hangs random=
ly but not with kernel <=3D 2.6.29.4
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2009-05-01 16:57 (59 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13179
Subject		: CD-R: wodim intermittent failures
Submitter	: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2009-04-21 1:52 (69 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124027879214231&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-14 21:32 (76 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-11 14:56 (79 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
		  Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13663
Subject		: suspend to ram regression (IDE related)
Submitter	: Etienne Basset <etienne.basset-Bf/eaXMDFuuXqB7oj33eUg@public.gmane.org>
Date		: 2009-06-26 17:40 (3 days old)
References	: http://lkml.org/lkml/2009/6/26/242
Handled-By	: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/32719/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13475
Subject		: suspend/hibernate lockdep warning
Submitter	: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-02 10:00 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124393723321241&w=3D=
4
Handled-By	: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/28660/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13389
Subject		: Warning 'Invalid throttling state, reset' gets displayed whe=
n it should not be
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-05-26 15:24 (34 days old)
Handled-By	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D21671
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21672


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.29 and 2.6.30, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13070

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
