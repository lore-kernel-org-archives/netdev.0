From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.34-rc6-git6: Reported regressions from 2.6.33
Date: Sun,  9 May 2010 23:13:46 +0200 (CEST)
Message-ID: <10aqDnTJcLO.A.mLE.48y5LB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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
  2010-05-09       80       27          24
  2010-05-04       76       26          22
  2010-04-20       64       35          34
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15951
Subject		: commit 9630bdd9 changes behavior of the poweroff
Submitter	: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Date		: 2010-04-01 13:39 (39 days old)
Message-ID	: <20100401133923.GA4104-VqjxzfR4DlwKmadIfiO5sKVXKuFTiq87@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127012918316305&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15936
Subject		: Suspicious rcu_dereference_check() usage detected during 2.6=
=2E34-rc6 boot on PPC64/p5 processor
Submitter	: Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2010-05-06 7:29 (4 days old)
Message-ID	: <1273130279.4898.5.camel-NRFfyExJdYpgXGGE5LP+UZlqa2bBAFbm0E9HWUfgJXw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127313031922395&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15935
Subject		: [BUG] btrfs: report a direct-IO bug
Submitter	: liubo <liubo2009-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date		: 2010-05-06 1:47 (4 days old)
Message-ID	: <4BE21FC1.1010901-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127311036803487&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15924
Subject		: kacpid consumes ~100% CPU, system freezes randomly
Submitter	: Jaroslav Kamen=C3=ADk <jaroslav-FZZqD5xcwZ7rBKCeMvbIDA@public.gmane.org>
Date		: 2010-05-06 21:12 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15909
Subject		: open("a/",O_NOFOLLOW) fails with ELOOP if "a" is a symbolic =
link to a directory.
Submitter	: Marius Tolzmann <tolzmann-KUpvgZVWgV9o1qOY/usvUg@public.gmane.org>
Date		: 2010-05-05 13:01 (5 days old)
Handled-By	: OGAWA Hirofumi <hirofumi-UIVanBePwB70ZhReMnHkpc8NsWr+9BEh@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15880
Subject		: Very bad regression from 2.6.33 as of 1600f9def
Submitter	: Alex Elsayed <eternaleye-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-29 2:28 (11 days old)
Message-ID	: <loom.20100429T041908-663-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127250825306178&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15863
Subject		: 2.6.34-rc5-git7 (plus all patches) -- another suspicious rcu=
_dereference_check() usage.
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-27 0:51 (13 days old)
Message-ID	: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127232949104878&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15862
Subject		: 2.6.34-rc4/5: iwlagn unusable until reload
Submitter	: Nico Schottelius <nico-linux-20100427-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2010-04-27 7:49 (13 days old)
Message-ID	: <20100427074934.GB3261-9ll+q7fL1vOwdVNcq5OhcUB+6BGkLq7r@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127235784004839&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15858
Subject		: [2.6.34-rc5] bad page state copying to/from HFS+ filesystem.=
=2E.
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-25 21:14 (15 days old)
Message-ID	: <v2k6278d2221004251414kbbcc41baw78b86120d81dce7d-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127223008621881&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15805
Subject		: reiserfs locking
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-15 21:02 (25 days old)
Message-ID	: <t2ka4423d671004151402n7b2dc425mdc9c6bb9640d63fb-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127136535323933&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15788
Subject		: external usb sound card doesn't work after resume
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2010-04-15 10:16 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15717
Subject		: bluetooth oops
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-14 20:14 (57 days old)
Message-ID	: <20100314201434.GE22059-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126859771528426&w=3D=
4
Handled-By	: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15713
Subject		: hackbench regression due to commit 9dfc6e68bfe6e
Submitter	: Alex Shi <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-25 8:40 (46 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/9dfc6e68bfe6ee452efb1a4=
e9ca26a9007f2b864
Message-ID	: <1269506457.4513.141.camel-c8rhgrCDLIED0+JXs3kMbRL4W9x8LtSr@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126950632920682&w=3D=
4
Handled-By	: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
		  Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15712
Subject		: [regression] 2.6.34-rc1 to -rc3 on zaurus: no longer boots
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-04-01 6:06 (39 days old)
Message-ID	: <20100401060624.GA1329-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127010200817402&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-31 10:21 (40 days old)
Message-ID	: <<<20100331102142.GA3294-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-03-28 11:31 (43 days old)
Message-ID	: <1269775909.5301.4.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15671
Subject		: intel graphic card hanging (Hangcheck timer elapsed... GPU h=
ung)
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2010-03-27 16:11 (44 days old)
Message-ID	: <20100327161104.GA12043-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970883105262&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15669
Subject		: INFO: suspicious rcu_dereference_check()
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-08 1:26 (63 days old)
Message-ID	: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58-JsoAwUIsXounXO2b/Sh1tA@public.gmane.org=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126801163107713&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2010-04-01 01:09 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15659
Subject		: [Regresion] [2.6.34-rc1] [drm:i915_hangcheck_elapsed] *ERROR=
* Hangcheck timer elapsed... GPU hung
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-25 20:04 (46 days old)
Message-ID	: <<201003252104.24965.maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954749618319&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15610
Subject		: fsck leads to swapper - BUG: unable to handle kernel NULL po=
inter dereference & panic
Submitter	: Ozgur Yuksel <ozgur.yuksel-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-03-22 15:59 (49 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15601
Subject		: [BUG] SLOB breaks Crypto
Submitter	: michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org
Date		: 2010-03-15 13:39 (56 days old)
Message-ID	: <4B9E38AF.70309-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126866044724539&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15590
Subject		: 2.6.34-rc1: regression: ^Z no longer stops sound
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-14 7:58 (57 days old)
Message-ID	: <<20100314075831.GA13457-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126855353122623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
Date		: 2010-03-13 23:53 (58 days old)
Message-ID	: <<alpine.DEB.2.01.1003131544340.5493-uKsf7x9sgtqQ/Pez2Lbyp4QuADTiUCJX@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15768
Subject		: Incorrectly calculated free blocks result in ENOSPC from wri=
tepage
Submitter	: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date		: 2010-04-12 11:24 (28 days old)
Handled-By	: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Patch		: http://patchwork.ozlabs.org/patch/49989/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15729
Subject		: BUG: physmap modprobe & rmmod
Submitter	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-04-02 20:40 (38 days old)
Message-ID	: <20100402134058.c4682716.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127024096210230&w=3D=
2
Handled-By	: Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/90497/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15505
Subject		: No more b43 wireless interface since 2.6.34-rc1
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-03-10 06:59 (61 days old)
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D15505#c11


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
