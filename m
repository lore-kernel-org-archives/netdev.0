From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc5: Reported regressions from 2.6.32
Date: Sun, 24 Jan 2010 22:54:30 +0100 (CET)
Message-ID: <md-TZL3UUvL.A.FiE.xJMXLB@chimera>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.32, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.32, please let=
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
  2010-01-24       75       29          23
  2010-01-10       55       33          21
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15139
Subject		: e1000: transmit queue 0 timed out
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-01-23 15:37 (2 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126426149306083&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15138
Subject		: evdev regression on macbook
Submitter	: Guillaume Chazarain <guichaz@gmail.com>
Date		: 2010-01-23 18:53 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126427286219235&w=3D=
4
Handled-By	: Dmitry Torokhov <dmitry.torokhov@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15133
Subject		: Wake on LAN doesn't work in sky2
Submitter	: Tino Keitel <tino.keitel@tikei.de>
Date		: 2010-01-15 9:10 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D166a0fd4c788ec7f10ca8194ec6d526afa12db75
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126354704815848&w=3D=
4
Handled-By	: Stephen Hemminger <shemminger@vyatta.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15132
Subject		: OOPS's with large initramfs
Submitter	: Nigel Kukard <nkukard@lbsd.net>
Date		: 2010-01-16 11:12 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126364100321603&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15129
Subject		: [drm:i915_gem_execbuffer] *ERROR* i915_gem_do_execbuffer ret=
urns -512
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-01-14 23:18 (11 days old)
References	: http://lkml.org/lkml/2010/1/14/570
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15126
Subject		: REGRESSION for RT2561/RT61 in 2.6.33
Submitter	: Alan Stern <stern@rowland.harvard.edu>
Date		: 2010-01-11 14:54 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126322167427159&w=3D=
4
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15125
Subject		: hung task - jbd2/dm-1-8 (during raid rebuild)
Submitter	: Michael Breuer <mbreuer@majjas.com>
Date		: 2010-01-10 21:47 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126316012025978&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15124
Subject		: PCI host bridge windows ignored (works with pci=3Duse_crs)
Submitter	: Jeff Garrett <jeff@jgarrett.org>
Date		: 2010-01-13 5:37 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126336296600307&w=3D=
4
Handled-By	: Yinghai Lu <yinghai@kernel.org>
		  Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15076
Subject		: System panic under load with clockevents_program_event
Submitter	: okias <d.okias@gmail.com>
Date		: 2010-01-17 13:03 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15043
Subject		: Display goes off with i915.powersave=3D1
Submitter	: Soeren Sonnenburg <sonne@debian.org>
Date		: 2010-01-10 20:09 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126315457519505&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15038
Subject		: drm/ksm: fbdev blanking regression
Submitter	: Johan Hovold <jhovold@gmail.com>
Date		: 2010-01-06 17:00 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D731b5a15a3b1474a41c2ca29b4c32b0f21bc852e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279726418748&w=3D=
4
Handled-By	: James Simmons <jsimmons@infradead.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15036
Subject		: soft lockup in dmesg after suspend/resume
Submitter	: ykzhao <yakui.zhao@intel.com>
Date		: 2010-01-04 5:36 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126258356202722&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15032
Subject		: Oops in uart_resume_port() on resume
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-01-04 15:47 (21 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dba15ab0e8de0d4439a91342ad52d55ca9e313f3d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126262008815689&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15025
Subject		: Oops in ext4 driver
Submitter	: Steinar H. Gunderson <sgunderson@bigfoot.com>
Date		: 2010-01-10 13:09 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15017
Subject		: kexec regression, radeon/kms irq related (bisected)
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2010-01-09 18:49 (16 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd8f60cfc93452d0554f6a701aa8e3236cbee4636


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15000
Subject		: Thinkpad dock button no longer works
Submitter	: Paul Martin <pm@debian.org>
Date		: 2010-01-07 02:11 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14999
Subject		: possible circular locking dependency detected in rfkill at s=
uspend
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-01-06 21:52 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-12-25 11:11 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14946
Subject		: All kernels after 2.6.32-git10  show only 1 CPU
Submitter	: Sid Boyce <sboyce@blueyonder.co.uk>
Date		: 2009-12-23 16:55 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126158734326801&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:35 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14924
Subject		: Weird hard hangs when rendering 'some' web-sites in Firefox
Submitter	: David <david@unsolicited.net>
Date		: 2009-12-21 21:53 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126143375823340&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14859
Subject		: System timer firing too much without cause
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2009-12-21 19:16 (35 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi@agolina.net>
Date		: 2009-12-12 13:28 (44 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15137
Subject		: NULL pointer dereference in vlan_skb_recv
Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Date		: 2010-01-23 15:56 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126426286507497&w=3D=
4
Handled-By	: Eric Dumazet <eric.dumazet@gmail.com>
Patch		: http://patchwork.kernel.org/patch/74999/
		  http://patchwork.kernel.org/patch/75002/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15131
Subject		: [OOPS] radeon kms
Submitter	: John Kacur <jkacur@redhat.com>
Date		: 2010-01-15 15:45 (10 days old)
References	: http://lkml.org/lkml/2010/1/15/129
Handled-By	: Jerome Glisse <glisse@freedesktop.org>
Patch		: http://git.kernel.org/?p=3Dlinux/kernel/git/airlied/drm-2.6.gi=
t;a=3Dpatch;h=3D30d2d9a54d48e4fefede0389ded1b6fc2d44a522


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15128
Subject		: Boot regression on AMD
Submitter	: Gene Heskett <gene.heskett@verizon.net>
Date		: 2010-01-13 20:21 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126341413213017&w=3D=
4
Handled-By	: Andreas Herrmann <andreas.herrmann3@amd.com>
Patch		: http://patchwork.kernel.org/patch/74883/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15039
Subject		: leds_alix2: can't allocate I/O for GPIO
Submitter	: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date		: 2010-01-07 10:26 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126286001106257&w=3D=
4
Handled-By	: Daniel Mack <daniel@caiaq.de>
Patch		: http://patchwork.kernel.org/patch/72006/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14949
Subject		: drm_vm.c:drm_mmap: possible circular locking dependency dete=
cted
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:45 (30 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182073616279&w=3D=
4
Handled-By	: Eric W. Biederman <ebiederm@aristanetworks.com>
Patch		: http://patchwork.kernel.org/patch/70461/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14791
Subject		: Something has been broken in the network stack this week
Submitter	: Delete This Account <speedyboyinovator@hotmail.com>
Date		: 2009-12-12 13:06 (44 days old)
Handled-By	: Ben Hutchings <ben@decadent.org.uk>
Patch		: http://patchwork.kernel.org/patch/72073/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.32,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14885

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
