From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: 2.6.32-rc1-git2: Reported regressions from 2.6.31
Date: Fri, 02 Oct 2009 15:00:37 +0200
Message-ID: <4AC5F975.6060505@s5r6.in-berlin.de>
References: <9UCePxij8cB.A.VCG.-3SxKB@chimera> <1254469139.3531.19.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254469139.3531.19.camel-6Ww87KsxWewAvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jaswinder Singh Rajput wrote:
> If you add one more entry say "Suspected commit :" then it will be great
> and will solve regressions much faster.

Will?  Might.

> You can request submitter to
> submit 'suspected commit' by git bisect and also specify git bisect
> links like : (for more information about git bisect check
> http://kerneltrap.org/node/11753)

I disagree.  A reporter should only be asked to bisect (using git or
other tools) /if/ a developer determined that bisection may speed up the
debugging process or is the only remaining option to make progress with
a bug.

It would be wrong to steal a reporter's valuable time by asking for
bisection before anybody familiar with the matter even had a first look
at the report.

Remember:
  - Not all bugs can be economically narrowed down by bisection.
  - Bisection requires skills, rigor, and time.
  - Alas there are considerable sections in our kernel history which
    are not bisectable.
-- 
Stefan Richter
-=====-==--= =-=- ---=-
http://arcgraph.de/sr/
