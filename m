From: "Carlos R. Mafra" <crmafra2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 12:23:16 +0100
Message-ID: <20110203112316.GA3718@linux-yscl.site>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu  3.Feb'11 at  1:03:41 +0100, Rafael J. Wysocki wrote:
> 
> If you know of any other unresolved post-2.6.36 regressions, please let us know
> either and we'll add them to the list.  Also, please let us know if any
> of the entries below are invalid.

I'm sorry if I'm overlooking something, but as far as I can see the regression
reported here:

https://lkml.org/lkml/2011/1/24/457

is not in the list (update on that report: reverting that commit on top of 
2.6.37 fixes the issue).

After some time, I also ended up finding an earlier report in the kernel bugzilla
which I think is the same regression (it was bisected to the same commit):

https://bugzilla.kernel.org/show_bug.cgi?id=24982

but I do not see it in the list either, even though it's marked as a
regression in the bugzilla.

The issue was also present in 2.6.38-rc2 last time I tested.
