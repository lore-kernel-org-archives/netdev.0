From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.28-rc7-git2: Reported regressions from 2.6.27
Date: Wed,  3 Dec 2008 22:49:35 +0100 (CET)
Message-ID: <QFIA5HSHV8B.A.2aG.hoxNJB@chimera>
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * Sorry for the delayed report.  Recently, I've been distracted by a n=
umber
   of regressions on one of my test boxes.
 * I haven't managed to follow all of the linked threads this time in
   search for fixes, so if you know of any patches fixing the listed bu=
gs,
   please let me know.]

This message contains a list of some regressions from 2.6.27, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.27, please let=
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
  2008-12-04      106       29          21
  2008-11-22       93       25          15
  2008-11-16       89       32          18
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12161
Subject		: [i915 drm] irq 16: nobody cared with latest git kernels
Submitter	: fredi ml <mailinglists.fredi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-02 13:26 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122822444615724&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12160
Subject		: networking oops after resume from s2ram (2.6.28-rc6)
Submitter	: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-28 21:15 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122790701615723&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12159
Subject		: 2.6.28-rc6-git1 -- No sound produced from Intel HDA ALSA dri=
ver
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-27 20:33 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122781805620212&w=3D=
4
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12158
Subject		: commit b1ee26b freezes system on switching from X to text co=
nsole
Submitter	: Gaudenz Steinlin <gaudenz-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2008-11-25 19:44 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db1ee26bab14886350ba12a5c10cbc0696ac679bf
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122764344231140&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12156
Subject		: v2.6.28-rc2: x86_32 relocation regression?
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-24 21:19 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122756158220966&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12155
Subject		: Regression in 2.6.28-rc and 2.6.27-stable - hibernate relate=
d
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-23 16:17 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122745709926361&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12154
Subject		: Mmiotrace regression in 2.6.28-rc6
Submitter	: Pekka Paalanen <pq-X3B1VOXEql0@public.gmane.org>
Date		: 2008-11-23 13:41 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122744774317151&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12153
Subject		: 2.6.28-rc2: runaway loop modprobe char-major-5-1
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2008-10-28 10:15 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122518916014197&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12152
Subject		: Huge wakeups number from i1915
Submitter	: Yves-Alexis Perez <corsac-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2008-12-02 16:48 (2 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D122823656702994&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12120
Subject		: [Block layer or SCSI] requests aborted too early during chec=
k_partition()
Submitter	: Stefan Richter <stefan-r-bz-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date		: 2008-11-29 05:19 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12100
Subject		: resume (S2R) broken by Intel microcode module, on A110L
Submitter	: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Date		: 2008-11-25 08:48 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12061
Subject		: snd_hda_intel: power_save: sound cracks on powerdown
Submitter	: Jens Weibler <bugzilla-kernel-6hJTtV8wudIr9FUcG+3rRQ@public.gmane.org>
Date		: 2008-11-18 12:07 (16 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12034
Subject		: snd-hda-intel on Realtek ALC268 chip shows only Master volum=
e (for playback)
Submitter	: Sergey <azure-IGUVrPOATOfsG83rWm+8vg@public.gmane.org>
Date		: 2008-11-15 04:20 (19 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12028
Subject		: i915 DRM is broken in 2.6.28-rc4
Submitter	: Adam Tkac <vonsch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-14 01:50 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11970
Subject		: gettimeofday return a old time in mmbench
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-06 23:57 (28 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D99ebcf8285df28f32fd2d1c19a7166e70f00309c
Handled-By	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
		  Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
		  Yanmin Zhang <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11958
Subject		: [2.6.27.x =3D&gt; 2.6.28-rc3] Xorg crash with xf86MapVidMem =
error
Submitter	: Tomasz Chmielewski <tch-Nem3ZqsbT/g@public.gmane.org>
Date		: 2008-11-05 05:37 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11947
Subject		: 2.6.28-rc VC switching with Intel graphics broken
Submitter	: Romano Giannetti <romano.giannetti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-03 12:10 (31 days old)
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11906
Subject		: 2.6.28-rc2 seems to fail at powering down the monitor when i=
t should
Submitter	: Gene Heskett <gene.heskett-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 6:39 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122534879721424&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11858
Subject		: Timeout regression introduced by 242f9dcb8ba6f68fcd217a119a7=
648a4f69290e9
Submitter	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-26 9:46 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D242f9dcb8ba6f68fcd217a119a7648a4f69290e9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122501447326698&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2008-10-24 12:45 (41 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11828
Subject		: Linux 2.6.27-git3: no SD card reader
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2008-10-14 0:54 (51 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122394573904699&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12162
Subject		: Commit 7cd5b08be3 breaks startup on Toshiba Portege R500
Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Date		: 2008-12-03 22:00 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7cd5b08be3c489df11b559fef210b81133764ad4
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122834170321535&w=3D=
4
Handled-By	: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122834271623218&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12082
Subject		: IRQ and MSI allocations broken without sparse irq
Submitter	: Jesper Dangaard Brouer <hawk-dAYI7NvHqcQ@public.gmane.org>
Date		: 2008-11-20 19:48 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122721060501073&w=3D=
4
Handled-By	: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122722773824802&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12081
Subject		: xen: pin correct PGD on suspend
Submitter	: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Date		: 2008-11-21 10:21 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122726293324850&w=3D=
4
Handled-By	: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122726293324850&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12047
Subject		: ACPI toshiba: only register rfkill if bt is enabled
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:10 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522113619025&w=3D=
2
Handled-By	: Frederik Deweerdt <frederik.deweerdt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122526843117478&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12031
Subject		: DRM enabled kernel hangs hard on resume (Intel graphics)
Submitter	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2008-11-12 18:42 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122651551216820&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D19007&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12020
Subject		: scsi_times_out NULL pointer dereference
Submitter	: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Date		: 2008-11-13 10:30 (21 days old)
Handled-By	: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D12020#c4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11925
Subject		: cdrom: missing compat ioctls
Submitter	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Date		: 2008-10-31 14:02 (34 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D33c2dca4957bd0da3e1af7b96d0758d97e708ef6
Handled-By	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122548923531545&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898
Subject		: mke2fs hang on AIC79 device.
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 01:17 (35 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df0c0a376d0fcd4c5579ecf5e95f88387cba85211
Handled-By	: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
		  Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898#c28
		  http://bugzilla.kernel.org/show_bug.cgi?id=3D11898#c36


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.27,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11808

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
