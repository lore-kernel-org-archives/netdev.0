From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.34-rc3-git6: Reported regressions from 2.6.33
Date: Thu, 8 Apr 2010 22:24:42 +0200
Message-ID: <201004082224.42633.rjw@sisk.pl>
References: <6Pphclm24fK.A.lSF.qsPvLB@chimera> <alpine.LFD.2.00.1004071444440.3586@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1004071444440.3586-GpypE611fyS63QaFMGN2QEqCLAeBNdoH@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 08 April 2010, Linus Torvalds wrote:
> 
> On Wed, 7 Apr 2010, Rafael J. Wysocki wrote:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15718
> > Subject		: File corruption regression on NFS related to commit 1f36f774
> > Submitter	: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
> > Date		: 2010-03-24 15:49 (15 days old)
> > First-Bad-Commit: http://git.kernel.org/git/linus/1f36f774b22a0ceb7dd33eca626746c81a97b6a5
> > Message-ID	: <4BAA3493.1030802-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126944579810350&w=4
> > Handled-By	: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> 
> I think this one is fixed by commit 3e297b61349.

Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15716
> > Subject		: ata2: lost interrupt with kernel 2.6.34-rc1
> > Submitter	: Andrew Benton <b3nton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2010-03-11 16:57 (28 days old)
> > Message-ID	: <4B992110.2090300-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126832670609705&w=4
> > Handled-By	: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
> 
> And isn't this the already long-fixed commit 332ac7ff77cd?
> 
> That bugzilla entry is a duplicate of 
> 
> 	https://bugzilla.kernel.org/show_bug.cgi?id=15537
> 
> as far as I can see.

Yes, my bad, sorry.  Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15715
> > Subject		: vmscan: underflow for get_scan_ratio
> > Submitter	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Date		: 2010-03-30 5:53 (9 days old)
> > First-Bad-Commit: http://git.kernel.org/git/linus/84b18490d1f1bc7ed5095c929f78bc002eb70f26
> > Message-ID	: <20100330055304.GA2983-U5EdaLXB8smDugQYiPIPGdh3ngVCH38I@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126992842105754&w=4
> > Handled-By	: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > 		  Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> That commit got reverted. See commit d6da1a5abc.

Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15674
> > Subject		: [2.6.34-rc2 NFS4 oops] open error path failure...
> > Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2010-03-29 18:36 (10 days old)
> > Message-ID	: <6278d2221003291136p6481fe8emfb039403343c082-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126988782722711&w=2
> 
> This smells like the same LOOKUP_DIRECTORY thing as the first entry, but.. 
> 
> Al?

This one has been fixed too, I see, so closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15600
> > Subject		: CONFIG_NO_BOOTMEM woes, 2.6.34-rc1
> > Submitter	: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Date		: 2010-03-15 15:28 (24 days old)
> > Message-ID	: <4B9E5211.9000204-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126866691701926&w=2
> 
> These should hopefully be all fixed. There was some confusion over this, 
> but the report that said it wasn't fixed in -rc3 was apparently not true 
> after all. Several commits, but mainly commit eed63519e, iirc.

Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15518
> > Subject		: CONFIG_NO_BOOTMEM=y breaks boot on 32bit
> > Submitter	: Daniel Vetter <daniel-/w4YWyX8dFk@public.gmane.org>
> > Date		: 2010-03-11 15:37 (28 days old)
> 
> Duplicate entry. See above.

Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15480
> > Subject		: [regression] Fails to boot properly unless given pci=nocrs
> > Submitter	: Yanko Kaneti <yaneti-jUE9FD3ILm5BDgjK7y7TUQ@public.gmane.org>
> > Date		: 2010-03-09 01:24 (30 days old)
> > Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
> > Patch		: http://lkml.org/lkml/2010/3/11/512
> 
> These are merged already. Commits d558b483d5, eb9fc8ef7cb etc.

Closed.

Thanks,
Rafael
