From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 17:34:21 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc4s5$gmr$2@main.gmane.org>
References: <20020521015407.A1296@wotan.suse.de> <200205210011.EAA04286@sex.inr.ac.ru> <20020521022007.A6248@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> 
> On Tue, May 21, 2002 at 04:11:00AM +0400, A.N.Kuznetsov wrote:
> > Hello!
> >
> > > It's unfortunately the truth. Even in_interrupt() is buggy current
> > > on SMP preemptive.
> >
> > And why folks working on preemtive kernel do not repair this?
> > To all that I remember it is well known issue.
> 
> It is fixed on x86-64 @)
> 
> if [ "$CONFIG_SMP" = "n" ]; then
>    bool 'Preemptible Kernel' CONFIG_PREEMPT
> fi
> 
That is not a fix!  It is dodging the issue. ;)

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
