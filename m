From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.34-rc3-git6: Reported regressions from 2.6.33
Date: Wed,  7 Apr 2010 23:08:30 +0200 (CEST)
Message-ID: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NOTE:
 The summary report of post-2.6.32 regressions will be sent later
 (hopefully tomorrow).]

This message contains a list of some regressions from 2.6.33,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.33, please let=
 us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15719
Subject		: virtio_net causing kernel BUG when running under VirtualBox
Submitter	: Thomas M=C3=BCller <thomas@mathtm.de>
Date		: 2010-03-27 14:32 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/9ab86bbcf8be755256f=
0a5e994e0b38af6b4d399
Message-ID	: <4BAE1707.2050803@mathtm.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970039227740&w=3D=
4
Handled-By	: Shirley Ma <mashirle@us.ibm.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15718
Subject		: File corruption regression on NFS related to commit 1f36f774
Submitter	: Boaz Harrosh <bharrosh@panasas.com>
Date		: 2010-03-24 15:49 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/1f36f774b22a0ceb7dd=
33eca626746c81a97b6a5
Message-ID	: <4BAA3493.1030802@panasas.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126944579810350&w=3D=
4
Handled-By	: Al Viro <viro@zeniv.linux.org.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15717
Subject		: bluetooth oops
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-03-14 20:14 (25 days old)
Message-ID	: <20100314201434.GE22059@elf.ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126859771528426&w=3D=
4
Handled-By	: Marcel Holtmann <marcel@holtmann.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15716
Subject		: ata2: lost interrupt with kernel 2.6.34-rc1
Submitter	: Andrew Benton <b3nton@gmail.com>
Date		: 2010-03-11 16:57 (28 days old)
Message-ID	: <4B992110.2090300@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126832670609705&w=3D=
4
Handled-By	: Jeff Garzik <jeff@garzik.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15715
Subject		: vmscan: underflow for get_scan_ratio
Submitter	: Shaohua Li <shaohua.li@intel.com>
Date		: 2010-03-30 5:53 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/84b18490d1f1bc7ed50=
95c929f78bc002eb70f26
Message-ID	: <20100330055304.GA2983@sli10-desk.sh.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126992842105754&w=3D=
4
Handled-By	: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
		  Wu Fengguang <fengguang.wu@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15713
Subject		: hackbench regression due to commit 9dfc6e68bfe6e
Submitter	: Alex Shi <alex.shi@intel.com>
Date		: 2010-03-25 8:40 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/9dfc6e68bfe6ee452ef=
b1a4e9ca26a9007f2b864
Message-ID	: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126950632920682&w=3D=
4
Handled-By	: Christoph Lameter <cl@linux-foundation.org>
		  Pekka Enberg <penberg@cs.helsinki.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15712
Subject		: [regression] 2.6.34-rc1 to -rc3 on zaurus: no longer boots
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-04-01 6:06 (7 days old)
Message-ID	: <20100401060624.GA1329@ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127010200817402&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15711
Subject		: 2.6.34-rc3, BUG at mm/slab.c:2989
Submitter	: Heinz Diehl <htd@fancy-poultry.org>
Date		: 2010-04-01 17:52 (7 days old)
Message-ID	: <20100401175225.GA6581@fancy-poultry.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127014437406250&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-03-31 10:21 (8 days old)
Message-ID	: <20100331102142.GA3294@swordfish.minsk.epam.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15674
Subject		: [2.6.34-rc2 NFS4 oops] open error path failure...
Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
Date		: 2010-03-29 18:36 (10 days old)
Message-ID	: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.co=
m>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126988782722711&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-03-28 11:31 (11 days old)
Message-ID	: <1269775909.5301.4.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15672
Subject		: KVM bug, git bisected
Submitter	: Kent Overstreet <kent.overstreet@gmail.com>
Date		: 2010-03-27 12:43 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/5beb49305251e566985=
2ed541e8e2f2f7696c53e
Message-ID	: <4BADFD74.8060904@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126969385121711&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15671
Subject		: intel graphic card hanging (Hangcheck timer elapsed... GPU h=
ung)
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2010-03-27 16:11 (12 days old)
Message-ID	: <20100327161104.GA12043@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970883105262&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15669
Subject		: INFO: suspicious rcu_dereference_check()
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-03-08 1:26 (31 days old)
Message-ID	: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58@mail.gmail.c=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126801163107713&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15668
Subject		: start_kernel(): bug: interrupts were enabled early
Submitter	: Rabin Vincent <rabin@rab.in>
Date		: 2010-03-25 19:53 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/773e3eb7b81e5ba13b5=
155dfb3bb75b8ce37f8f9
Message-ID	: <20100325194100.GA2364@debian>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954607216519&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-04-01 01:09 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15661
Subject		: PROBLEM: crash on halt with 2.6.34-0.16.rc2.git0.fc14.x86_64
Submitter	: Jon Masters <jonathan@jonmasters.org>
Date		: 2010-03-26 15:29 (13 days old)
Message-ID	: <1269617372.3779.234.camel@localhost>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126961739803949&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15659
Subject		: [Regresion] [2.6.34-rc1] [drm:i915_hangcheck_elapsed] *ERROR=
* Hangcheck timer elapsed... GPU hung
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2010-03-25 20:04 (14 days old)
Message-ID	: <201003252104.24965.maciej.rutecki@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954749618319&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15655
Subject		: corrupt ext3 fs and partial freeze
Submitter	: Alban Browaeys <prahal@yahoo.com>
Date		: 2010-03-30 08:25 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15625
Subject		: BUG: 2.6.34-rc1, RIP is (null)
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-03-18 22:22 (21 days old)
Message-ID	: <4BA2A7A9.4080503@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126895098217351&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15624
Subject		: [BUG] percpu misaligned allocation
Submitter	: Frederic Weisbecker <fweisbec@gmail.com>
Date		: 2010-03-18 4:49 (21 days old)
Message-ID	: <20100318044930.GC5045@nowhere>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126888780031992&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15619
Subject		: Regression - Linux 2.6.34-rc1 - i915 - Render error detected
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2010-03-17 21:58 (22 days old)
Message-ID	: <b637ec0b1003171458t524d168fiab52ce2b3431e3c9@mail.gmail.c=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126886311908558&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15615
Subject		: NULL pointer deref in task_is_waking
Submitter	: Amit Shah <shahamit@gmail.com>
Date		: 2010-03-23 04:04 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15611
Subject		: Failure with the 2.6.34-rc1 kernel
Submitter	: Rupjyoti Sarmah <rsarmah@amcc.com>
Date		: 2010-03-16 15:45 (23 days old)
Message-ID	: <AC311A8E81420D4EBC1F26E6479848FE065B7D3D@SDCEXCHANGE01.ad=
=2Eamcc.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126875435718396&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15610
Subject		: fsck leads to swapper - BUG: unable to handle kernel NULL po=
inter dereference & panic
Submitter	: Ozgur Yuksel <ozgur.yuksel@oracle.com>
Date		: 2010-03-22 15:59 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15603
Subject		: lockdep warning at boot time when determining whether to res=
ume
Submitter	: Sami Liedes <sliedes@cc.hut.fi>
Date		: 2010-03-22 00:03 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15601
Subject		: [BUG] SLOB breaks Crypto
Submitter	: michael-dev@fami-braun.de
Date		: 2010-03-15 13:39 (24 days old)
Message-ID	: <4B9E38AF.70309@fami-braun.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126866044724539&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15600
Subject		: CONFIG_NO_BOOTMEM woes, 2.6.34-rc1
Submitter	: Avi Kivity <avi@redhat.com>
Date		: 2010-03-15 15:28 (24 days old)
Message-ID	: <4B9E5211.9000204@redhat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126866691701926&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15590
Subject		: 2.6.34-rc1: regression: ^Z no longer stops sound
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-03-14 7:58 (25 days old)
Message-ID	: <20100314075831.GA13457@elf.ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126855353122623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists@nerdbynature.de>
Date		: 2010-03-13 23:53 (26 days old)
Message-ID	: <alpine.DEB.2.01.1003131544340.5493@bogon.housecafe.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15553
Subject		: Screen backlight doesn't come back on after lid was closed (=
GM45)
Submitter	:  <bugs@kaijauch.de>
Date		: 2010-03-17 14:35 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15551
Subject		: WARNING: at net/mac80211/work.c:811 ieee80211_work_work+0x7f=
/0xde8 [mac80211]()
Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
Date		: 2010-03-16 22:03 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15518
Subject		: CONFIG_NO_BOOTMEM=3Dy breaks boot on 32bit
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2010-03-11 15:37 (28 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15505
Subject		: No more b43 wireless interface since 2.6.34-rc1
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-03-10 06:59 (29 days old)
Handled-By	: Yinghai Lu <yinghai@kernel.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D15505#c11


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15480
Subject		: [regression] Fails to boot properly unless given pci=3Dnocrs
Submitter	: Yanko Kaneti <yaneti@declera.com>
Date		: 2010-03-09 01:24 (30 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch		: http://lkml.org/lkml/2010/3/11/512


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.33,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D15310

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
