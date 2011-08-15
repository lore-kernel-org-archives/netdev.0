From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: 3.1-rc1-git9: Reported regressions 2.6.39 -> 3.0
Date: Mon, 15 Aug 2011 08:37:59 -0700
Message-ID: <20110815153759.GF2389@linux.vnet.ibm.com>
References: <xuTC4jRtHbB.A.l4H.gMCSOB@chimera>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
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
In-Reply-To: <xuTC4jRtHbB.A.l4H.gMCSOB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 14, 2011 at 09:02:27PM +0200, Rafael J. Wysocki wrote:
> [NOTE:
>  We already have a bug entry for tracking regressions from 3.0:
> 
>  http://bugzilla.kernel.org/show_bug.cgi?id=40982
> 
>  but there are no reports linked to it, mostly because Maciej is on vacation,
>  but also because the frequency of reporting regressions has been low
>  recently.  So, if you're seeing a regression from 3.0, please let us know.]
> 
> This message contains a list of some post-2.6.39 regressions introduced before
> 3.0, for which there are no fixes in the mainline known to the tracking team.
> If any of them have been fixed already, please let us know.
> 
> If you know of any other unresolved post-2.6.39 regressions, please let us know
> either and we'll add them to the list.  Also, please let us know if any
> of the entries below are invalid.
> 
> Each entry from the list will be sent additionally in an automatic reply to
> this message with CCs to the people involved in reporting and handling the
> issue.
> 
> 
> Listed regressions statistics:
> 
>   Date          Total  Pending  Unresolved
>   ----------------------------------------
>   2011-08-14       63       22          19
> 
> 
> Unresolved regressions
> ----------------------
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=40282
> Subject		: IP forwarding regression since 3.0-rc6
> Submitter	: Stephan Seitz <stse+lkml-S0d6l+6kcjrOGKtSYHEJQ9HuzzzSOjJt@public.gmane.org>
> Date		: 2011-07-25 12:51 (21 days old)
> Message-ID	: <20110725T141145.GA.2ae38.stse-S0d6l+6kcjrOGKtSYHEJQ9HuzzzSOjJt@public.gmane.org>
> References	: http://marc.info/?l=linux-kernel&m=131159880004908&w=2
> 
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=40172
> Subject		: lockdep trace from post 3.0.
> Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date		: 2011-07-24 1:32 (22 days old)
> Message-ID	: <20110724013257.GA6777-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> References	: http://marc.info/?l=linux-kernel&m=131147120206819&w=2
> 
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=40092
> Subject		: RCU stall in linux-3.0.0
> Submitter	: Philip Armstrong <phil-awZZuG094qgqdlJmJB21zg@public.gmane.org>
> Date		: 2011-07-25 21:44 (21 days old)

This one was due the the CPU's idea of the current time getting way
out of sync (as in more than a minute's worth of disagreement, which is
pretty impressive when you think about it).  So what happened is that
one CPU decided that the current grace period was a full minute old
immediately, and thus started screaming piteously.  John Stultz provided
a configuration workaround, and he and Thomas Gleixner would be working
out the long-term fix.

							Thanx, Paul
