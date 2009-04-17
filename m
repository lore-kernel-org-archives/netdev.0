From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 23:25:45 +0200
Message-ID: <200904172325.49030.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <alpine.LFD.2.00.0904161738030.4042@localhost.localdomain> <20090417012544.GB16126@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090417012544.GB16126-X9Un+BFzKDI@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 17 April 2009, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> 
> > 
> > 
> > I think you put this in the wrong regression pile:
> > 
> > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13112
> > > Subject		: Oops in drain_array
> > > Submitter	: Bart <mmx-G/jkD+u3s4s@public.gmane.org>
> > > Date		: 2009-04-14 10:21 (3 days old)
> > > References	: http://marc.info/?l=linux-kernel&m=123970493224628&w=4
> > 
> > Hmm. This one seems like it should be in the "since 2.6.28" camp, since if 
> > I read that one right, it happens with 2.6.29.1.
> > 
> > (I mean sure, it might be new since 2.6.29, but it sounds more likely that 
> > it's already in 2.6.29)
> 
> I'd suspect it's possibly hardware related:
> 
>   http://www.kerneloops.org/search.php?search=free_block&btnG=Function+Search
> 
> Look at the very similar call signatures - spanning almost all 
> kernels back to v2.6.16. There's one spike at .27 - perhaps the same 
> box trying up hard and crashing several times - or a popular distro 
> kernel?
> 
> Or it's a really ancient bug going back to v2.6.16.

I have moved this one onto the list of regressions from 2.6.28.  When it is
confirmed that the bug is older, I'll drop it from there.

Thanks,
Rafael
