From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.29-rc8-git5: Reported regressions from 2.6.28
Date: Mon, 23 Mar 2009 09:23:47 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903230922440.3030@localhost.localdomain>
References: <GPBuLTara4J.A.3kH.TZTxJB@chimera> <20090321200534.GA30238@elte.hu> <20090323005738.GB6003@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
To: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090323005738.GB6003@localhost>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Mon, 23 Mar 2009, Wu Fengguang wrote:
> > 
> > I think this was tracked back to the effective halving of 
> > dirty_ratio by 1cf6e7d83 ("mm: task dirty accounting fix") and 
> > doubling the ratio fixed the iozone regression.
> 
> Yes, exactly. The patch for fixing this regression is trivial.

I was planning on applying that patch only after 2.6.29 is out, and then 
if there are no surprising side effects and nobody complains, we'd then 
back-port it into stable.

		Linus
