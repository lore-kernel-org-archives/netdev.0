From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc7: Reported regressions from 2.6.32
Date: Sun,  7 Feb 2010 23:16:11 +0100 (CET)
Message-ID: <4Ht3jFrT7uE.A.JI.-nzbLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpmuinux-foundation.org@ogre.sisk.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:55076 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab0BGWcl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 17:32:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ANNOUNCEMENT:
 Maciej Rutecki has generously volunteered to work on the tracking of k=
ernel
 regressions with me, so now there are two people doing this and I'm go=
ing
 to call us "the tracking team".  Please be friendly to Maciej, he's do=
ing his
 best to help.  If you have any information about kernel regressions yo=
u want
 to share with us, please feel free to contact Maciej as well as me.]

This message contains a list of some regressions from 2.6.32,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.32, please let=
 us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-02-07       97       27          20
  2010-02-01       85       26          21
  2010-01-24       75       29          23
  2010-01-10       55       33          21
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15246
Subject		: BUG: Bad page state in process portageq
Submitter	: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Date		: 2010-02-07 0:45 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126550356515887&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15245
Subject		: [2.6.33-rc6 fc76be4 w/ drm-radon-testing and KMS enabled] We=
ird JCPU times?
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2010-02-06 7:24 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126544107816889&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15207
Subject		: Pineview - only cursor on black screen visible, "GPU hung" i=
n dmesg
Submitter	: Christian Friedemann <dawn2k@gmail.com>
Date		: 2010-02-01 20:15 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15202
Subject		: lockdep warning during elevator_switch
Submitter	: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Date		: 2010-01-31 23:55 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126498212613051&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15200
Subject		: NFS problems in 2.6.33-rc6: Unknown error 526
Submitter	: J.A. Magall=C3=B3n <jamagallon@ono.com>
Date		: 2010-01-31 22:46 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126497800408928&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15199
Subject		: sata_nv and no /dev files
Submitter	: Bart=C5=82omiej Zimo=C5=84 <uzi18@o2.pl>
Date		: 2010-01-31 23:45 (8 days old)
Message-ID	: <1f9bac08.1a5266d6.4b66012a.5a11a@o2.pl>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126498153112488&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15192
Subject		: netperf ~50% regression with 2.6.33-rc1, bisect to 1b9508f
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2010-01-25 10:03 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/1b9508f6831e10d5325=
6825de8904caa22d1ca2c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126441481427331&w=3D=
4
Handled-By	: Mike Galbraith <efault@gmx.de>
		  Peter Zijlstra <peterz@infradead.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15177
Subject		: Asynchronous writes up to 30% slower than in previous kernel=
 versions
Submitter	: Bart Van Assche <bart.vanassche@gmail.com>
Date		: 2010-01-30 16:38 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15142
Subject		: sysfs-related lockdep warning in __blkdev_get
Submitter	: Matti Aarnio <matti.aarnio--kernel-bugzilla@zmailer.org>
Date		: 2010-01-25 13:38 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15139
Subject		: e1000: transmit queue 0 timed out
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-01-23 15:37 (16 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126426149306083&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15114
Subject		: X.org hang with [drm:i915_gem_do_execbuffer] *ERROR* in dmes=
g
Submitter	: Matej Laitl <strohel@gmail.com>
Date		: 2010-01-23 19:54 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15076
Subject		: System panic under load with clockevents_program_event
Submitter	: okias <d.okias@gmail.com>
Date		: 2010-01-17 13:03 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15044
Subject		: Much higher wakeups for "<kernel IPI> : Rescheduling interru=
pts" since 2.6.32.2
Submitter	: Roman Mamedov <roman@rm.pp.ru>
Date		: 2010-01-11 02:58 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15043
Subject		: Display goes off with i915.powersave=3D1 after suspend-resum=
e
Submitter	: Soeren Sonnenburg <sonne@debian.org>
Date		: 2010-01-10 20:09 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126315457519505&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15036
Subject		: soft lockup in dmesg after suspend/resume
Submitter	: ykzhao <yakui.zhao@intel.com>
Date		: 2010-01-04 5:36 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126258356202722&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15025
Subject		: Oops in ext4 driver
Submitter	: Steinar H. Gunderson <sgunderson@bigfoot.com>
Date		: 2010-01-10 13:09 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14999
Subject		: possible circular locking dependency detected in rfkill at s=
uspend
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-01-06 21:52 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-12-25 11:11 (45 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:35 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi@agolina.net>
Date		: 2009-12-12 13:28 (58 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/27dfaf4f5825a119305=
db1bc63bef30ed400e376
Handled-By	: Zhao Yakui <yakui.zhao@intel.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15251
Subject		: ioctl32(mdadm:2243): Unknown cmd fd(3) cmd(800c0910){t:09;sz=
:12} arg(ffb7f9c4)
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2010-01-30 22:02 (9 days old)
Message-ID	: <201001302302.10574.arnd@arndb.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126489038709553&w=3D=
4
Handled-By	: Arnd Bergmann <arnd@arndb.de>
Patch		: http://patchwork.kernel.org/patch/75931/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15250
Subject		: "drm/i915: implement new pm ops" disables irq on aborted s2d=
isk
Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date		: 2010-02-03 03:18 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/cbda12d77ea590082ed=
b6d30bd342a67ebc459e0
Message-ID	: <4B695BA0.4000007@tuffmail.co.uk>
References	: https://lists.linux-foundation.org/pipermail/linux-pm/2010=
-February/024200.html
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://patchwork.kernel.org/patch/77640/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15244
Subject		: PROBLEM: hda-intel divide by zero kernel crash in azx_positi=
on_ok()
Submitter	: Jody Bruchon <jody@nctritech.com>
Date		: 2010-02-06 0:32 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126541276028173&w=3D=
2
Handled-By	: Takashi Iwai <tiwai@suse.de>
		  Jody Bruchon <jody@nctritech.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D126547145614070&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15196
Subject		: kmem_cache_create: duplicate cache ccid2_h
Submitter	: Heinz Diehl <htd@fancy-poultry.org>
Date		: 2010-01-30 18:33 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126487640324942&w=3D=
4
Handled-By	: Xiaotian Feng <xtfeng@gmail.com>
Patch		: http://patchwork.kernel.org/patch/77601/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15195
Subject		: kernel BUG at include/net/netns/generic.h:41, pfkey_create+0=
x36/0x18b [af_key]
Submitter	: Luca Tettamanti <kronos.it@gmail.com>
Date		: 2010-01-30 13:23 (9 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126485785004775&w=3D=
4
Handled-By	: Alexey Dobriyan <adobriyan@gmail.com>
Patch		: http://patchwork.kernel.org/patch/75891/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15039
Subject		: leds_alix2: can't allocate I/O for GPIO
Submitter	: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date		: 2010-01-07 10:26 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126286001106257&w=3D=
4
Handled-By	: Daniel Mack <daniel@caiaq.de>
Patch		: http://patchwork.kernel.org/patch/72006/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14949
Subject		: drm_vm.c:drm_mmap: possible circular locking dependency dete=
cted
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:45 (44 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182073616279&w=3D=
4
Handled-By	: Eric W. Biederman <ebiederm@aristanetworks.com>
Patch		: http://patchwork.kernel.org/patch/70461/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.32,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14885

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

