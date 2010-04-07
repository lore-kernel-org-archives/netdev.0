From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.34-rc3-git6: Reported regressions from 2.6.33
Date: Wed, 7 Apr 2010 15:04:46 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1004071444440.3586@i5.linux-foundation.org>
References: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>,
	Al Viro <viro@zeniv.linux.org.uk>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 7 Apr 2010, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15718
> Subject		: File corruption regression on NFS related to commit 1f36f774
> Submitter	: Boaz Harrosh <bharrosh@panasas.com>
> Date		: 2010-03-24 15:49 (15 days old)
> First-Bad-Commit: http://git.kernel.org/git/linus/1f36f774b22a0ceb7dd33eca626746c81a97b6a5
> Message-ID	: <4BAA3493.1030802@panasas.com>
> References	: http://marc.info/?l=linux-kernel&m=126944579810350&w=4
> Handled-By	: Al Viro <viro@zeniv.linux.org.uk>

I think this one is fixed by commit 3e297b61349.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15716
> Subject		: ata2: lost interrupt with kernel 2.6.34-rc1
> Submitter	: Andrew Benton <b3nton@gmail.com>
> Date		: 2010-03-11 16:57 (28 days old)
> Message-ID	: <4B992110.2090300@gmail.com>
> References	: http://marc.info/?l=linux-kernel&m=126832670609705&w=4
> Handled-By	: Jeff Garzik <jeff@garzik.org>

And isn't this the already long-fixed commit 332ac7ff77cd?

That bugzilla entry is a duplicate of 

	https://bugzilla.kernel.org/show_bug.cgi?id=15537

as far as I can see.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15715
> Subject		: vmscan: underflow for get_scan_ratio
> Submitter	: Shaohua Li <shaohua.li@intel.com>
> Date		: 2010-03-30 5:53 (9 days old)
> First-Bad-Commit: http://git.kernel.org/git/linus/84b18490d1f1bc7ed5095c929f78bc002eb70f26
> Message-ID	: <20100330055304.GA2983@sli10-desk.sh.intel.com>
> References	: http://marc.info/?l=linux-kernel&m=126992842105754&w=4
> Handled-By	: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 		  Wu Fengguang <fengguang.wu@intel.com>

That commit got reverted. See commit d6da1a5abc.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15674
> Subject		: [2.6.34-rc2 NFS4 oops] open error path failure...
> Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
> Date		: 2010-03-29 18:36 (10 days old)
> Message-ID	: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
> References	: http://marc.info/?l=linux-kernel&m=126988782722711&w=2

This smells like the same LOOKUP_DIRECTORY thing as the first entry, but.. 

Al?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15600
> Subject		: CONFIG_NO_BOOTMEM woes, 2.6.34-rc1
> Submitter	: Avi Kivity <avi@redhat.com>
> Date		: 2010-03-15 15:28 (24 days old)
> Message-ID	: <4B9E5211.9000204@redhat.com>
> References	: http://marc.info/?l=linux-kernel&m=126866691701926&w=2

These should hopefully be all fixed. There was some confusion over this, 
but the report that said it wasn't fixed in -rc3 was apparently not true 
after all. Several commits, but mainly commit eed63519e, iirc.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15518
> Subject		: CONFIG_NO_BOOTMEM=y breaks boot on 32bit
> Submitter	: Daniel Vetter <daniel@ffwll.ch>
> Date		: 2010-03-11 15:37 (28 days old)

Duplicate entry. See above.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15480
> Subject		: [regression] Fails to boot properly unless given pci=nocrs
> Submitter	: Yanko Kaneti <yaneti@declera.com>
> Date		: 2010-03-09 01:24 (30 days old)
> Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Patch		: http://lkml.org/lkml/2010/3/11/512

These are merged already. Commits d558b483d5, eb9fc8ef7cb etc.

		Linus
