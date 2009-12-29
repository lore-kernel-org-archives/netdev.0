From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.33-rc2: Reported regressions from 2.6.32
Date: Tue, 29 Dec 2009 16:05:30 +0100 (CET)
Message-ID: <LptzGUUXbTK.A.MSF.ymhOLB@chimera>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752277AbZL2PI4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * There you go, another round of tracking regressions.  It's not too b=
ad at
   the moment, as far as the regressions from 2.6.32 are concerned, but=
 we have
   quite a few -stable regressions, apparently in the DRI area.
 * Regressions from 2.6.31 are still being reported.]

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
  2009-12-29       36       34          27


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14952
Subject		: instant reboot on loading 2.6.33-rc on Celeron 900
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2009-12-29 13:57 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126209508500393&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14950
Subject		: tbench regression with 2.6.33-rc1
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-12-25 11:11 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174044213172&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14949
Subject		: drm_vm.c:drm_mmap: possible circular locking dependency dete=
cted
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:45 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182073616279&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14948
Subject		: EHCI resume sysfs duplicates
Submitter	: Borislav Petkov <petkovbb@googlemail.com>
Date		: 2009-12-26 9:36 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126182020615709&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14947
Subject		: Blank screen for Intel KMS
Submitter	: Miguel Calleja <mcalleja1@telecable.es>
Date		: 2009-12-25 13:10 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfc816655236cd9da162356e96e74c7cfb0834d92
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126174693019098&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14946
Subject		: All kernels after 2.6.32-git10  show only 1 CPU
Submitter	: Sid Boyce <sboyce@blueyonder.co.uk>
Date		: 2009-12-23 16:55 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126158734326801&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14942
Subject		: gkrellm no longer shows all the temperatures on thinkpad x60
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-12-27 21:57 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126195107005565&w=3D=
4
Handled-By	: Henrique de Moraes Holschuh <hmh@hmh.eng.br>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14940
Subject		: cfq-iosched: tiobench regression
Submitter	: Shaohua Li <shaohua.li@intel.com>
Date		: 2009-12-24 0:55 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126161612401994&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14938
Subject		: Unable to handle kernel paging request in radeon_fence_signa=
led
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:40 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192123104047&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14937
Subject		: WARNING: at kernel/lockdep.c:2830
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-12-27 13:35 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192220404829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14936
Subject		: kernel BUG at fs/ext4/inode.c:1063 if attempted to use non-e=
xt4 partition with ext4
Submitter	: Gene Heskett <gene.heskett@verizon.net>
Date		: 2009-12-26 14:13 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126183682330809&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126169372613898&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14934
Subject		: kernel crash during boot
Submitter	: werner <w.landgraf@ru.ru>
Date		: 2009-12-25 5:37 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126171951030608&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14925
Subject		: sky2 panic under load
Submitter	: Berck E. Nash <flyboy@gmail.com>
Date		: 2009-12-21 23:52 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126143955730347&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126160893126548&w=3D4
Handled-By	: Stephen Hemminger <shemminger@vyatta.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14924
Subject		: Weird hard hangs when rendering 'some' web-sites in Firefox
Submitter	: David <david@unsolicited.net>
Date		: 2009-12-21 21:53 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126143375823340&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14923
Subject		: Regression in 2.6.32.2: segfault on halt
Submitter	: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Date		: 2009-12-19 15:10 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126123574505069&w=3D=
4
Handled-By	: Mike Galbraith <efault@gmx.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14910
Subject		: Stable version 2.6.32.2 broke my KMS Radeon setup
Submitter	: Ruud Linders <kernelml@xs4all.nl>
Date		: 2009-12-20 12:02 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126131105608871&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14909
Subject		: pata_cmd64x broken in 2.6.33-rc1
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2009-12-19 22:23 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd43744390e460dce6626fb8de2c02a24ff650005
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126126142501594&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14908
Subject		: 256MB CF card no longer recognized in PCMCIA slot
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-12-19 21:55 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126125973632173&w=3D=
4
Handled-By	: Dominik Brodowski <linux@dominikbrodowski.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14907
Subject		: Commit "kbuild: fix bzImage build for x86" breaks build
Submitter	: Oliver Hartkopp <oliver@hartkopp.net>
Date		: 2009-12-19 19:21 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D4a2ff67c88211026afcbdbc190c13f705dae1b59
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126125050622195&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126114565103300&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14904
Subject		: slab: possible recursive locking detected
Submitter	: Heiko Carstens <heiko.carstens@de.ibm.com>
Date		: 2009-12-18 11:58 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126113754023909&w=3D=
4
Handled-By	: Pekka Enberg <penberg@cs.helsinki.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14901
Subject		: bisected crash due to "x86: Move swiotlb initialization befo=
re dma32_free_bootmem"
Submitter	: Roland Dreier <rdreier@cisco.com>
Date		: 2009-12-15 7:47 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126086324302061&w=3D=
4
Handled-By	: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
		  Yinghai Lu <yinghai@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14900
Subject		: drm_i915 error
Submitter	: Tarkan Erimer <tarkane@netone.com.tr>
Date		: 2009-12-14 12:50 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126079504930147&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14890
Subject		: [WMI?] boot hang
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-12-25 10:10 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D3e9b988e4edf065d39c1343937f717319b1c1065
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126173586309724&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D126170348921630&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14887
Subject		: suspend doesn't work on X200s
Submitter	: Andrew Lutomirski <luto@mit.edu>
Date		: 2009-12-22 0:45 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126144274102396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14844
Subject		: No more wireless interface eth1 after boot
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-12-19 16:33 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14792
Subject		: Misdetection of the TV output
Submitter	: Santi <santi@agolina.net>
Date		: 2009-12-12 13:28 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14791
Subject		: Something has been broken in the network stack this week
Submitter	: Delete This Account <speedyboyinovator@hotmail.com>
Date		: 2009-12-12 13:06 (18 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14951
Subject		: lockdep possible recursive lock in slab parent->list->rlock
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2009-12-27 12:06 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126191560531463&w=3D=
4
Handled-By	: Pekka Enberg <penberg@cs.helsinki.fi>
Patch		: http://patchwork.kernel.org/patch/69829/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14944
Subject		: 2.6.32.2 SATA link detect failed, 2.6.32.1 works fine
Submitter	: fengxiangjun <fengxiangjun@neusoft.com>
Date		: 2009-12-21 11:12 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126139442328314&w=3D=
4
Handled-By	: Tejun Heo <tj@kernel.org>
Patch		: http://patchwork.kernel.org/patch/69746/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14941
Subject		: agpgart-amd64 not initialized
Submitter	: Marin Mitov <mitov@issp.bas.bg>
Date		: 2009-12-27 15:19 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126192729110083&w=3D=
4
Handled-By	: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Patch		: http://patchwork.kernel.org/patch/69956/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14935
Subject		: hd-audio0 eats 25% CPU (according to top)
Submitter	: Sergei Trofimovich <slyich@gmail.com>
Date		: 2009-12-25 10:21 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126173644210280&w=3D=
4
Handled-By	: Takashi Iwai <tiwai@suse.de>
Patch		: http://patchwork.kernel.org/patch/69747/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14906
Subject		: boot problem bisected to commit 99935a7a59
Submitter	: Vincent ETIENNE <ve@vetienne.net>
Date		: 2009-12-19 16:07 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126123946509316&w=3D=
4
Handled-By	: Yinghai Lu <yinghai@kernel.org>
Patch		: http://patchwork.kernel.org/patch/68941/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14899
Subject		: reiserfs: inconsistent lock state
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-12-11 22:06 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126056920702515&w=3D=
4
Handled-By	: Frederic Weisbecker <fweisbec@gmail.com>
Patch		: http://patchwork.kernel.org/patch/67256/
		  http://patchwork.kernel.org/patch/67257/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14846
Subject		: acer-wmi kernel OOPS, cannot create duplicit sysfs name
Submitter	: Old=C5=99ich Jedli=C4=8Dka <oldium.pro@seznam.cz>
Date		: 2009-12-19 23:44 (11 days old)
Handled-By	: Carlos Corbacho <carlos@strangeworlds.co.uk>
Patch		: http://patchwork.kernel.org/patch/69795/


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
