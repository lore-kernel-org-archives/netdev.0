From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.36-rc3-git5: Reported regressions 2.6.34 -> 2.6.35
Date: Sun, 12 Sep 2010 21:07:07 +0200 (CEST)
Message-ID: <QnCvudbe2FD.A.XiE.DgSjMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
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
  2010-09-12      135       26          25
  2010-08-30      124       38          34
  2010-08-01      100       27          23
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18272
Subject		: 2.6.35.*: horrible (exponential? >linear) slowdown to unusability (ACPI idle?)
Submitter	: Nix <nix@esperi.org.uk>
Date		: 2010-09-05 0:51 (8 days old)
First-Bad-Commit: http://git.kernel.org/linus/30a564be9d9554c168a654eddc2165869cc0d7bf
Message-ID	: <87zkvx2ese.fsf@spindle.srvr.nix>
References	: http://marc.info/?l=linux-kernel&m=128364994602942&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18202
Subject		: Microphone levels too low
Submitter	: Alexander Hunziker <alex.hunziker@rega-sense.ch>
Date		: 2010-09-09 22:20 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18032
Subject		: No sound on headphone jack
Submitter	: Alexander Hunziker <alex.hunziker@rega-sense.ch>
Date		: 2010-09-07 21:45 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17812
Subject		: Kernel completely frozen when memory is full
Submitter	: Mickey86 <mikael.cordon@gmail.com>
Date		: 2010-09-05 13:09 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17772
Subject		: Unable to locate IOAPIC for GSI *
Submitter	: zersaa <zersaa@gmail.com>
Date		: 2010-09-04 21:28 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17732
Subject		: [2.6.35.x regression] rcu_preempt_state stall warning and machine slow-downs
Submitter	: Matthias Dahl <ml_kernel@mortal-soul.de>
Date		: 2010-09-01 6:47 (12 days old)
Message-ID	: <201009010847.20236.ml_kernel@mortal-soul.de>
References	: http://marc.info/?l=linux-kernel&m=128332418629305&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16771
Subject		: [Bisected Regression in 2.6.35] A full tmpfs filesystem causes hibernationto hang
Submitter	: M. Vefa Bicakci <bicave@superonline.com>
Date		: 2010-08-15 5:25 (29 days old)
First-Bad-Commit: http://git.kernel.org/linus/bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
Message-ID	: <4C677A49.4030904@superonline.com>
References	: http://marc.info/?l=linux-kernel&m=128184995401968&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16691
Subject		: IPW5100: iwlagn broken with 2.6.34.x to 2.6.35.2 update
Submitter	: Can Celasun <dcelasun@gmail.com>
Date		: 2010-08-21 08:28 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16633
Subject		: ath5k + 2.6.35 x86 + hostapd - Failed to set channel
Submitter	: NiTr0 <nitr0@seti.kr.ua>
Date		: 2010-08-19 19:37 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16614
Subject		: [2.6.35] usb 2.0 em28xx  kernel panic general protection fault: 0000 [#1] SMP          RIP: 0010:[<ffffffffa004fbc5>]  [<ffffffffa004fbc5>] em28xx_isoc_copy_vbi+0x62e/0x812 [em28xx]
Submitter	: Sander Eikelenboom <linux@eikelenboom.it>
Date		: 2010-08-10 22:12 (34 days old)
Message-ID	: <61936849.20100811001257@eikelenboom.it>
References	: http://marc.info/?l=linux-kernel&m=128152075830927&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16562
Subject		: 2.6.35: cpu_idle bug report / on i7 870 cpu (x86_64)
Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
Date		: 2010-08-06 22:09 (38 days old)
Message-ID	: <alpine.DEB.2.00.1008061800530.5241@p34.internal.lan>
References	: http://marc.info/?l=linux-kernel&m=128113260904048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16549
Subject		: 2.6.35: suspicious rcu_dereference_check() usage
Submitter	: Vladislav Bolkhovitin <vst@vlnb.net>
Date		: 2010-08-04 10:56 (40 days old)
Message-ID	: <4C594740.1090608@vlnb.net>
References	: http://marc.info/?l=linux-kernel&m=128091938215177&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16537
Subject		: TREE_RCU hangs at boot
Submitter	: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date		: 2010-08-07 12:18 (37 days old)
Handled-By	: Paul E. McKenney <paulmck@linux.vnet.ibm.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16532
Subject		: random suspend (S3) problems on Intel DG45ID board
Submitter	: Alexey Fisher <bug-track@fisher-privat.net>
Date		: 2010-08-07 08:55 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16525
Subject		: unexpected high load since 2.6.35
Submitter	: MadLoisae@gmx.net <MadLoisae@gmx.net>
Date		: 2010-08-02 20:53 (42 days old)
Message-ID	: <4C573041.1070103@gmx.net>
References	: http://marc.info/?l=linux-kernel&m=128078243726655&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16515
Subject		: [bisected] Radeon rv280 can't boot on kernel 2.6.35.
Submitter	: Albert Gall <ss3vdr@gmail.com>
Date		: 2010-08-04 16:10 (40 days old)
First-Bad-Commit: http://git.kernel.org/linus/https://bugzilla.kernel.org/attachment.cgi?id=27350
Handled-By	: Alex Deucher <alexdeucher@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16495
Subject		: Kernel 2.6.35 takes almost half an hour to boot
Submitter	: Claudio M. Camacho <claudiomkd@gmail.com>
Date		: 2010-08-02 17:16 (42 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16488
Subject		: [i915] Framebuffer ID error after suspend/hibernate leading to X crash
Submitter	: Milan Bouchet-Valat <nalimilan@club.fr>
Date		: 2010-08-01 08:55 (43 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16458
Subject		: Bluetooth disabled after resume
Submitter	: AttilaN <attila123456@gmail.com>
Date		: 2010-07-25 09:33 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2010-07-13 23:21 (62 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_measured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org@boris64.net>
Date		: 2010-07-01 13:54 (74 days old)
Handled-By	: H. Peter Anvin <hpa@zytor.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2010-06-09 18:36 (96 days old)
First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb@closure.thunk.org>
References	: http://marc.info/?l=linux-kernel&m=127610857819033&w=4
		  http://bugs.freedesktop.org/show_bug.cgi?id=29536
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <phunge0@hotmail.com>
Date		: 2010-06-16 17:57 (89 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-06-11 20:31 (94 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp@safe.ca>
Date		: 2010-06-12 04:17 (93 days old)
Handled-By	: Patrick McHardy <kaber@trash.net>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-06-28 9:40 (77 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
		  http://lkml.indiana.edu/hypermail/linux/kernel/1007.3/00884.html
Handled-By	: Jan Kara <jack@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27272


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.34 and 2.6.35, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
