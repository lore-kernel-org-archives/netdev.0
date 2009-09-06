From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc9: Reported regressions from 2.6.30
Date: Sun,  6 Sep 2009 19:15:07 +0200 (CEST)
Message-ID: <2ehA7xoGvXL.A.4PB.3eBpKB@chimera>
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
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.30, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let=
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
  2009-09-06      123       34          27
  2009-08-26      108       33          26
  2009-08-20      102       32          29
  2009-08-10       89       27          24
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14141
Subject		: order 2 page allocation failures
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-09-06 7:40 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125222287419691&w=3D=
4
Handled-By	: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14139
Subject		: Output to external monitor is broken
Submitter	: Carlos R. Mafra <crmafra2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-06 14:22 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df8aed700c6ec46ddade6570004ce25332283b306
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125224701520738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14135
Subject		: NULL pointer dereference in ima_counts_put
Submitter	: Ciprian Docan <docan-plZrL8KR64B+CIkdHa1UOg@public.gmane.org>
Date		: 2009-09-02 13:49 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D94e5d714f604d4cb4cb13163f01ede278e69258b
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125190146028116&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14133
Subject		: WARNING: at arch/x86/kernel/smp.c:117 native_smp_send_resche=
dule
Submitter	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2009-08-31 20:43 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125175143918050&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14114
Subject		: Tuning a saa7134 based card is broken in kernel 2.6.31-rc7
Submitter	: Tsvety Petrov <Tsvetoslav.Petrov-qXmYkbEmOXkAvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-03 21:06 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14103
Subject		: cdc_acm gives I/O error
Submitter	: Paul Martin <pm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2009-09-01 13:30 (6 days old)
Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14095
Subject		: Asus EeePC 1005HA-M: Suspend hangs and disables the wireless
Submitter	:  Karsten Jaeger <lists-CsyeHe0QoF4AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-31 10:14 (7 days old)
References	: http://lists.alioth.debian.org/pipermail/debian-eeepc-deve=
l/2009-August/002513.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14070
Subject		: lockdep warning triggered by dup_fd
Submitter	: Bart Van Assche <bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-23 09:36 (15 days old)
References	: http://lkml.org/lkml/2009/8/23/8


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14058
Subject		: Oops in fsnotify
Submitter	: Grant Wilson <grant.wilson-1HOZaDBbGgxaa/9Udqfwiw@public.gmane.org>
Date		: 2009-08-20 15:48 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125078450923133&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14043
Subject		: System sometimes hangs during boot
Submitter	: Bart Van Assche <bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-23 18:04 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14018
Subject		: kernel freezes, inotify problem
Submitter	: Christoph Thielecke <christoph.thielecke-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-08-19 12:48 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125068616818353&w=3D=
4
Handled-By	: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14013
Subject		: hd don't show up
Submitter	: Tim Blechmann <tim-xpEK/MU0Hawdnm+yROfE0A@public.gmane.org>
Date		: 2009-08-14 8:26 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125023842514480&w=3D=
4
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-08-15 07:55 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13950
Subject		: Oops when USB Serial disconnected while in use
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-08 17:47 (30 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124975432900466&w=3D=
4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-06 20:15 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13942
Subject		: Troubles with AoE and uninitialized object
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-04 10:12 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124938117104811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk-X3B1VOXEql0@public.gmane.org>
Date		: 2009-08-03 12:58 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13940
Subject		: iwlagn and sky2 stopped working, ACPI-related
Submitter	: Ricardo Jorge da Fonseca Marques Ferreira <storm@sys49152.n=
et>
Date		: 2009-08-07 22:33 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968457731107&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13935
Subject		: 2.6.31-rcX breaks Apple MightyMouse (Bluetooth version)
Submitter	: Adrian Ulrich <kernel-4ZM2p5qjiQGewZBzVTKGGg@public.gmane.org>
Date		: 2009-08-08 22:08 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfa047e4f6fa63a6e9d0ae4d7749538830d14a343


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-04 09:02 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-07-29 16:44 (40 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 21:24 (52 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-23 17:57 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-07-22 13:35 (47 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-07 15:19 (62 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (63 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (82 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14140
Subject		: 2.6.31-rc9 breaks gianfar
Submitter	: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Date		: 2009-09-06 7:27 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D38bddf04bcfe661fbdab94888c3b72c32f6873b3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125222206218784&w=3D=
4
Handled-By	: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/45965/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14138
Subject		: Regression in suspend to ram
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-31 11:51 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125171952817851&w=3D=
4
Handled-By	: OGAWA Hirofumi <hirofumi-UIVanBePwB70ZhReMnHkpc8NsWr+9BEh@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/45945/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14137
Subject		: usb console regressions
Submitter	: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Date		: 2009-09-05 21:08 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125218501310512&w=3D=
4
Handled-By	: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/45953/
		  http://patchwork.kernel.org/patch/45952/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14136
Subject		: readcd Oops
Submitter	: Bob Tracy <rct-GsGdjl1a1FBK+8ot1e1MDQ@public.gmane.org>
Date		: 2009-09-03 3:39 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125195043617418&w=3D=
4
Handled-By	: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/45347/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Date		: 2009-08-13 6:45 (25 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13948
Subject		: ath5k broken after suspend-to-ram
Submitter	: Johannes Stezenbach <js-FF7aIK3TAVNeoWH0uzbU5w@public.gmane.org>
Date		: 2009-08-07 21:51 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968192727854&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38550/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13947
Subject		: Libertas: Association request to the driver failed
Submitter	: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date		: 2009-08-07 19:11 (31 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D57921c312e8cef72ba35a4cfe870b376da0b1b87
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124967234311481&w=3D=
4
Handled-By	: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/43114/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13615

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
