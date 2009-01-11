From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc1: Reported regressions from 2.6.28
Date: Sun, 11 Jan 2009 12:12:05 +0100 (CET)
Message-ID: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Notes:
* 2.6.29-rc1 is out so it's time for a regressions report.  At the moment there
  are not too many regressions from 2.6.28 listed.
* We've got quite a number of regressions from 2.6.27 reported against 2.6.28
  final recently.  For this reason, I'm going to continue reporting regressions
  introduced between 2.6.27 and 2.6.28.
* Regressions 2.6.26 -> 2.6.27 won't be listed any more.  There are only 6 of
  them left and they don't seem to be urgent.
]

This message contains a list of some regressions from 2.6.28, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12422
Subject		: 2.6.28-git can't resume from str
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-10 1:39 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=123155157909282&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12420
Subject		: WARNING: at drivers/ata/libata-sff.c:1017 ata_sff_hsm_move+0x45e/0x750()
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-09 12:34 (3 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=871af1210f13966ab911ed2166e4ab2ce775b99d
References	: http://marc.info/?l=linux-kernel&m=123150457832109&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen@cn.fujitsu.com>
Date		: 2009-01-08 14:11 (4 days old)
References	: http://marc.info/?l=linux-kernel&m=123142399720125&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-01-07 22:43 (5 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=linux-kernel&m=123136836213319&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12417
Subject		: glx performance drop with: "x86: PAT: implement track/untrack of pfnmap regions for x86 - v3"
Submitter	: Alexey Fisher <bug-track@fisher-privat.net>
Date		: 2009-01-06 18:46 (6 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5899329b19100c0b82dc78e9b21ed8b920c9ffb3
References	: http://marc.info/?l=linux-kernel&m=123126782822696&w=4
Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12416
Subject		: Recent change to kernel spikes out ccache/distcc
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2009-01-06 15:15 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=123125495000603&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12415
Subject		: WARNING: at drivers/net/wireless/iwlwifi/iwl-sta.c:689
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-05 10:36 (7 days old)
References	: http://marc.info/?l=linux-wireless&m=123115178019082&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-05 4:13 (7 days old)
References	: http://marc.info/?l=linux-kernel&m=123112882127823&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12402
Subject		: 2.6.29-rc: kernel BUG at fs/xfs/support/debug.c:108
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-01-09 04:41 (3 days old)
References	: http://thread.gmane.org/gmane.comp.file-systems.xfs.general/27548
Handled-By	: Christoph Hellwig <hch@infradead.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12399
Subject		: USB wakeup problem on Toshiba Portege R500
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2009-01-08 7:35 (4 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=6fd9086a518d4f14213a32fe6c9ac17fabebbc1e
References	: http://marc.info/?l=linux-kernel&m=123140019117968&w=4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12428
Subject		: Build error on latest git
Submitter	: Petr Titera <P.Titera@century.cz>
Date		: 2009-01-11 9:49 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123166856318712&w=4
Handled-By	: Petr Titera <P.Titera@century.cz>
Patch		: http://marc.info/?l=linux-kernel&m=123167509024996&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12427
Subject		: cpumask change causes sparc build bustage
Submitter	: David Miller <davem@davemloft.net>
Date		: 2009-01-11 8:31 (1 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=588235bb53f2c215f0d4b08fd30b461fedc3338e
References	: http://marc.info/?l=linux-kernel&m=123166268013838&w=4
Handled-By	: David Miller <davem@davemloft.net>
Patch		: http://marc.info/?l=linux-kernel&m=123167571525706&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12400
Subject		: git-latest: kernel oops in IOMMU setup
Submitter	: Dirk Hohndel <hohndel@infradead.org>
Date		: 2009-01-08 20:05 (4 days old)
References	: http://marc.info/?l=linux-kernel&m=123144520124853&w=4
Handled-By	: Dirk Hohndel <hohndel@infradead.org>
Patch		: http://marc.info/?l=linux-kernel&m=123152033725557&w=4


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=12398

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

