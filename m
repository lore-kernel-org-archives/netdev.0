From: yakui_zhao <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 10:34:53 +0800
Message-ID: <1239935693.3638.28.camel@localhost.localdomain>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
	 <1239931813.7661.394.camel@rzhang-dt>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, mjq59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1239931813.7661.394.camel@rzhang-dt>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-04-17 at 09:30 +0800, Zhang Rui wrote:
> On Fri, 2009-04-17 at 05:42 +0800, Rafael J. Wysocki wrote:
> > 
> > 
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13095
> > Subject         : thinkpad-acpi: cannot control brightness with hotkeys
> > Submitter       : Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2009-04-11 23:07 (6 days old)
> > References      : http://lkml.org/lkml/2009/4/11/160
> > Handled-By      : Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
> > Patch           : http://lkml.org/lkml/2009/4/15/339
> > 
> > 
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13048
> > Subject         : /sys/class/backlight/acpi_video0/* is gone on vaio laptop with Intel GM45.
> > Submitter       : Rodrigo L. Batista <rodrigo-1dof46nAmC8dnm+yROfE0A@public.gmane.org>
> > Date            : 2009-04-09 04:57 (8 days old)
> > Handled-By      : yakui_zhao <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Patch           : http://bugzilla.kernel.org/attachment.cgi?id=20967
> >                   http://bugzilla.kernel.org/attachment.cgi?id=20959
> > 
> > 
> bug 13095 is a duplicate of bug 13048.
> patches from Matthew and Yakui are for the same issue.
> 
> Yakui, could you verify which patch should be taken please?
The patch from Matthew is better. 
It still can work even when the KMS is disabled by adding the boot
option of "i915.modeset=0".

Hi, Matthew
    Will you please push the patch?
    
thanks.

> 
> thanks,
> rui
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
