From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.34-rc2: Reported regressions 2.6.32 -> 2.6.33
Date: Sun, 21 Mar 2010 21:27:25 +0100 (CET)
Message-ID: <QQGfxbJf48H.A.NFD.uNopLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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

[NOTE:
 Well, we seem to have two reports that are almost 2 months old and wit=
h
 patches.  Somebody care to push those patches to Linus or say why they
 are invalid, pretty please?]

This message contains a list of some post-2.6.32 regressions introduced=
 before
2.6.33, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.32 regressions, please let=
 us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-03-21      133       38          34
  2010-02-21      115       34          27
  2010-02-15      112       34          31
  2010-02-07       97       27          20
  2010-02-01       85       26          21
  2010-01-24       75       29          23
  2010-01-10       55       33          21
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15585
Subject		: [Bisected Regression in 2.6.32.8] i915 with KMS enabled caus=
es memorycorruption when resuming from suspend-to-disk
Submitter	: M. Vefa Bicakci <bicave@superonline.com>
Date		: 2010-03-13 5:11 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/d8e0902806c0bd2ccc4=
f6a267ff52565a3ec933b
Message-ID	: <4B9B1E8F.5090806@superonline.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126845754409543&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15544
Subject		: black screen upon S3 resume, syslog has "render error" and "=
page table error"
Submitter	: Sanjoy Mahajan <sanjoy@mit.edu>
Date		: 2010-03-16 00:45 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15534
Subject		: 07ca:b808 crashing and breaking usb's
Submitter	: Alex Fiestas <alex@eyeos.org>
Date		: 2010-03-14 15:56 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15527
Subject		: [BUG] NULL pointer dereference in i915_gem_object_save_bit_1=
7_swizzle
Submitter	: Justin Madru <jdm64@gawab.com>
Date		: 2010-03-04 9:00 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/280b713b5b0fd84cf24=
69098aee88acbb5de859c
Message-ID	: <20100304090047.23689.qmail@info88.gawab.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126769366716380&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15525
Subject		: Blank screen after some time, after hibernation/suspend
Submitter	:  <capsel@matrix.inten.pl>
Date		: 2010-03-12 17:24 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15502
Subject		: render error detected, EIR: 0x00000010
Submitter	: Artem Anisimov <aanisimov@inbox.ru>
Date		: 2010-03-10 05:45 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15494
Subject		: BUG: key ffff88013d4f4c70 not in .data! when loading microco=
de.ko
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-03-09 16:28 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15474
Subject		: r8169 fails to bring up ethernet
Submitter	: Matteo <rootkit85@yahoo.it>
Date		: 2010-03-07 23:57 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/ac1aa47b131416a6ff3=
7eb1005a0a1d2541aad6c
Handled-By	: Francois Romieu <romieu@fr.zoreil.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15466
Subject		: 2.6.33 dies on modprobe
Submitter	: M G Berberich <berberic@fmi.uni-passau.de>
Date		: 2010-02-28 22:12 (22 days old)
Message-ID	: <20100228221257.GA8858@invalid>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126739570819208&w=3D=
2
Handled-By	: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15465
Subject		: 2.6.33 problems
Submitter	: werner@guyane.dyn-o-saur.com
Date		: 2010-02-27 17:09 (23 days old)
Message-ID	: <1267290551.13148@guyane.dyn-o-saur.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126729183719672&w=3D=
2
Handled-By	: Tejun Heo <tj@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15454
Subject		: r8169 exits with error -22 since 2.6.33
Submitter	: Conrad Kostecki <ConiKost@gmx.de>
Date		: 2010-03-05 22:32 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15439
Subject		: Laptop does consume more power when booted "cold" -- Thinkpa=
d X200s
Submitter	:  <johannes.schlatow@googlemail.com>
Date		: 2010-03-03 23:09 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15418
Subject		: battery status info broken; missing entry in ec_dmi_table fo=
r specific MSI hardware (notebook)
Submitter	: Tom-Steve Watzke <tswatzke@arcor.de>
Date		: 2010-03-01 07:25 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15392
Subject		: The kernel does not start up.
Submitter	: Krist=C3=B3f Ralovich <kristof.ralovich@gmail.com>
Date		: 2010-02-25 06:52 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15376
Subject		: regression (oops) with usb in 2.6.33-rc8
Submitter	: Christophe Fergeau <cfergeau@mandriva.com>
Date		: 2010-02-23 10:58 (27 days old)
Handled-By	: Sarah Sharp <sarah.a.sharp@linux.intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15319
Subject		: [BUG]: Possibe recursive locking detected in sysfs
Submitter	: John Kacur <jkacur@redhat.com>
Date		: 2010-02-11 17:11 (39 days old)
Message-ID	: <520f0cf11002110911t3f125649v73062e9851e2cfb3@mail.gmail.c=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126590832432598&w=3D=
2
Handled-By	: Eric Biederman <ebiederm@aristanetworks.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15317
Subject		: Lockdep report while running aplay with pulse as the default
Submitter	: Ed Tomlinson <edt@aei.ca>
Date		: 2010-02-13 17:17 (37 days old)
Message-ID	: <201002131217.10579.edt@aei.ca>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126608146427546&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15311
Subject		: Starting pulseaudio causes a NULL pointer hit
Submitter	: Ed Tomlinson <edt@aei.ca>
Date		: 2010-02-14 23:41 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15305
Subject		: Dell video dies when booting
Submitter	: David Ronis <ronis@ronispc.chem.mcgill.ca>
Date		: 2010-02-14 1:07 (36 days old)
Message-ID	: <1266109622.11290.10.camel@montroll.chem.mcgill.ca>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126611098225127&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15278
Subject		: lockdep warning for iscsi in 2.6.33-rc6
Submitter	: Tao Ma <tao.ma@oracle.com>
Date		: 2010-02-09 6:59 (41 days old)
Message-ID	: <4B7107CF.3060703@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126569884330200&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15277
Subject		: 2.6.33-rc6 crashes on resume
Submitter	: Bill Davidsen <davidsen@roadwarrior3.tmr.com>
Date		: 2010-02-08 23:03 (42 days old)
Message-ID	: <4B70982F.8090208@roadwarrior3.tmr.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126567021801935&w=3D=
2
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15276
Subject		: latest git kernel: general protection fault: 0000 [#1]
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2010-02-09 8:36 (41 days old)
Message-ID	: <20100209083605.GA1766@arch.tripp.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126570498804223&w=3D=
2
Handled-By	: J=C3=A9r=C3=B4me Glisse <glisse@freedesktop.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15259
Subject		: Corruption with OpenGL since Intel's big DRM push on i945
Submitter	: Alexandre Demers <papouta@hotmail.com>
Date		: 2010-02-08 13:19 (42 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/76446cac68568fc7f51=
68a27deaf803ed22a4360


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15246
Subject		: BUG: Bad page state in process portageq
Submitter	: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Date		: 2010-02-07 0:45 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126550356515887&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15245
Subject		: [2.6.33-rc6 Weird JCPU times?
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2010-02-06 7:24 (44 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126544107816889&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15244
Subject		: PROBLEM: hda-intel divide by zero kernel crash in azx_positi=
on_ok()
Submitter	: Jody Bruchon <jody@nctritech.com>
Date		: 2010-02-06 0:32 (44 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126541276028173&w=3D=
2
Handled-By	: Takashi Iwai <tiwai@suse.de>
		  Jody Bruchon <jody@nctritech.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15202
Subject		: lockdep warning during elevator_switch
Submitter	: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Date		: 2010-01-31 23:55 (50 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126498212613051&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15200
Subject		: NFS problems in 2.6.33-rc6: Unknown error 526
Submitter	: J.A. Magall=C3=B3n <jamagallon@ono.com>
Date		: 2010-01-31 22:46 (50 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126497800408928&w=3D=
4
Handled-By	: Bruce Fields <bfields@fieldses.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15139
Subject		: e1000: transmit queue 0 timed out
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-01-23 15:37 (58 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126426149306083&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15076
Subject		: System panic under load with clockevents_program_event
Submitter	: okias <d.okias@gmail.com>
Date		: 2010-01-17 13:03 (64 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15036
Subject		: soft lockup in dmesg after suspend/resume
Submitter	: ykzhao <yakui.zhao@intel.com>
Date		: 2010-01-04 5:36 (77 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126258356202722&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-12-25 11:11 (87 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:35 (85 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi@agolina.net>
Date		: 2009-12-12 13:28 (100 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/27dfaf4f5825a119305=
db1bc63bef30ed400e376
Handled-By	: Zhao Yakui <yakui.zhao@intel.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15328
Subject		: high load avg, extreme sluggishness on T41 w/ Radeon Mobilit=
y M7
Submitter	: John W. Linville <linville@tuxdriver.com>
Date		: 2010-02-16 20:25 (34 days old)
Handled-By	: Francisco Jerez <currojerez@riseup.net>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D25118


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15287
Subject		: RadeonKMS segfaults kdm on mobility radeon x700 pcie
Submitter	: Jan Kreuzer <kontrollator@gmx.de>
Date		: 2010-02-12 17:58 (38 days old)
Handled-By	: Matthew Wilcox <matthew@wil.cx>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D25483


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15192
Subject		: netperf ~50% regression with 2.6.33-rc1, bisect to 1b9508f
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2010-01-25 10:03 (56 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/1b9508f6831e10d5325=
6825de8904caa22d1ca2c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126441481427331&w=3D=
4
Handled-By	: Mike Galbraith <efault@gmx.de>
		  Peter Zijlstra <peterz@infradead.org>
		  Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
Patch		: http://patchwork.kernel.org/patch/78544/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15142
Subject		: sysfs-related lockdep warning in __blkdev_get
Submitter	: Matti Aarnio <matti.aarnio--kernel-bugzilla@zmailer.org>
Date		: 2010-01-25 13:38 (56 days old)
Handled-By	: NeilBrown <neilb@suse.de>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D25085


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.32 and 2.6.33, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14885

Please let the tracking teak know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
