From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.32-rc1-git2: Reported regressions from 2.6.31
Date: Thu,  1 Oct 2009 21:26:59 +0200 (CEST)
Message-ID: <9UCePxij8cB.A.VCG.-3SxKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Notes:

 * Here's the first summary report of known regressions from 2.6.31.  There's
   not too many of them at the moment, which is nice.

 * We're still getting quite a number of reports of regressions from 2.6.30 and
   it's been that way since 2.6.31 was released.  For details please see the
   summary report of regressions 2.6.30 -> 2.6.31 that will follow shortly.]

This message contains a list of some regressions from 2.6.31, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.31, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14299
Subject		: oops in wireless, iwl3945 related?
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-09-29 17:12 (3 days old)
References	: http://marc.info/?l=linux-kernel&m=125424439725743&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad related?
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-09-30 20:07 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=125434130703538&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer@pengutronix.de>
Date		: 2009-09-30 15:11 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=125432349404060&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14296
Subject		: spitz boots but suspend/resume is broken
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-09-30 12:06 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=125431244516449&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14279
Subject		: Suspend to RAM freeze totally since 2.6.32-rc1
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-09-30 18:14 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14277
Subject		: Caught 8-bit read from freed memory in b43 driver at association
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-09-30 18:06 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14276
Subject		: nfsroot will not remount rw and claims illegal options
Submitter	: Hans de Bruin <bruinjm@xs4all.nl>
Date		: 2009-09-30 15:08 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14260
Subject		: T400 suspend/resume regression
Submitter	: Theodore Tso <tytso@mit.edu>
Date		: 2009-09-26 6:57 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=125394827806011&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14214
Subject		: BUG at drivers/scsi/scsi_lib.c:1108!
Submitter	: Plamen Petrov <pvp-lsts@fs.ru.acad.bg>
Date		: 2009-09-23 11:13 (9 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14302
Subject		: Kernel panic on i386 machine when booting with profile=2
Submitter	: Shi, Alex <alex.shi@intel.com>
Date		: 2009-10-01 3:23 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=125436749607199&w=4
Handled-By	: Alex Shi <alex.shi@intel.com>
Patch		: http://patchwork.kernel.org/patch/50813/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14300
Subject		: BUG_ON crash w/ ext4
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2009-10-01 1:41 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=125436130800340&w=4
		  http://marc.info/?l=linux-kernel&m=125436568504914&w=4
Handled-By	: Theodore Tso <tytso@mit.edu>
Patch		: http://patchwork.kernel.org/patch/50810/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14278
Subject		: New message "NOHZ: local_softirq_pending 08" at each ping request
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-09-30 18:12 (2 days old)
Handled-By	: Michael Buesch <mb@bu3sch.de>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=23220


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14271
Subject		: ACPI boot memory leaks
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2009-09-29 9:18 (3 days old)
References	: http://marc.info/?l=linux-kernel&m=125421594111690&w=4
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch		: http://patchwork.kernel.org/patch/50565/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14259
Subject		: NFS problem with past 2.6.31 git tree
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2009-09-25 15:12 (7 days old)
References	: http://marc.info/?l=linux-kernel&m=125389156504570&w=4
Handled-By	: Trond Myklebust <Trond.Myklebust@netapp.com>
Patch		: http://patchwork.kernel.org/patch/50428/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14247
Subject		: ACPI Exception: AE_TIME, Returned by Handler for [EmbeddedControl] flooding logs
Submitter	: Thomas Backlund <tmb@mandriva.org>
Date		: 2009-09-25 15:08 (7 days old)
References	: http://lkml.org/lkml/2009/9/25/121
Handled-By	: Alexey Starikovskiy <astarikovskiy@suse.de>
Patch		: http://patchwork.kernel.org/patch/50516/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.31,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=14230

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

