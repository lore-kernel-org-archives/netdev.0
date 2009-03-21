From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.29-rc8-git5: Reported regressions from 2.6.28
Date: Sat, 21 Mar 2009 21:05:34 +0100
Message-ID: <20090321200534.GA30238@elte.hu>
References: <GPBuLTara4J.A.3kH.TZTxJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Wu Fengguang <fengguang.wu@intel.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <GPBuLTara4J.A.3kH.TZTxJB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Rafael J. Wysocki <rjw@sisk.pl> wrote:

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12809
> Subject		: iozone regression with 2.6.29-rc6
> Submitter	: Lin Ming <ming.m.lin@intel.com>
> Date		: 2009-02-27 9:13 (23 days old)
> First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cf6e7d83bf334cc5916137862c920a97aabc018
> References	: http://marc.info/?l=linux-kernel&m=123572630504360&w=4
> 		  http://lkml.org/lkml/2009/3/14/265
> Handled-By	: Wu Fengguang <fengguang.wu@intel.com>

I think this was tracked back to the effective halving of 
dirty_ratio by 1cf6e7d83 ("mm: task dirty accounting fix") and 
doubling the ratio fixed the iozone regression.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12800
> Subject		: x86 PAT invalid vm_insert_pfn assumptions
> Submitter	: Thomas Hellstrom <thellstrom@vmware.com>
> Date		: 2009-03-02 01:40 (20 days old)

fix queued up for .30:

 895791d: VM, x86, PAT: add a new vm flag to track full pfnmap at mmap
 4bb9c5c: VM, x86, PAT: Change is_linear_pfn_mapping to not use vm_pgoff

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12763
> Subject		: Different cpu MHz values for processor0 and processor1
> Submitter	: Matthew A. Bockol <mbockol@carleton.edu>
> Date		: 2009-02-21 5:42 (29 days old)
> References	: http://marc.info/?l=linux-kernel&m=123519687807246&w=4

first-bad-commit:

d96f94c: ACPI: Enable bit 11 in _PDC to advertise hw coord

	Ingo
