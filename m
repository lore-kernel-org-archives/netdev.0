From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: 2.6.27-rc8-git7: Reported regressions from 2.6.26
Date: Sun, 5 Oct 2008 16:01:37 +0400
Message-ID: <20081005120136.GA22457@2ka.mipt.ru>
References: <0pOgGB.A.uLG.E475IB@wind> <20081005071421.GA17685@2ka.mipt.ru> <200810051302.20896.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200810051302.20896.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 05, 2008 at 01:02:20PM +0200, Rafael J. Wysocki (rjw-KKrjLPT3xs0@public.gmane.org) wrote:
> > Just for the reference, this one regresses from the 2.6.23.
> 
> Still, tbench results from 2.6.26 are better than from 2.6.27-rc.
> That's why it's still on the list, but if you think that's not relevant, please
> let me know and I'll drop it.

I meant it continuously regresses from .23 including 26-27 timeframe.
There were at least two changes in 26-27 which caused tbench regression
in this particular time interval. One of them enabled TSO over loopback
by default, so one can turn it off via ethtools or this patch:
http://marc.info/?l=linux-netdev&m=122263663631600&w=2

another (hopefully) one I'm trying to find out, which is a bit complex
and slow, since e1000 driver changes in the middle of the 26-27
timeframe does not allow my testing machines to boot.

So, there is a regression (partially resolved), but it is only part of
the problem.

-- 
	Evgeniy Polyakov
