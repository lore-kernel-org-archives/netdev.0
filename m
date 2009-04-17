From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Thu, 16 Apr 2009 17:46:15 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904161742140.4042@localhost.localdomain>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Apr 2009, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13098
> Subject		: 2.6.29-git12 breaks vga=0x0f07 on MSI/Intel GPU
> Submitter	: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
> Date		: 2009-04-06 01:14 (11 days old)
> References	: http://lkml.org/lkml/2009/4/5/200
> Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>

I think this got fixed already. The VGA moresettign was reverted back to 
the old order.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13044
> Subject		: 2.6.30-rc1 can't find the root fs
> Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
> Date		: 2009-04-08 13:35 (9 days old)

This was one of the async things that got fixed by just waiting for module 
async work to finish.

		Linus
