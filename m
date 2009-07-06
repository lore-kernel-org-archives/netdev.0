From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc2: Reported regressions from 2.6.30
Date: Tue,  7 Jul 2009 01:42:09 +0200 (CEST)
Message-ID: <35kKlbXMqWN.A.RXD.D0oUKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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

[NOTE: I'll be traveling next week, so there won't be a summary report.]

This message contains a list of some regressions from 2.6.30, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=124690524027166&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13732
Subject		: tty layer instabilities
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-07-06 13:43 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=124688781732419&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13731
Subject		: Inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 4:22 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=124685417325348&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13730
Subject		: hitting lockdep limits...
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-05 18:19 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=124681799023782&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13729
Subject		: kernel BUG at fs/notify/notification.c:93!
Submitter	: Mikko C. <mikko.cal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-04 10:16 (33 days old)
References	: http://lkml.org/lkml/2009/7/4/12
Handled-By	: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13728
Subject		: 2.6.31-rc2 soft lockups, RPC-related
Submitter	: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Date		: 2009-07-05 7:17 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=124677884816794&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13727
Subject		: Cannot Recognize Empty DVD Media
Submitter	: Tarkan Erimer <tarkan.erimer-AMZSHK9Z0TXlajqSnzHT9w@public.gmane.org>
Date		: 2009-07-02 16:23 (5 days old)
References	: http://lkml.org/lkml/2009/7/2/178


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13726
Subject		: fio sync read 4k block size 35% regression
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-07-01 11:25 (6 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=51daa88ebd8e0d437289f589af29d4b39379ea76
References	: http://lkml.org/lkml/2009/6/30/679
Handled-By	: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13716
Subject		: The AIC-7892P controller does not work any more
Submitter	: Andrej Podzimek <andrej-+Hii8LNHG6Ng9hUCZPvPmw@public.gmane.org>
Date		: 2009-07-05 19:23 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13700
Subject		: usb error flood in dmesg, makes kde use plenty of cpu - bisected
Submitter	: jouni susiluoto <jouni.susiluoto-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Date		: 2009-07-03 21:13 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13690
Subject		: nodes_clear cause hugepage unusable on non-NUMA machine
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-02 01:22 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13673
Subject		: HIGHMEM64G causes hang in PCI init on 32-bit x86
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-06-26 15:59 (11 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=95ee14e4379c5e19c0897c872350570402014742
References	: http://marc.info/?l=linux-pci&m=124615181602643&w=4
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13667
Subject		: drm: display arifacts when X.Org is stopped
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-06-27 18:52 (10 days old)
References	: http://lkml.org/lkml/2009/6/27/105


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13666
Subject		: WARNING: at mm/page_alloc.c:1743 __alloc_pages_nodemask
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2009-06-27 16:15 (10 days old)
References	: http://lkml.org/lkml/2009/6/27/75


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13661
Subject		: warning in smp_call_function_single while S2R
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2009-06-27 17:12 (10 days old)
References	: http://lkml.org/lkml/2009/6/27/80


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13657
Subject		: Linux-2.6.31-rc1 Fails To Recognize Some USB Disks
Submitter	: Tarkan Erimer <tarkan.erimer-AMZSHK9Z0TXlajqSnzHT9w@public.gmane.org>
Date		: 2009-06-26 10:03 (11 days old)
References	: http://lkml.org/lkml/2009/6/26/34


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13656
Subject		: 2.6.31-rc1 crashes randomly on my Machine.
Submitter	: Zeno Davatz <zdavatz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-26 08:56 (11 days old)
References	: http://lkml.org/lkml/2009/6/26/27


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13652
Subject		: scheduling while atomic: pptpgw
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-A/MS7pq9VAU@public.gmane.org>
Date		: 2009-06-19 21:15 (18 days old)
References	: http://lkml.org/lkml/2009/6/19/237


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13650
Subject		: Problem with alloc_arch_preferred_bootmem() on powerpc
Submitter	: Sean MacLennan <smaclennan-Qtffpm9i2AVWk0Htik3J/w@public.gmane.org>
Date		: 2009-06-20 19:48 (17 days old)
References	: http://marc.info/?l=linuxppc-embedded&m=124552732411775&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (20 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13522
Subject		: BUG: scheduling while atomic
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-A/MS7pq9VAU@public.gmane.org>
Date		: 2009-06-12 19:29 (25 days old)
References	: http://lkml.org/lkml/2009/6/29/237


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13734
Subject		: regression in 2.6.31-rcX since commit a1091aa
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2009-07-06 19:07 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=124690725130645&w=4
Handled-By	: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/34292/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13665
Subject		: commit 69c854817566 causes OOMs
Submitter	: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-06-27 08:12 (10 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=69c854817566db82c362797b4a6521d0b00fe1d8
References	: http://lkml.org/lkml/2009/6/27/28
Handled-By	: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/32740/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13659
Subject		: iwlagn (4965): no wireless due to RFKILL problem
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-06-26 13:36 (11 days old)
References	: http://lkml.org/lkml/2009/6/26/127
Handled-By	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/6/27/35


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13643
Subject		: Touchpad lost synchronization after resume from suspend to RAM
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml-VIXq6x/3rUk@public.gmane.org>
Date		: 2009-06-28 10:42 (9 days old)
References	: http://lkml.org/lkml/2009/6/23/365
		  2.6.30-rc1: touchpad disabled
		  http://lkml.org/lkml/2009/6/25/256
Handled-By	: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/34075/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=13615

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael
