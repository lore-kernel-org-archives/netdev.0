From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Mon, 10 Jun 2002 07:12:04 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D04B3B4.DDA3878C@mvista.com>
References: <3D0390E2.1B80ADEE@mvista.com>
		<20020609.213224.01016187.davem@redhat.com>
		<3D045F15.578E1DA9@mvista.com> <20020610.013110.81671593.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: george anzinger <george@mvista.com>
>    Date: Mon, 10 Jun 2002 01:11:01 -0700
> 
>    "David S. Miller" wrote:
>    >
>    > Also we need to know what network driver, if preemption is being
>    > used (being from mvista I assume you are using preemption, and if
>    > so make sure you have the preemption networking patches applied).
> 
>    Uh, are you saying there is a set of network patches?  If
>    so, where might they be found?  And yes, we are testing
>    preemption, trying to wring out the "last" bug :)  (Could
>    you be referring to the patches we are developing?)
> 
> An mvista person recently put "make net preempt safe" patches
> into 2.5.x  Basically it amounted to putting a few preempt_disable
> sections into net/core/skbuff.c

Ah, yes.  Those are the ones I have found sofar.  Robert
Love would be the submitter.  It would apear there is at
least one more hole :(  Thus the query.
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
