From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.34-rc6-git2: Reported regressions from 2.6.33
Date: Tue, 4 May 2010 17:00:32 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005041654400.5478@i5.linux-foundation.org>
References: <JzEGxUyyQHG.A.ZtH.YHJ4LB@chimera>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <JzEGxUyyQHG.A.ZtH.YHJ4LB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Tue, 4 May 2010, Rafael J. Wysocki wrote:
> 
> Unresolved regressions
> ----------------------
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15880
> Subject		: Very bad regression from 2.6.33 as of 1600f9def
> Submitter	: Alex Elsayed <eternaleye-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date		: 2010-04-29 2:28 (6 days old)
> Message-ID	: <loom.20100429T041908-663-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
> References	: http://marc.info/?l=linux-kernel&m=127250825306178&w=2

This looks like it wasn't a regression, but some other compile/install 
issue. See

	http://marc.info/?l=linux-kernel&m=127274294422719&w=2

where he reports that his self-compiled 2.6.33 doesn't boot either. 

There's some confusion about .config, but it might well be an install 
problem too (in fact, that sounds more likely - the original bug-report 
seems to reboot before the kernel has really even booted - it apparently 
hasn't done the graphics mode switch by the early bootloader)

		Linus
