From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.30-rc7-git4: Reported regressions from 2.6.29
Date: Sat, 30 May 2009 21:29:39 +0200 (CEST)
Message-ID: <4to6E2myxvG.A.muC.aIbIKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
  2009-05-31      100       32          27
  2009-05-24       92       34          27
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13408
Subject		: Performance regression in 2.6.30-rc7
Submitter	: Diego Calleja <diegocg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-30 18:51 (1 days old)
References	: http://lkml.org/lkml/2009/5/30/146


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13407
Subject		: adb trackpad disappears after suspend to ram
Submitter	: Jan Scholz <scholz-wOpdxP1gw6Cc+IqHO83+wjjhTm2NLCe8@public.gmane.org>
Date		: 2009-05-28 7:59 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ed8d2b3a81bdbb0418301628ccdb008ac9f40b7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124349762314976&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13401
Subject		: pktcdvd writing is really slow with CFQ scheduler (bisected)
Submitter	: Laurent Riffard <laurent.riffard-GANU6spQydw@public.gmane.org>
Date		: 2009-05-28 18:43 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13391
Subject		: Kernel boot hangs at about every second start when kms is ac=
tivated
Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
Date		: 2009-05-26 21:47 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13389
Subject		: Warning 'Invalid throttling state, reset' gets displayed whe=
n it should not be
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-05-26 15:24 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13377
Subject		: Microphone no longer works on Toshiba Satellite A100
Submitter	: M. Vefa Bicakci <bicave-qUEp0r/b3FNfOZc0+OmrVg@public.gmane.org>
Date		: 2009-05-24 15:49 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D23f0c048ba59ad5c2f3fd85ed98360b631dbf6f8
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124318383910011&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13374
Subject		: reiserfs blocked for more than 120secs
Submitter	: Harald Dunkel <harald.dunkel-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2009-05-23 8:52 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124306880410811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13373
Subject		: fbcon, intelfb, i915: INFO: possible circular locking depend=
ency detected
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-23 5:08 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124305538130702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13366
Subject		: About 80% of shutdowns fail (blocking)
Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
Date		: 2009-05-23 00:58 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13362
Subject		: [mac80211 ] Wifi Network Slownes Bisected
Submitter	: Alejandro Riveira <ariveira-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-22 13:32 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13351
Subject		: 2.6.30 corrupts my system after suspend resume with readonly=
 mounted hard disk
Submitter	:  <unggnu-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-05-20 14:09 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78a8b35bc7abf8b8333d6f625e08c0f7cc1c3742
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick-nxAOmsU53hB6lmGzAMPh1A@public.gmane.org>
Date		: 2009-05-19 09:08 (12 days old)
Handled-By	: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13337
Subject		: [post 2.6.29 regression] hang during suspend of b44/b43 modu=
les
Submitter	: Tomas Janousek <tomi-YoqI/XImC7s@public.gmane.org>
Date		: 2009-05-18 10:59 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13330
Subject		: nfs4 NULL pointer dereference in _nfs4_do_setlk
Submitter	: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>
Date		: 2009-05-17 04:44 (14 days old)
Handled-By	: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-03 16:22 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13325
Subject		: 2.6.30-rc kills my box hard - and lockdep chains
Submitter	: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Date		: 2009-05-14 15:49 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231630701394&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2009-04-29 21:01 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
Handled-By	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-30 8:51 (31 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13313
Subject		: vm86old oops
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-A/MS7pq9VAU@public.gmane.org>
Date		: 2009-05-14 21:53 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13310
Subject		: REGRESSION 2.6.30-rc1: oprofile panics system when started
Submitter	: Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-14 17:51 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2009-05-14 09:34 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13277
Subject		: 2.6.30 regression - unreliable resume - bisected - Thinkpad =
X40
Submitter	: Daniel Vetter <daniel-/w4YWyX8dFk@public.gmane.org>
Date		: 2009-05-11 10:08 (20 days old)
Handled-By	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13219
Subject		: Since kernel 2.6.30-rc1, computers hangs randomly ..
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2009-05-01 16:57 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-21 21:35 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13179
Subject		: CD-R: wodim intermittent failures
Submitter	: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2009-04-21 1:52 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124027879214231&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-14 21:32 (47 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13116
Subject		: Can't boot with nosmp
Submitter	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-15 4:18 (46 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123976917817920&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13406
Subject		: Kernel does not compile when set to use i915 kernel mode-set=
ting per default
Submitter	: Woody Suwalski <woodys-PRTm14v61u5BDgjK7y7TUQ@public.gmane.org>
Date		: 2009-05-20 19:30 (11 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D124284975803785&w=3D4
Handled-By	: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/27026/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13378
Subject		: kernel/async.c broke pata_legacy.c
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-05-24 16:13 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124318186507210&w=3D=
4
Handled-By	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/25699/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13372
Subject		: Oops in usb-serial with keyspan adapter
Submitter	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2009-05-18 0:07 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124260532924736&w=3D=
4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/26603/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13121
Subject		: Buggy _BCM - acer aspire 5720G, 5710Z, 5315
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-16 11:37 (45 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1a7c618a3f7bef1a20ae740df512eeba21397fa5
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123988189401913&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/19755/
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21268


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-11 14:56 (50 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
		  Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
