From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 12:43:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002701c24e01$f59b6190$8900a8c0@weixl>
References: <Pine.GSO.4.30.0208270803520.6895-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Ben Greear" <greearb@candelatech.com>,
   "Cheng Jin" <chengjin@cs.caltech.edu>, "Cheng Hu" <chenghu@cs.caltech.edu>,
   "Steven Low" <slow@cs.caltech.edu>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jamal" <hadi@cyberus.ca>, "Andi Kleen" <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> >
> > That is because of the lock it takes. Locks are always slow.
>
> xtime_lock?
I guess so, after looked at do_gettimeofday

>
> > Possibilities:
> >
> > - Ignore the problem and switch back to gettimeoffset again
>
> Is it safe to call gettimeoffset without the lock?
What's the possible danger to ignore the lock? Can I read the xtime
directly?

>
> > - Switch to gettimeoffset but add some correction step for the unlikely
> > case that someone wants the timestamp from user space
> > (would be my prefered solution)
> > - Implement lockless gettimeofday like x86-64 or sparc
> > (good one too, but likely slower than last)
>
>
> ia64 seems to also have the lock.
>
> cheers,
> jamal
>
>
>
>
