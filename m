From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc3-git3: Reported regressions from 2.6.32
Date: Sun, 10 Jan 2010 23:27:15 +0100 (CET)
Message-ID: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754162Ab0AJWev@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
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
  2010-01-10       55       33          21
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15043
Subject		: Display goes off with i915.powersave=3D1
Submitter	: Soeren Sonnenburg <sonne@debian.org>
Date		: 2010-01-10 20:09 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126315457519505&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15041
Subject		: Pagemap endless read loop with LTP
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2010-01-10 2:09 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126308941423848&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15038
Subject		: drm/ksm: fbdev blanking regression
Submitter	: Johan Hovold <jhovold@gmail.com>
Date		: 2010-01-06 17:00 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D731b5a15a3b1474a41c2ca29b4c32b0f21bc852e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279726418748&w=3D=
4
Handled-By	: James Simmons <jsimmons@infradead.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15036
Subject		: soft lockup in dmesg after suspend/resume
Submitter	: ykzhao <yakui.zhao@intel.com>
Date		: 2010-01-04 5:36 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126258356202722&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15035
Subject		: BUG: unable to handle kernel paging request in rs600_gart_se=
t_page()
Submitter	: Xiaotian Feng <dfeng@redhat.com>
Date		: 2010-01-05 19:10 (6 days old)
References	: http://lkml.org/lkml/2010/1/5/95


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15033
Subject		: drm: gem_object_free without struct_mutex
Submitter	: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Date		: 2009-12-30 19:45 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126220236201529&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15032
Subject		: Oops in uart_resume_port() on resume
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-01-04 15:47 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dba15ab0e8de0d4439a91342ad52d55ca9e313f3d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126262008815689&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14976
Subject		: No sound on snd_hda_codec_via in 2.6.33-rc2
Submitter	: Mark Rosenstand <rosenstand@gmail.com>
Date		: 2010-01-02 08:27 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14954
Subject		: warning from alloc_pages_nodemask on boot -- caused by commi=
t 78f1699659963fff97975df44db6d5dbe7218e55
Submitter	: Stephen Hemminger <shemminger@linux-foundation.org>
Date		: 2009-12-29 19:57 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78f1699659963fff97975df44db6d5dbe7218e55
Handled-By	: Alex Chiang <achiang@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-12-25 11:11 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14949
Subject		: drm_vm.c:drm_mmap: possible circular locking dependency dete=
cted
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:45 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182073616279&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14948
Subject		: EHCI resume sysfs duplicates
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:36 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182020615709&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14946
Subject		: All kernels after 2.6.32-git10  show only 1 CPU
Submitter	: Sid Boyce <sboyce@blueyonder.co.uk>
Date		: 2009-12-23 16:55 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126158734326801&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:35 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14934
Subject		: kernel crash during boot
Submitter	: werner <w.landgraf@ru.ru>
Date		: 2009-12-25 5:37 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126171951030608&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14925
Subject		: sky2 panic under load
Submitter	: Berck E. Nash <flyboy@gmail.com>
Date		: 2009-12-21 23:52 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126143955730347&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126160893126548&w=3D4
Handled-By	: Stephen Hemminger <shemminger@vyatta.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14924
Subject		: Weird hard hangs when rendering 'some' web-sites in Firefox
Submitter	: David <david@unsolicited.net>
Date		: 2009-12-21 21:53 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126143375823340&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14860
Subject		: No DP-DVI output when laptop is docked
Submitter	: P=C3=A4r Andersson <paran@lysator.liu.se>
Date		: 2009-12-21 21:02 (21 days old)
Handled-By	: ykzhao <yakui.zhao@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14859
Subject		: System timer firing too much without cause
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2009-12-21 19:16 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi@agolina.net>
Date		: 2009-12-12 13:28 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14791
Subject		: Something has been broken in the network stack this week
Submitter	: Delete This Account <speedyboyinovator@hotmail.com>
Date		: 2009-12-12 13:06 (30 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15039
Subject		: leds_alix2: can't allocate I/O for GPIO
Submitter	: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date		: 2010-01-07 10:26 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126286001106257&w=3D=
4
Handled-By	: Daniel Mack <daniel@caiaq.de>
Patch		: http://patchwork.kernel.org/patch/72006/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15037
Subject		: BUG during shutdown - bisected to commit e2912009
Submitter	: Marc Dionne <marc.c.dionne@gmail.com>
Date		: 2010-01-02 0:27 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126239207631034&w=3D=
4
Handled-By	: Xiaotian Feng <dfeng@redhat.com>
Patch		: http://patchwork.kernel.org/patch/71537/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15034
Subject		: volano ~30% regression
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2010-01-04 8:15 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126259391411982&w=3D=
4
Handled-By	: Mike Galbraith <efault@gmx.de>
Patch		: http://patchwork.kernel.org/patch/70623/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15031
Subject		: bug in fs/btrfs/ordered-data.c:672
Submitter	: Carlos R. Mafra <crmafra2@gmail.com>
Date		: 2010-01-02 11:32 (9 days old)
References	: http://lkml.org/lkml/2010/1/2/17
Handled-By	: Yan, Zheng <yanzheng@21cn.com>
Patch		: http://www.mail-archive.com/linux-btrfs@vger.kernel.org/msg036=
86.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15026
Subject		: i915: Resume regression on MSI Wind U100 w/o KMS
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2010-01-08 23:45 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126299433427673&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://patchwork.kernel.org/patch/71887/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14974
Subject		: tg3 does not resume from hibernation properly on BCM5787M
Submitter	: Chow Loong Jin <hyperair@ubuntu.com>
Date		: 2010-01-02 05:30 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D87668d352aa8d135bd695a050f18bbfc7b50b506
Handled-By	: Matt Carlson <mcarlson@broadcom.com>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D14974#c12


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14957
Subject		: Blank screen with KMS enabled
Submitter	: Philipp Kohlbecher <xt28@gmx.de>
Date		: 2009-12-30 00:08 (12 days old)
Handled-By	: Zhao Yakui <yakui.zhao@intel.com>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D24476


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14944
Subject		: 2.6.32.2 SATA link detect failed, 2.6.32.1 works fine
Submitter	: fengxiangjun <fengxiangjun@neusoft.com>
Date		: 2009-12-21 11:12 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126139442328314&w=3D=
4
Handled-By	: Tejun Heo <tj@kernel.org>
Patch		: http://patchwork.kernel.org/patch/69746/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14942
Subject		: gkrellm no longer shows all the temperatures on thinkpad x60
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-12-27 21:57 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126195107005565&w=3D=
4
Handled-By	: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Patch		: http://patchwork.kernel.org/patch/69809/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14907
Subject		: Commit "kbuild: fix bzImage build for x86" breaks build
Submitter	: Oliver Hartkopp <oliver@hartkopp.net>
Date		: 2009-12-19 19:21 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D4a2ff67c88211026afcbdbc190c13f705dae1b59
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126125050622195&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126114565103300&w=3D4
		  http://marc.info/?l=3Dlinux-kbuild&m=3D126202819526623&w=3D2
Handled-By	: Jonathan Nieder <jrnieder@gmail.com>
Patch		: http://thread.gmane.org/gmane.linux.kbuild.devel/4313/focus=3D=
4319
		  http://patchwork.kernel.org/patch/71957/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14899
Subject		: reiserfs: inconsistent lock state
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-12-11 22:06 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126056920702515&w=3D=
4
Handled-By	: Frederic Weisbecker <fweisbec@gmail.com>
Patch		: http://patchwork.kernel.org/patch/67256/
		  http://patchwork.kernel.org/patch/67257/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14874
Subject		: Ath5k regression with commit 8bf3d79bc401ca417ccf9fc076d3295=
d1a71dbf5
Submitter	: Joshua Covington <joshuacov@googlemail.com>
Date		: 2009-12-25 00:49 (17 days old)
Handled-By	: Luis R. Rodriguez <mcgrof@gmail.com>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D24335


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
