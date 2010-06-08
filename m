From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed,  9 Jun 2010 00:06:30 +0200 (CEST)
Message-ID: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:39648 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab0FHWM6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 18:12:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NOTES:
 * This by no means is a complete list, but we only put e-mail reports that
   are at least 1 week old into the Bugzilla.
 * Quite a few of the already reported regressions may be related to the bug
   fixed by 386f40c86d6c8d5b717ef20620af1a750d0dacb4 (Revert "tty: fix a little
   bug in scrup, vt.c"), so reporters please retest with this commit applied.]

This message contains a list of some regressions from 2.6.34,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.34, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16163
Subject		: [2.6.35-rc1 Regression] i915: Commit cfecde causes VGA to stay off
Submitter	: David John <davidjon@xenontk.org>
Date		: 2010-06-02 12:52 (7 days old)
Message-ID	: <4C065423.3000202@xenontk.org>
References	: http://marc.info/?l=linux-kernel&m=127548313828613&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16161
Subject		: [2.6.35-rc1 regression] sysfs: cannot create duplicate filename ... XVR-600 related?
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2010-06-01 19:57 (8 days old)
Message-ID	: <19461.26166.427857.612983@pilspetsen.it.uu.se>
References	: http://marc.info/?l=linux-kernel&m=127542227511925&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16160
Subject		: 2.6.35 Radeon KMS power management regression?
Submitter	: Nigel Cunningham <ncunningham@crca.org.au>
Date		: 2010-06-01 6:23 (8 days old)
Message-ID	: <4C04A767.8000209@crca.org.au>
References	: http://marc.info/?l=linux-kernel&m=127537343722290&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16145
Subject		: Unable to boot after "ACPI: Don't let acpi_pad needlessly mark TSC unstable"
Submitter	: Tom Gundersen <teg@jklm.no>
Date		: 2010-06-07 13:11 (2 days old)
Handled-By	: Venkatesh Pallipadi <venki@google.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16129
Subject		: BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2
Submitter	: Jan Kreuzer <kontrollator@gmx.de>
Date		: 2010-06-05 06:15 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16122
Subject		: 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142 __mark_inode_dirty+0x103/0x170
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2010-06-04 13:18 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16120
Subject		: Oops: 0000 [#1] SMP, unable to handle kernel NULL pointer dereference at (null)
Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
Date		: 2010-06-04 09:25 (5 days old)
Handled-By	: Eric Dumazet <eric.dumazet@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16104
Subject		: Radeon KMS does not start after merge of the new PM-Code
Submitter	: Jan Kreuzer <kontrollator@gmx.de>
Date		: 2010-06-02 07:47 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16090
Subject		: sysfs: cannot create duplicate filename
Submitter	: Tobias <devnull@plzk.org>
Date		: 2010-06-01 15:59 (8 days old)
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16037
Subject		: NULL Pointer dereference in __ir_input_register/budget_ci_attach
Submitter	: Sean Finney <seanius@debian.org>
Date		: 2010-05-23 19:52 (17 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16131
Subject		: kernel BUG at fs/btrfs/extent-tree.c:4363 (btrfs_free_tree_block)
Submitter	: Chow Loong Jin <hyperair@ubuntu.com>
Date		: 2010-06-05 18:53 (4 days old)
Handled-By	: Yan Zheng <zheng.yan@oracle.com>
Patch		: https://patchwork.kernel.org/patch/103235/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16127
Subject		: Boot freeze on HP Compaq nx6325 (RS482) with Radeon KMS
Submitter	: Jure Repinc <jlp.bugs@gmail.com>
Date		: 2010-06-04 21:14 (5 days old)
Handled-By	: Dave Airlie <airlied@linux.ie>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26677


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16092
Subject		: Caught 64-bit read from uninitialized memory in memtype_rb_augment_cb
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-06-01 18:08 (8 days old)
Handled-By	: Venki <venki@google.com>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=16092#c2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.34,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

