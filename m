From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 17:26:29 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc4cs$fvl$2@main.gmane.org>
References: <200205210011.EAA04286@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> 
> Hello!
> 
> > It's unfortunately the truth. Even in_interrupt() is buggy current
> > on SMP preemptive.
> 
> And why folks working on preemtive kernel do not repair this?
> To all that I remember it is well known issue.
> 
Ah, but we have.  in_interrupt() was fixed about a month
ago.  I think Robert got it into all the patches.  Whats
more, it is a bit faster too :)

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
