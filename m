From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.28-rc5: Reported regressions from 2.6.27
Date: Sun, 16 Nov 2008 17:24:10 +0100 (CET)
Message-ID: <VwdsQNEjR_C.A.CiD.9_FIJB@chimera>
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
 (1) Due to some recent controversies, in future I will only use 'Handl=
ed-By'
     tags for people who actually submit a patch or provide substantial=
 help to
     the reporter (like advising him which commits to revert etc.).
 (2) We have almost as many regressions with patches as unresolved ones=
 and
     the majority of these patches have not been merged for over two we=
eks
     (for almost three weeks in many cases and for over a _month_ in on=
e case).
     IMO, this is insane.]

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
  2008-11-16       89       32          18
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12049
Subject		: Oops in acpi_system_wakeup_device_seq_show
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2008-11-16 13:04 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0794469da3f7b2093575cbdfc1108308dd3641ce
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122684070215520&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12041
Subject		: 2.6.28-rc4 mem_cgroup_charge_common panic
Submitter	: Badari Pulavarty <pbadari-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date		: 2008-11-10 21:43 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122635343008147&w=3D=
4
Handled-By	: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12040
Subject		: iwlagn driver segfault in 2.6.28-rc3
Submitter	: Lukas Hejtmanek <xhejtman-8qz54MUs51PtwjQa/ONI9g@public.gmane.org>
Date		: 2008-11-11 14:34 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122641417331593&w=3D=
4
Handled-By	: reinette chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12034
Subject		: snd-hda-intel on Realtek ALC268 chip shows only Master volum=
e (for playback)
Submitter	: Sergey <azure-IGUVrPOATOfsG83rWm+8vg@public.gmane.org>
Date		: 2008-11-15 04:20 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12031
Subject		: DRM enabled kernel hangs hard on resume on x60
Submitter	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2008-11-12 18:42 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122651551216820&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12028
Subject		: i915 DRM is broken in 2.6.28-rc4
Submitter	: Adam Tkac <vonsch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-14 01:50 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12019
Subject		: Major increase in the number of wakeups from C3
Submitter	: Mircea Gherzan <mgherzan-0aWM6n0cdD1zL9IiBdi9GK9KmVUGpFAF@public.gmane.org>
Date		: 2008-11-13 07:02 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11996
Subject		: Tracing framework regression in 2.6.28-rc3
Submitter	: Pekka Paalanen <pq-X3B1VOXEql0@public.gmane.org>
Date		: 2008-11-09 10:13 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122624392229317&w=3D=
4
Handled-By	: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11970
Subject		: gettimeofday return a old time in mmbench
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-06 23:57 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D99ebcf8285df28f32fd2d1c19a7166e70f00309c
Handled-By	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
		  Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11965
Subject		: regression introduced by - timers: fix itimer/many thread ha=
ng
Submitter	: Doug Chapman <doug.chapman-VXdhtT5mjnY@public.gmane.org>
Date		: 2008-11-06 11:03 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df06febc96ba8e0af80bcc3eaec0a109e88275fac
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122596943416648&w=3D=
4
Handled-By	: Frank Mayhar <fmayhar-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
		  Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
		  Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11958
Subject		: [2.6.27.x =3D&gt; 2.6.28-rc3] Xorg crash with xf86MapVidMem =
error
Submitter	: Tomasz Chmielewski <tch-Nem3ZqsbT/g@public.gmane.org>
Date		: 2008-11-05 05:37 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11947
Subject		: 2.6.28-rc VC switching with Intel graphics broken
Submitter	: Romano Giannetti <romano.giannetti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-03 12:10 (14 days old)
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11913
Subject		: USB/INPUT: slab error in cache_alloc_debugcheck_after(): dou=
ble free?
Submitter	: Helge Deller <deller-Mmb7MZpHnFY@public.gmane.org>
Date		: 2008-10-30 23:11 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dcb8f488c33539f096580e202f5438a809195008f
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122540833301394&w=3D=
4
Handled-By	: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Denys Vlasenko <vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11906
Subject		: 2.6.28-rc2 seems to fail at powering down the monitor when i=
t should
Submitter	: Gene Heskett <gene.heskett-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 6:39 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122534879721424&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11905
Subject		: lots of extra timer interrupts costing 2W
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2008-10-30 2:18 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfb02fbc14d17837b4b7b02dbb36142c16a7bf208
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122533314305315&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122541849114444&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11858
Subject		: Timeout regression introduced by 242f9dcb8ba6f68fcd217a119a7=
648a4f69290e9
Submitter	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-26 9:46 (22 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D242f9dcb8ba6f68fcd217a119a7648a4f69290e9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122501447326698&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2008-10-24 12:45 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11822
Subject		: ACPI Warning (nspredef-0858): _SB_.PCI0.LPC_.EC__.BAT0._BIF:=
 Return Package type mismatch at index 9 - found Buffer, expected Strin=
g [20080926]
Submitter	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-25 01:26 (23 days old)
Handled-By	: Robert Moore <Robert.Moore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12047
Subject		: ACPI toshiba: only register rfkill if bt is enabled
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:10 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522113619025&w=3D=
2
Handled-By	: Frederik Deweerdt <frederik.deweerdt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122526843117478&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12042
Subject		: USB hid blocks USB port in 2.6.28rc3
Submitter	: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Date		: 2008-11-11 0:31 (6 days old)
References	: http://marc.info/?l=3Dlinux-usb&m=3D122636246522848&w=3D4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122661425620251&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12038
Subject		: Suspend regression in stable kernel 2.6.27.4 on Mac mini Cor=
e Duo
Submitter	: Tino Keitel <tino.keitel-Mmb7MZpHnFY@public.gmane.org>
Date		: 2008-11-09 20:28 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D66036f5862883fcc9f7ff8550685a5a3de1a57e4
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122626258429689&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122661443120581&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12020
Subject		: scsi_times_out NULL pointer dereference
Submitter	: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Date		: 2008-11-13 10:30 (4 days old)
Handled-By	: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D12020#c4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11989
Subject		: Suspend failure on NForce4-based boards due to chanes in sto=
p_machine
Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Date		: 2008-11-03 0:28 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc9583e55fa2b08a230c549bd1e3c0bde6c50d9cc
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122567187604356&w=3D=
4
Handled-By	: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Patch		: http://lkml.org/lkml/2008/11/15/69


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11982
Subject		: Fan level 7 after resume wit 2.6.28-rc3
Submitter	: Tino Keitel <tino.keitel-rAwCM5oiXHA@public.gmane.org>
Date		: 2008-11-05 7:33 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122587043409186&w=3D=
4
Handled-By	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18744&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11954
Subject		: sysprof tracer ABI regression in 2.6.28rc1
Submitter	: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Date		: 2008-11-04 22:14 (13 days old)
Handled-By	: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18683&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11925
Subject		: cdrom: missing compat ioctls
Submitter	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Date		: 2008-10-31 14:02 (17 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D33c2dca4957bd0da3e1af7b96d0758d97e708ef6
Handled-By	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122548923531545&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11911
Subject		: new PCMCIA device instance after resume - orinoco can't down=
load firmware
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:19 (20 days old)
References	: http://marc.info/?l=3Dlinux-wireless&m=3D122522165719760&w=
=3D4
Handled-By	: Dave <kilroyd-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122539058601588&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11903
Subject		: regression: vmalloc easily fail
Submitter	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2008-10-28 20:59 (20 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Ddb64fe02258f1507e13fe5212a989922323685ce
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522755530998&w=3D=
4
Handled-By	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
		  Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
		  Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122609055221549&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11899
Subject		: sometime boot failed on T61 laptop
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 02:04 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122663989015147&w=3D=
4
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
		  Yanmin Zhang <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18860&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898
Subject		: mke2fs hang on AIC79 device.
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 01:17 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df0c0a376d0fcd4c5579ecf5e95f88387cba85211
Handled-By	: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
		  Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898#c28
		  http://bugzilla.kernel.org/show_bug.cgi?id=3D11898#c36


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11875
Subject		: radeonfb lockup in .28-rc (bisected)
Submitter	: James Cloos <cloos-GRsvFm/Gh/pBDgjK7y7TUQ@public.gmane.org>
Date		: 2008-10-28 0:00 (20 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db1ee26bab14886350ba12a5c10cbc0696ac679bf
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122515210200530&w=3D=
4
		  http://lkml.org/lkml/2008/11/10/12
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Patch		: http://lkml.org/lkml/2008/11/10/12


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11828
Subject		: Linux 2.6.27-git3: no SD card reader
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2008-10-14 0:54 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122394573904699&w=3D=
4
Handled-By	: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-pci&m=3D122662042229570&w=3D2


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
