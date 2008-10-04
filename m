From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.27-rc8-git7: Reported regressions from 2.6.26
Date: Sat,  4 Oct 2008 19:28:42 +0200 (CEST)
Message-ID: <0pOgGB.A.uLG.E475IB@wind>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44570 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbYJDTNZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 15:13:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message contains a list of some regressions from 2.6.26, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.26, please let=
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
  2008-10-04      181       41          33
  2008-09-27      173       35          28
  2008-09-21      169       45          36
  2008-09-15      163       46          32
  2008-09-12      163       51          38
  2008-09-07      150       43          33
  2008-08-30      135       48          36
  2008-08-23      122       48          40
  2008-08-16      103       47          37
  2008-08-10       80       52          31
  2008-08-02       47       31          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11700
Subject		: ACPI instabilities and IRQs being disabled
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2008-09-27 22:40 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122255527412178&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11699
Subject		: 2.6.27-rc-7: BUG: scheduling while atomic, c1e_idle+0x98/0xe=
0
Submitter	: Prakash Punnoor <prakash@punnoor.de>
Date		: 2008-09-28 17:45 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122262403415629&w=3D=
4
Handled-By	: Thomas Gleixner <tglx@linutronix.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11698
Subject		: 2.6.27-rc7, freezes with &gt; 1 s2ram cycle
Submitter	: Soeren Sonnenburg <kernel@nn7.de>
Date		: 2008-09-29 11:29 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122268780926859&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11697
Subject		: CD tray closes spontaneously after opening it
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2008-09-30 10:47 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122277167125264&w=3D=
4
Handled-By	: Kay Sievers <kay.sievers@vrfy.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11695
Subject		: USB disconnects every 30 seconds
Submitter	: Dave Hansen <dave@sr71.net>
Date		: 2008-10-03 17:45 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122305738430115&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11676
Subject		: 2.6.27-rc2 to rc8, apgart fails, iommu=3Dsoft works, regress=
ion
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2008-09-30 10:24 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11664
Subject		: acpi errors and random freeze on sony vaio sr
Submitter	: Giovanni Pellerano <giovanni.pellerano@gmail.com>
Date		: 2008-09-28 03:48 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11643
Subject		: ALSA sound/core/pcm_native.c:1947: BUG? (err &gt;=3D 0)
Submitter	: sangu <sangu.gnome@gmail.com>
Date		: 2008-09-24 16:51 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11634
Subject		: Sometime my laptop is dead on resume from ram
Submitter	: Romano Giannetti <romano.giannetti@gmail.com>
Date		: 2008-09-24 01:12 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11608
Subject		: 2.6.27-rc6 BUG: unable to handle kernel paging request
Submitter	: John Daiker <daikerjohn@gmail.com>
Date		: 2008-09-16 23:00 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122160611517267&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11607
Subject		: 2.6.27-rc6 =C2=A0Bug in tty_chars_in_buffer
Submitter	: John Daiker <daikerjohn@gmail.com>
Date		: 2008-09-15 2:26 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122144565514490&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11569
Subject		: Don't complain about disabled irqs when the system has panic=
ed
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2008-09-02 13:49 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122036356127282&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11568
Subject		: spontaneous reboot on resume with 2.6.27
Submitter	: Andy Wettstein <ajw1980@gmail.com>
Date		: 2008-09-14 20:00 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11543
Subject		: kernel panic: softlockup in tick_periodic() ???
Submitter	: Joshua Hoblitt <j_kernel@hoblitt.com>
Date		: 2008-09-11 16:46 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122117786124326&w=3D=
4
Handled-By	: Thomas Gleixner <tglx@linutronix.de>
		  Cyrill Gorcunov <gorcunov@gmail.com>
		  Ingo Molnar <mingo@elte.hu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11516
Subject		: severe performance degradation on x86_64 going from 2.6.26-r=
c9 -&gt; 2.6.27-rc5
Submitter	: Jason Vas Dias <jason.vas.dias@gmail.com>
Date		: 2008-09-07 13:59 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11512
Subject		: sort-of regression due to "kconfig: speed up all*config + ra=
ndconfig"
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2008-09-05 22:50 (30 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122065498013858&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11504
Subject		: reiserfs =C2=A0BUG in 2.6.27-rc5
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2008-09-03 16:35 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122045982120138&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11476
Subject		: failure to associate after resume from suspend to ram
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2008-09-01 13:33 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122028529415108&w=3D=
4
Handled-By	: Zhu Yi <yi.zhu@intel.com>
		  Dan Williams <dcbw@redhat.com>
		  Jouni Malinen <j@w1.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11407
Subject		: suspend: unable to handle kernel paging request
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2008-08-21 17:28 (45 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121933974928881&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
		  Pekka Enberg <penberg@cs.helsinki.fi>
		  Pavel Machek <pavel@suse.cz>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11404
Subject		: BUG: in 2.6.23-rc3-git7 in do_cciss_intr
Submitter	: rdunlap <randy.dunlap@oracle.com>
Date		: 2008-08-21 5:52 (45 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121929819616273&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D121932889105368&w=3D4
Handled-By	: Miller, Mike (OS Dev) <Mike.Miller@hp.com>
		  James Bottomley <James.Bottomley@hansenpartnership.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11380
Subject		: lockdep warning: cpu_add_remove_lock at:cpu_maps_update_begi=
n+0x14/0x16
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2008-08-20 6:44 (46 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121921480931970&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11340
Subject		: LTP overnight run resulted in unusable box
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2008-08-13 9:24 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121861951902949&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11308
Subject		: tbench regression on each kernel release from 2.6.22 -&gt; 2=
=2E6.28
Submitter	: Christoph Lameter <cl@linux-foundation.org>
Date		: 2008-08-11 18:36 (55 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121847986119495&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122125737421332&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11272
Subject		: BUG: parport_serial in 2.6.27-rc1 for NetMos Technology PCI =
9835
Submitter	: Jaswinder Singh <jaswinderlinux@gmail.com>
Date		: 2008-08-05 15:12 (61 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121794900319776&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11271
Subject		: BUG: fealnx in 2.6.27-rc1
Submitter	: Jaswinder Singh <jaswinderlinux@gmail.com>
Date		: 2008-08-05 14:58 (61 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D121794762016830&w=3D=
4
		  http://lkml.org/lkml/2008/8/10/98
Handled-By	: Francois Romieu <romieu@fr.zoreil.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11264
Subject		: Invalid op opcode in kernel/workqueue
Submitter	: Jean-Luc Coulon <jean.luc.coulon@gmail.com>
Date		: 2008-08-07 04:18 (59 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11230
Subject		: Kconfig no longer outputs a .config with freshly updated def=
configs
Submitter	: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Date		: 2008-08-02 16:03 (64 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121769306319391&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11224
Subject		: Only three cores found on quad-core machine.
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2008-08-01 18:15 (65 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121761475224719&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11220
Subject		: Screen stays black after resume
Submitter	: Nico Schottelius <nico@schottelius.org>
Date		: 2008-07-31 21:05 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121753882422899&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11215
Subject		: INFO: possible recursive locking detected ps2_command
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2008-07-31 9:41 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121749737011637&w=3D=
4
Handled-By	: Peter Zijlstra <a.p.zijlstra@chello.nl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11210
Subject		: libata badness
Submitter	: Kumar Gala <galak@kernel.crashing.org>
Date		: 2008-07-31 18:53 (66 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D121753059307310&w=3D4
Handled-By	: Kumar Gala <galak@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11209
Subject		: 2.6.27-rc1 process time accounting
Submitter	: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date		: 2008-07-31 10:43 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121750102917490&w=3D=
4
		  http://lkml.org/lkml/2008/9/30/199
Handled-By	: Peter Zijlstra <a.p.zijlstra@chello.nl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11207
Subject		: VolanoMark regression with 2.6.27-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2008-07-31 3:20 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D121747464114335&w=3D=
4
Handled-By	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
		  Peter Zijlstra <a.p.zijlstra@chello.nl>
		  Dhaval Giani <dhaval@linux.vnet.ibm.com>
		  Miao Xie <miaox@cn.fujitsu.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11701
Subject		: sky2 wol regression
Submitter	: Tino Keitel <tino.keitel@gmx.de>
Date		: 2008-09-24 8:05 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122224359222164&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122298334522551&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11696
Subject		: 2.6.27-rc8 doubled times
Submitter	: Hugh Dickins <hugh@veritas.com>
Date		: 2008-10-03 10:21 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122302939313636&w=3D=
4
Handled-By	: Thomas Gleixner <tglx@linutronix.de>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122307260621434&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11629
Subject		: quad G5 fails to shut down
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2008-09-23 14:20 (12 days old)
Handled-By	: Johannes Berg <johannes@sipsolutions.net>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11629#c8


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11615
Subject		: sata_nv EH problems
Submitter	: P=C3=A4r Andersson <paran@lysator.liu.se>
Date		: 2008-09-21 18:09 (14 days old)
Handled-By	: Tejun Heo <tj@kernel.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18078&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11550
Subject		: pnp: Huge number of "io resource overlap" messages
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2008-09-09 10:50 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122095745403793&w=3D=
4
Handled-By	: Rene Herman <rene.herman@keyaccess.nl>
		  Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122246533505643&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11549
Subject		: 2.6.27-rc5 acpi: EC Storm error message on bootup
Submitter	: <jmerkey@wolfmountaingroup.com>
Date		: 2008-09-02 21:27 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122039255517586&w=3D=
4
Handled-By	: Alexey Starikovskiy <astarikovskiy@suse.de>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18047&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11505
Subject		: oltp ~10% regression with 2.6.27-rc5 on stoakley machine
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2008-09-04 7:06 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122051202202373&w=3D=
4
		  http://marc.info/?t=3D122089704700005&r=3D1&w=3D4
Handled-By	: Peter Zijlstra <a.p.zijlstra@chello.nl>
		  Gregory Haskins <ghaskins@novell.com>
		  Ingo Molnar <mingo@elte.hu>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122194673932703&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11442
Subject		: btusb hibernation/suspend breakage in current -git
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2008-08-25 11:37 (41 days old)
References	: http://marc.info/?l=3Dlinux-bluetooth&m=3D121966402012074&=
w=3D4
Handled-By	: Oliver Neukum <oliver@neukum.org>
Patch		: http://marc.info/?l=3Dlinux-bluetooth&m=3D121967226027323&w=3D=
4
		  http://bugzilla.kernel.org/show_bug.cgi?id=3D11442#c1


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.26,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11167

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

