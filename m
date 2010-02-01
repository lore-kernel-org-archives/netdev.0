From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.33-rc6: Reported regressions from 2.6.32
Date: Mon,  1 Feb 2010 01:18:53 +0100 (CET)
Message-ID: <vZZJKzCUn4G.A.CPB.F7hZLB@chimera>
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
  2010-02-01       85       26          21
  2010-01-24       75       29          23
  2010-01-10       55       33          21
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15202
Subject		: lockdep warning during elevator_switch
Submitter	: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
Date		: 2010-01-31 23:55 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126498212613051&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15200
Subject		: NFS problems in 2.6.33-rc6: Unknown error 526
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2010-01-31 22:46 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126497800408928&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15199
Subject		: sata_nv and no /dev files
Submitter	: Bart=C5=82omiej Zimo=C5=84 <uzi18-h7QdYz1kt/Q@public.gmane.org>
Date		: 2010-01-31 23:45 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126498153112488&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15196
Subject		: kmem_cache_create: duplicate cache ccid2_h
Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
Date		: 2010-01-30 18:33 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126487640324942&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15192
Subject		: netperf ~50% regression with 2.6.33-rc1, bisect to 1b9508f
Submitter	: Lin Ming <ming.m.lin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-25 10:03 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1b9508f6831e10d53256825de8904caa22d1ca2c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126441481427331&w=3D=
4
Handled-By	: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
		  Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15144
Subject		: HDA Intel Audio hang on boot
Submitter	: Sid Boyce <sboyce-QgLWrMLu8clzjhtm8Ag3mw@public.gmane.org>
Date		: 2010-01-15 1:24 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126351866722507&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15142
Subject		: "INFO: possible circular locking dependency detected"
Submitter	: Matti Aarnio <matti.aarnio--kernel-bugzilla-VYF+RMHuKCpAfugRpC6u6w@public.gmane.org>
Date		: 2010-01-25 13:38 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15139
Subject		: e1000: transmit queue 0 timed out
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-23 15:37 (9 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126426149306083&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15138
Subject		: evdev regression on macbook
Submitter	: Guillaume Chazarain <guichaz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-23 18:53 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126427286219235&w=3D=
4
Handled-By	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15125
Subject		: hung task - jbd2/dm-1-8 (during raid rebuild)
Submitter	: Michael Breuer <mbreuer-P//MSfjsEjDQT0dZR+AlfA@public.gmane.org>
Date		: 2010-01-10 21:47 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126316012025978&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15124
Subject		: PCI host bridge windows ignored (works with pci=3Duse_crs)
Submitter	: Jeff Garrett <jeff-184d8XiO+QJg9hUCZPvPmw@public.gmane.org>
Date		: 2010-01-13 5:37 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126336296600307&w=3D=
4
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
		  Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15119
Subject		: iwl_bg_scan_completed: WARN on scan complete
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-24 12:27 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15114
Subject		: X.org hang with [drm:i915_gem_do_execbuffer] *ERROR* in dmes=
g
Submitter	: Matej Laitl <strohel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-23 19:54 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15076
Subject		: System panic under load with clockevents_program_event
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-17 13:03 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15043
Subject		: Display goes off with i915.powersave=3D1 after suspend-resum=
e
Submitter	: Soeren Sonnenburg <sonne-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2010-01-10 20:09 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126315457519505&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15036
Subject		: soft lockup in dmesg after suspend/resume
Submitter	: ykzhao <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-04 5:36 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126258356202722&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15025
Subject		: Oops in ext4 driver
Submitter	: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-01-10 13:09 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14999
Subject		: possible circular locking dependency detected in rfkill at s=
uspend
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-01-06 21:52 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-25 11:11 (38 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson-1HOZaDBbGgxaa/9Udqfwiw@public.gmane.org>
Date		: 2009-12-27 13:35 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi-wpr36wD7VxHR7s880joybQ@public.gmane.org>
Date		: 2009-12-12 13:28 (51 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D27dfaf4f5825a119305db1bc63bef30ed400e376
Handled-By	: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15198
Subject		: Radeon KMS regression
Submitter	: Kevin Winchester <kjwinchester-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-30 17:18 (2 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D42590a75019a50012f25a962246498dead428433
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126487191019612&w=3D=
4
Handled-By	: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/75023/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15195
Subject		: kernel BUG at include/net/netns/generic.h:41, pfkey_create+0=
x36/0x18b [af_key]
Submitter	: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-30 13:23 (2 days old)
References	: http://marc.info/?l=3Dlinux-netdev&m=3D126485785004775&w=3D=
4
Handled-By	: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/75891/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15039
Subject		: leds_alix2: can't allocate I/O for GPIO
Submitter	: Arnd Hannemann <hannemann-JasiFyN5vQG662+jY7v6MhvVK+yQ3ZXh@public.gmane.org>
Date		: 2010-01-07 10:26 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126286001106257&w=3D=
4
Handled-By	: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/72006/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14949
Subject		: drm_vm.c:drm_mmap: possible circular locking dependency dete=
cted
Submitter	: Borislav Petkov <petkovbb-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-12-26 9:45 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182073616279&w=3D=
4
Handled-By	: Eric W. Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/70461/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14791
Subject		: Something has been broken in the network stack this week
Submitter	: Delete This Account <speedyboyinovator-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-12-12 13:06 (51 days old)
Handled-By	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
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
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
