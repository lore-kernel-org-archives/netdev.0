From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Thu, 16 Apr 2009 23:42:31 +0200 (CEST)
Message-ID: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
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

This message contains a list of some regressions from 2.6.29, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.29, please let=
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
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13126
Subject		: BUG: MAX_LOCKDEP_ENTRIES too low! when mounting rootfs
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-15 12:43 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979949820538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13125
Subject		: active uvcvideo breaks over suspend
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-04-15 10:12 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979009508840&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13124
Subject		: ioatdma: DMA-API: device driver frees DMA memory with wrong =
function
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-09 12:36 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123928064322503&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13122
Subject		: reiserfs_delete_xattrs: Couldn't delete all xattrs (-13)
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-16 19:23 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123990989515105&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13121
Subject		: commit 1a7c618a3f7bef1a20ae740df512eeba21397fa5 breaks ACPI =
video
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-16 11:37 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1a7c618a3f7bef1a20ae740df512eeba21397fa5
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123988189401913&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-14 21:32 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13118
Subject		: iptables very slow after commit 784544739a25c30637397ace5489=
eeb6e15d7d49
Submitter	: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-10 16:05 (7 days old)
References	: http://lkml.org/lkml/2009/4/10/111
Handled-By	: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13116
Subject		: Can't boot with nosmp
Submitter	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-15 4:18 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123976917817920&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13114
Subject		: USB storage (usbstick) automount woes
Submitter	: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-09 9:26 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De6e244b6cb1f70e7109381626293cd40a8334ed3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123926928907568&w=3D=
4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13112
Subject		: Oops in drain_array
Submitter	: Bart <mmx-G/jkD+u3s4s@public.gmane.org>
Date		: 2009-04-14 10:21 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123970493224628&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13111
Subject		: Linux 2.6.30-rc1 tg3 endian issues with MAC addresses on BCM=
5701
Submitter	: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Date		: 2009-04-08 7:12 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De4f341103e4a2b35f56a0f89802f1b1448e8d04b
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123917477312823&w=3D=
4
Handled-By	: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13110
Subject		: 2.6.30-rc1 problems with firmware loading
Submitter	: Ben Castricum <mail0904-YLO5ZLKhJ/U/fZsR/wcYMA@public.gmane.org>
Date		: 2009-04-12 6:20 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123951774919978&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-11 14:56 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13108
Subject		: 2.6.30-rc1: white screen during boot (regression) on spitz
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-04-10 10:34 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123935954223418&w=3D=
4
Handled-By	: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13107
Subject		: LTP 20080131 causes defunct processes w/2.6.30-rc1
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2009-04-09 15:43 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db3bfa0cba867f23365b81658b47efd906830879b
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123929187208953&w=3D=
4
Handled-By	: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13106
Subject		: 2.6.30-rc1: intel 3945 no wireless
Submitter	: 2.6.30-rc1: intel 3945 no wireless
Date		: 2009-04-08 5:36 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123916905605534&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13101
Subject		: BUG: scheduling while atomic: swapper/0/0x10000100
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-07 7:37 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123908995822195&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13099
Subject		: net, sky2: BUG: unable to handle kernel NULL pointer derefer=
ence, pci_vpd_truncate()
Submitter	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date		: 2009-04-06 9:03 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123900867611321&w=3D=
4
Handled-By	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13098
Subject		: 2.6.29-git12 breaks vga=3D0x0f07 on MSI/Intel GPU
Submitter	: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Date		: 2009-04-06 01:14 (11 days old)
References	: http://lkml.org/lkml/2009/4/5/200
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13097
Subject		: Kernel will freeze network after using a tun/tap device
Submitter	: D=C3=A2niel Fraga <fragabr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-15 22:19 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13087
Subject		: boot hang due to commit ff69f2bba67bd45514923aaedbf40fe35178=
7c59
Submitter	: Bruno <bonbons67-H4aWS73dXupiYsDpGMXq6A@public.gmane.org>
Date		: 2009-04-14 17:51 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dff69f2bba67bd45514923aaedbf40fe351787c59


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13069
Subject		: regression in 2.6.29-git3 on SH/Dreamcast
Submitter	: Adrian McMenamin <adrian-TSF8l6Tg6afpT6hvJLqO3U8SxdOydiOw@public.gmane.org>
Date		: 2009-03-29 19:04 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123835353115372&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13068
Subject		: Lockdep warining in inotify_dev_queue_event
Submitter	: Sachin Sant <sachinp-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-05 12:37 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123893439229272&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13067
Subject		: iwl3945: wlan0: beacon loss from AP - sending probe request
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-05 9:11 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123892272218266&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13066
Subject		: Intel HD Audio oops
Submitter	: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-01 8:28 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123857454625829&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13058
Subject		: First hibernation attempt fails
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-04-10 10:58 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1faa16d22877f4839bd433547d770c676d1d964c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123928022321917&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13044
Subject		: 2.6.30-rc1 can't find the root fs
Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
Date		: 2009-04-08 13:35 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13031
Subject		: Deadlock/hang in SATA probe
Submitter	: Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>
Date		: 2009-04-06 23:33 (11 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13123
Subject		: 20 ACPI interrupts per second on EEEPC 4G
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-04-12 15:54 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123955169317870&w=3D=
4
Handled-By	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123973665713690&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13120
Subject		: BUG: using rootfstype=3Dext4 causes oops
Submitter	: Andrew Price <andy-QvJ1taJFSUQwEI6hhNFqhFpr/1R2p/CL@public.gmane.org>
Date		: 2009-04-15 20:59 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123982932807371&w=3D=
4
Handled-By	: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123991090816794&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13115
Subject		: microcode driver newly spews warnings
Submitter	: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Date		: 2009-04-13 18:23 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123964711725007&w=3D=
4
Handled-By	: Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123980715900884&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13113
Subject		: tiobench read 50% regression with 2.6.30-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-04-09 8:29 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123926576802992&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123971130800697&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13096
Subject		: 2.6.30-rc2 hangs in get_measured_perf on tigerton
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-04-15 14:01 (2 days old)
References	: http://lkml.org/lkml/2009/4/15/34
Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/4/15/355


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13095
Subject		: thinkpad-acpi: cannot control brightness with hotkeys
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-11 23:07 (6 days old)
References	: http://lkml.org/lkml/2009/4/11/160
Handled-By	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/4/15/339


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13048
Subject		: /sys/class/backlight/acpi_video0/* is gone on vaio laptop wi=
th Intel GM45.
Submitter	: Rodrigo L. Batista <rodrigo-1dof46nAmC8dnm+yROfE0A@public.gmane.org>
Date		: 2009-04-09 04:57 (8 days old)
Handled-By	: yakui_zhao <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D20967
		  http://bugzilla.kernel.org/attachment.cgi?id=3D20959


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.29,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13070

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
