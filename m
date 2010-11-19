From: Mark Lord <kernel-R6A+fiHC8nRWk0Htik3J/w@public.gmane.org>
Subject: Re: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Thu, 18 Nov 2010 19:47:21 -0500
Message-ID: <4CE5C919.7090504@teksavvy.com>
References: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
In-Reply-To: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10-11-18 06:50 PM, Rafael J. Wysocki wrote:
> This message contains a list of some post-2.6.35 regressions introduced before
> 2.6.36, for which there are no fixes in the mainline known to the tracking team.
> If any of them have been fixed already, please let us know.
>
> If you know of any other unresolved post-2.6.35 regressions, please let us know
> either and we'll add them to the list.  Also, please let us know if any
> of the entries below are invalid.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21652
> Subject		: several problems with intel graphics since 2.6.36
> Submitter	: Norbert Preining<preining-DX+603jRYB8@public.gmane.org>
> Date		: 2010-10-27 14:32 (23 days old)
> Message-ID	:<20101027143252.GA8676-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
> References	: http://marc.info/?l=linux-kernel&m=128818998630241&w=2

That one is interesting to me.. I suspect it may be the same cause
as for https://bugzilla.kernel.org/show_bug.cgi?id=21952

I have one of those Samsung (N210) Netbooks here: works fine with 2.6.34 and 
earlier,
but fails to come out of suspend on 2.6.35/2.6.36 (haven't tried 2.6.37).

So perhaps add 21952 to the list, or link it to the 21652
(kind of amusing how similar the bug numbers are..).


My non-Intel graphics notebook (has ATI X1400 graphics) also has a resume
regression with 2.6.36.  But it does work fine with 2.6.35 (and earlier,
back many years).  As a result, I'm stuck with 2.6.35 for the time being,
and lack the time for a concerted debug effort on 2.6.36+ right now.

Cheers
