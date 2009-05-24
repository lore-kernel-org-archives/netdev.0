From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.30-rc7: Reported regressions from 2.6.29
Date: Sun, 24 May 2009 21:06:06 +0200 (CEST)
Message-ID: <ZPPBiNHr1LC.A.9ZH.K9bGKB@chimera>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:34106 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936AbZEXWBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 18:01:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NOTE:
 Bug entries for which I know there are working patches get the
 RESOLVED / PATCH_ALREADY_AVAILABLE status in the Bugzilla, which
 makes it easier to check if the patches have been merged before sendin=
g
 out the list.  For this reason, please let me know of working patches
 for any of the regression list items or (better) change the status of =
the bug
 entries in case you know of a working patch (in which case please also=
 add
 a link to the patch to the appropriate bug entry).]

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
  2009-05-24       92       34          27
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13377
Subject		: Microphone no longer works on Toshiba Satellite A100
Submitter	: M. Vefa Bicakci <bicave@superonline.com>
Date		: 2009-05-24 15:49 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D23f0c048ba59ad5c2f3fd85ed98360b631dbf6f8
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124318383910011&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13374
Subject		: reiserfs blocked for more than 120secs
Submitter	: Harald Dunkel <harald.dunkel@t-online.de>
Date		: 2009-05-23 8:52 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124306880410811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13373
Subject		: fbcon, intelfb, i915: INFO: possible circular locking depend=
ency detected
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-05-23 5:08 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124305538130702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13372
Subject		: Oops in usb-serial with keyspan adapter
Submitter	: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date		: 2009-05-18 0:07 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124260532924736&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13366
Subject		: About 80% of shutdowns fail (blocking)
Submitter	: Martin Bammer <mrb74@gmx.at>
Date		: 2009-05-23 00:58 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick@ostenberg.de>
Date		: 2009-05-19 09:08 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
Subject		: rtable leak in ipv4/route.c
Submitter	: Alexander V. Lukyanov <lav@yar.ru>
Date		: 2009-05-18 14:10 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13337
Subject		: [post 2.6.29 regression] hang during suspend of b44/b43 modu=
les
Submitter	: Tomas Janousek <tomi@nomi.cz>
Date		: 2009-05-18 10:59 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13331
Subject		: FUTEX_LOCK_PI kills kernel
Submitter	: Andreas Schwab <schwab@linux-m68k.org>
Date		: 2009-05-17 09:51 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13330
Subject		: nfs4 NULL pointer dereference in _nfs4_do_setlk
Submitter	: Rich Ercolani <rercola@acm.jhu.edu>
Date		: 2009-05-17 04:44 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro@gmail.com>
Date		: 2009-05-03 16:22 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13326
Subject		: [PATCH]Null pointer dereference in rtc-cmos driver
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan@pardus.org.tr>
Date		: 2009-05-14 16:16 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231783704696&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13325
Subject		: 2.6.30-rc kills my box hard - and lockdep chains
Submitter	: Jonathan Corbet <corbet@lwn.net>
Date		: 2009-05-14 15:49 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231630701394&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13323
Subject		: 2.6.30-rc deadline scheduler performance regression for iozo=
ne over NFS
Submitter	: Jeff Moyer <jmoyer@redhat.com>
Date		: 2009-04-23 14:01 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124049547915450&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2009-04-29 21:01 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime@gmx.de>
Date		: 2009-04-30 8:51 (25 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2009-05-14 09:34 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13285
Subject		: INTELFB: Colors display incorrectly
Submitter	: Dean Menezes <samanddeanus@yahoo.com>
Date		: 2009-05-12 01:40 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13250
Subject		: Side channel of Intel HDA chip doesn't work anymore, did wor=
k with 2.6.29
Submitter	: Andreas Juch <kernel-bt@juch.cc>
Date		: 2009-05-05 10:14 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13219
Subject		: Since kernel 2.6.30-rc1, computers hangs randomly ..
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2009-05-01 16:57 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-04-21 21:35 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13179
Subject		: CD-R: wodim intermittent failures
Submitter	: Andy Isaacson <adi@hexapodia.org>
Date		: 2009-04-21 1:52 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124027879214231&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13171
Subject		: 2.6.30-rc2 + xorg-intel-2.7.0 + DRM_I915_KMS =3D corruption
Submitter	: Alex Bennee <kernel-hacker@bennee.com>
Date		: 2009-04-19 6:27 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124022460014812&w=3D=
4
		  https://bugs.freedesktop.org/show_bug.cgi?id=3D21480


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13148
Subject		: resume after suspend-to-ram broken on Sony Vaio VGN-SR19VN w=
hen sony-laptop driver present
Submitter	: fanderay <fanderay4@googlemail.com>
Date		: 2009-04-22 14:39 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13126
Subject		: BUG: MAX_LOCKDEP_ENTRIES too low! when mounting rootfs
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-04-15 12:43 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979949820538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins@novell.com>
Date		: 2009-04-14 21:32 (41 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa@zytor.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13116
Subject		: Can't boot with nosmp
Submitter	: Stephen Hemminger <shemminger@vyatta.com>
Date		: 2009-04-15 4:18 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123976917817920&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams@intel.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13378
Subject		: kernel/async.c broke pata_legacy.c
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-05-24 16:13 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124318186507210&w=3D=
4
Handled-By	: James Bottomley <James.Bottomley@hansenpartnership.com>
Patch		: http://patchwork.kernel.org/patch/25699/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13293
Subject		: Kernel BUG under network load with gianfar
Submitter	: Michael Guntsche <mike@it-loops.com>
Date		: 2009-05-03 13:36 (22 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0fd56bb5be6455d0d42241e65aed057244665e5e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124135824600924&w=3D=
4
Handled-By	: Lennert Buytenhek <buytenh@wantstofly.org>
Patch		: http://patchwork.kernel.org/patch/25518/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13277
Subject		: Thinkpad X40 no longer resumes reliable since ff69f2bba67bd4=
5514923aaedbf40fe351787c59
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2009-05-11 10:08 (14 days old)
Handled-By	: Len Brown <len.brown@intel.com>
Patch		: http://patchwork.kernel.org/patch/22499/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13245
Subject		: possible circular locking dependency detected
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-05-04 16:56 (21 days old)
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://patchwork.kernel.org/patch/25557/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13125
Subject		: active uvcvideo breaks over suspend
Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date		: 2009-04-15 10:12 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979009508840&w=3D=
4
Handled-By	: Ming Lei <tom.leiming@gmail.com>
Patch		: http://lkml.org/lkml/2009/4/18/5


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13121
Subject		: Buggy _BCM - acer aspire 5720G, 5710Z, 5315
Submitter	: Maxim Levitsky <maximlevitsky@gmail.com>
Date		: 2009-04-16 11:37 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1a7c618a3f7bef1a20ae740df512eeba21397fa5
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123988189401913&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang@intel.com>
Patch		: http://patchwork.kernel.org/patch/19755/
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21268


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista@gmail.com>
Date		: 2009-04-11 14:56 (44 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang@intel.com>
		  Alexey Starikovskiy <astarikovskiy@suse.de>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D21061
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21282


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

