From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.30-rc8-git4: Reported regressions from 2.6.29
Date: Sun,  7 Jun 2009 11:47:31 +0200 (CEST)
Message-ID: <bCxQpon4SCJ.A.RrF.yY7KKB@chimera>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.29, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.29, please let=
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
  2009-06-07      110       35          31
  2009-05-31      100       32          27
  2009-05-24       92       34          27
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13475
Subject		: suspend/hibernate lockdep warning
Submitter	: Dave Young <hidave.darkstar@gmail.com>
Date		: 2009-06-02 10:00 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124393723321241&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13474
Subject		: Oops whilst booting
Submitter	: Chris Clayton <chris2553@googlemail.com>
Date		: 2009-06-06 18:59 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124431487924254&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13473
Subject		: Bug while trying to launch a KVM guest
Submitter	: Sachin Sant <sachinp@in.ibm.com>
Date		: 2009-06-05 17:20 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124422173129047&w=3D=
4
Handled-By	: Mimi Zohar <zohar@us.ibm.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13472
Subject		: Oops with minicom and USB serial
Submitter	: Peter Chubb <peterc@gelato.unsw.edu.au>
Date		: 2009-06-05 1:37 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124416901026700&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13471
Subject		: Loading parport_pc kills the keyboard if ACPI is enabled
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan@pardus.org.tr>
Date		: 2009-06-04 9:12 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124410667532558&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13446
Subject		: resume after suspend-to-ram broken on Toshiba Satellite A100=
 with 2.6.30-rc8 (works in 2.6.28)
Submitter	: Andrea Iob <andrea_iob@yahoo.it>
Date		: 2009-06-03 21:42 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13424
Subject		: possible deadlock when doing governor switching
Submitter	: Shaohua Li <shaohua.li@intel.com>
Date		: 2009-05-31 16:36 (8 days old)
References	: http://www.spinics.net/lists/cpufreq/msg00711.html
Handled-By	: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13408
Subject		: Performance regression in 2.6.30-rc7
Submitter	: Diego Calleja <diegocg@gmail.com>
Date		: 2009-05-30 18:51 (9 days old)
References	: http://lkml.org/lkml/2009/5/30/146


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13407
Subject		: adb trackpad disappears after suspend to ram
Submitter	: Jan Scholz <scholz@fias.uni-frankfurt.de>
Date		: 2009-05-28 7:59 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ed8d2b3a81bdbb0418301628ccdb008ac9f40b7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124349762314976&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13401
Subject		: pktcdvd writing is really slow with CFQ scheduler (bisected)
Submitter	: Laurent Riffard <laurent.riffard@free.fr>
Date		: 2009-05-28 18:43 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13391
Subject		: Kernel boot hangs at about every second start when kms is ac=
tivated
Submitter	: Martin Bammer <mrb74@gmx.at>
Date		: 2009-05-26 21:47 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13374
Subject		: reiserfs blocked for more than 120secs
Submitter	: Harald Dunkel <harald.dunkel@t-online.de>
Date		: 2009-05-23 8:52 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124306880410811&w=3D=
4
		  http://lkml.org/lkml/2009/5/29/389


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13373
Subject		: fbcon, intelfb, i915: INFO: possible circular locking depend=
ency detected
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-05-23 5:08 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124305538130702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13366
Subject		: About 80% of shutdowns fail (blocking)
Submitter	: Martin Bammer <mrb74@gmx.at>
Date		: 2009-05-23 00:58 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13362
Subject		: rt2x00: slow wifi with correct basic rate bitmap
Submitter	: Alejandro Riveira <ariveira@gmail.com>
Date		: 2009-05-22 13:32 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13351
Subject		: 2.6.30 corrupts my system after suspend resume with readonly=
 mounted hard disk
Submitter	:  <unggnu@googlemail.com>
Date		: 2009-05-20 14:09 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78a8b35bc7abf8b8333d6f625e08c0f7cc1c3742
Handled-By	: Yinghai Lu <yinghai@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick@ostenberg.de>
Date		: 2009-05-19 09:08 (20 days old)
Handled-By	: Rusty Russell <rusty@rustcorp.com.au>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13337
Subject		: [post 2.6.29 regression] hang during suspend of b44/b43 modu=
les
Submitter	: Tomas Janousek <tomi@nomi.cz>
Date		: 2009-05-18 10:59 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13330
Subject		: nfs4 NULL pointer dereference in _nfs4_do_setlk
Submitter	: Rich Ercolani <rercola@acm.jhu.edu>
Date		: 2009-05-17 04:44 (22 days old)
Handled-By	: Trond Myklebust <trond.myklebust@fys.uio.no>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro@gmail.com>
Date		: 2009-05-03 16:22 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2009-04-29 21:01 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime@gmx.de>
Date		: 2009-04-30 8:51 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13313
Subject		: vm86old oops
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Date		: 2009-05-14 21:53 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2009-05-14 09:34 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13277
Subject		: 2.6.30 regression - unreliable resume - bisected - Thinkpad =
X40
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2009-05-11 10:08 (28 days old)
Handled-By	: Len Brown <len.brown@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13219
Subject		: Since kernel 2.6.30-rc1, computers hangs randomly ..
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2009-05-01 16:57 (38 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-04-21 21:35 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13179
Subject		: CD-R: wodim intermittent failures
Submitter	: Andy Isaacson <adi@hexapodia.org>
Date		: 2009-04-21 1:52 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124027879214231&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins@novell.com>
Date		: 2009-04-14 21:32 (55 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa@zytor.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13116
Subject		: Can't boot with nosmp
Submitter	: Stephen Hemminger <shemminger@vyatta.com>
Date		: 2009-04-15 4:18 (54 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123976917817920&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista@gmail.com>
Date		: 2009-04-11 14:56 (58 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang@intel.com>
		  Alexey Starikovskiy <astarikovskiy@suse.de>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13470
Subject		: Machine doesn't boot due to mmconfig detection problem
Submitter	: Pascal Terjan <pterjan@mandriva.com>
Date		: 2009-05-29 19:35 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D044cd80942e47b9de0915b627902adf05c52377f
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124388792118481&w=3D=
4
Handled-By	: Yinghai Lu <yinghai@kernel.org>
Patch		: http://patchwork.kernel.org/patch/27613/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13462
Subject		: Unused bands in intefb console and smaller 180x56 -> 128x48
Submitter	: Santi <santi@agolina.net>
Date		: 2009-06-05 16:30 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc9fb15f60eb517c958dec64dca9357bf62bf2201
Handled-By	: Keith Packard <keithp@keithp.com>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D13462#c2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13423
Subject		: JMicron SATA controller not available
Submitter	: Marc Dionne <marc.c.dionne@gmail.com>
Date		: 2009-05-26 22:56 (13 days old)
References	: http://lkml.org/lkml/2009/5/26/687
Handled-By	: Yu Zhao <yu.zhao@intel.com>
Patch		: http://lkml.org/lkml/2009/5/27/402


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13389
Subject		: Warning 'Invalid throttling state, reset' gets displayed whe=
n it should not be
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-05-26 15:24 (13 days old)
Handled-By	: Frans Pop <elendil@planet.nl>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D21671
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21672


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.29,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13070

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
