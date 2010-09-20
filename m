From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc4-git5: Reported regressions 2.6.34 -> 2.6.35
Date: Mon, 20 Sep 2010 21:54:41 +0200 (CEST)
Message-ID: <r2gGqgg1zFC.A.LrE.w97lMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some post-2.6.34 regressions introduced before
2.6.35, for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.34 regressions, please let us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-09-20      137       27          25
  2010-09-12      135       26          25
  2010-08-30      124       38          34
  2010-08-01      100       27          23
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18522
Subject		: [REGRESSION] cdrom drive doesn't detect removal
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-12 9:49 (9 days old)
First-Bad-Commit: http://git.kernel.org/linus/6b4517a7913a09d3259bb1d21c9cb300f12294bd
Message-ID	: <1284284969.2928.18.camel@maxim-laptop>
References	: http://marc.info/?l=linux-kernel&m=128428499013930&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18272
Subject		: 2.6.35.*: horrible (exponential? >linear) slowdown to unusability (ACPI idle?)
Submitter	: Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
Date		: 2010-09-05 0:51 (16 days old)
First-Bad-Commit: http://git.kernel.org/linus/30a564be9d9554c168a654eddc2165869cc0d7bf
Message-ID	: <87zkvx2ese.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128364994602942&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18202
Subject		: Microphone levels too low
Submitter	: Alexander Hunziker <alex.hunziker-Mds7TqofYmjt3F02DXVmkw@public.gmane.org>
Date		: 2010-09-09 22:20 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18032
Subject		: No sound on headphone jack
Submitter	: Alexander Hunziker <alex.hunziker-Mds7TqofYmjt3F02DXVmkw@public.gmane.org>
Date		: 2010-09-07 21:45 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17812
Subject		: Kernel completely frozen when memory is full
Submitter	: Mickey86 <mikael.cordon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-05 13:09 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17772
Subject		: Unable to locate IOAPIC for GSI *
Submitter	: zersaa <zersaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-04 21:28 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17732
Subject		: [2.6.35.x regression] rcu_preempt_state stall warning and machine slow-downs
Submitter	: Matthias Dahl <ml_kernel-Rk1lLwyeSiSCvTm3UDtA3g@public.gmane.org>
Date		: 2010-09-01 6:47 (20 days old)
Message-ID	: <201009010847.20236.ml_kernel-Rk1lLwyeSiSCvTm3UDtA3g@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128332418629305&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16691
Subject		: IPW5100: iwlagn broken with 2.6.34.x to 2.6.35.2 update
Submitter	: Can Celasun <dcelasun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-21 08:28 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16633
Subject		: ath5k + 2.6.35 x86 + hostapd - Failed to set channel
Submitter	: NiTr0 <nitr0-z9XQkeP78BxUq1AO9QMCaQ@public.gmane.org>
Date		: 2010-08-19 19:37 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16614
Subject		: [2.6.35] usb 2.0 em28xx  kernel panic general protection fault: 0000 [#1] SMP          RIP: 0010:[<ffffffffa004fbc5>]  [<ffffffffa004fbc5>] em28xx_isoc_copy_vbi+0x62e/0x812 [em28xx]
Submitter	: Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Date		: 2010-08-10 22:12 (42 days old)
Message-ID	: <61936849.20100811001257-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128152075830927&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16562
Subject		: 2.6.35: cpu_idle bug report / on i7 870 cpu (x86_64)
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2010-08-06 22:09 (46 days old)
Message-ID	: <alpine.DEB.2.00.1008061800530.5241-0qmrozcXWo8bm2hyYBkBBg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128113260904048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16549
Subject		: 2.6.35: suspicious rcu_dereference_check() usage
Submitter	: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Date		: 2010-08-04 10:56 (48 days old)
Message-ID	: <4C594740.1090608-d+Crzxg7Rs0@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128091938215177&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16537
Subject		: TREE_RCU hangs at boot
Submitter	: Rolf Eike Beer <eike-kernel-F+mm6HnICJmzQB+pC5nmwQ@public.gmane.org>
Date		: 2010-08-07 12:18 (45 days old)
Handled-By	: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16525
Subject		: unexpected high load since 2.6.35
Submitter	: MadLoisae-hi6Y0CQ0nG0@public.gmane.org <MadLoisae-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-08-02 20:53 (50 days old)
Message-ID	: <4C573041.1070103-hi6Y0CQ0nG0@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128078243726655&w=2
		  http://lkml.org/lkml/2010/9/14/105


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16515
Subject		: [bisected] Radeon rv280 can't boot on kernel 2.6.35.
Submitter	: Albert Gall <ss3vdr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-04 16:10 (48 days old)
First-Bad-Commit: http://git.kernel.org/linus/https://bugzilla.kernel.org/attachment.cgi?id=27350
Handled-By	: Alex Deucher <alexdeucher-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16495
Subject		: Kernel 2.6.35 takes almost half an hour to boot
Submitter	: Claudio M. Camacho <claudiomkd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-02 17:16 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16488
Subject		: [i915] Framebuffer ID error after suspend/hibernate leading to X crash
Submitter	: Milan Bouchet-Valat <nalimilan-pqIVbhRXszc@public.gmane.org>
Date		: 2010-08-01 08:55 (51 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16462
Subject		: unable to connect to AP on legal channel 13
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-25 17:06 (58 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16458
Subject		: Bluetooth disabled after resume
Submitter	: AttilaN <attila123456-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-25 09:33 (58 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem-VInPYn6yXxRWk0Htik3J/w@public.gmane.org>
Date		: 2010-07-13 23:21 (70 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_measured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org-ro/BP3KN3ujR7s880joybQ@public.gmane.org>
Date		: 2010-07-01 13:54 (82 days old)
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2010-06-09 18:36 (104 days old)
First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb-UK71uKi2zisAobODsErMgNi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127610857819033&w=4
		  http://bugs.freedesktop.org/show_bug.cgi?id=29536
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <brian.bloniarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-16 17:57 (97 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-11 20:31 (102 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Date		: 2010-06-12 04:17 (101 days old)
Handled-By	: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16396
Subject		: [bisected] resume from suspend freezes system
Submitter	: tomas m <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-15 02:32 (68 days old)
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=30822


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 9:40 (85 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
		  http://lkml.indiana.edu/hypermail/linux/kernel/1007.3/00884.html
Handled-By	: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=30282


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.34 and 2.6.35, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
