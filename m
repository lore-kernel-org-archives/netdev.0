From: Andi Kleen <ak@muc.de>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 02:39:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc5l2$hn3$2@main.gmane.org>
References: <200205210011.EAA04286@sex.inr.ac.ru> <3CE99434.20E7479C@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, Andi Kleen <ak@suse.de>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george anzinger <george@mvista.com>
Content-Disposition: inline
In-Reply-To: <3CE99434.20E7479C@mvista.com>
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2002 at 02:26:29AM +0200, george anzinger wrote:
> kuznet@ms2.inr.ac.ru wrote:
> > 
> > Hello!
> > 
> > > It's unfortunately the truth. Even in_interrupt() is buggy current
> > > on SMP preemptive.
> > 
> > And why folks working on preemtive kernel do not repair this?
> > To all that I remember it is well known issue.
> > 
> Ah, but we have.  in_interrupt() was fixed about a month
> ago.  I think Robert got it into all the patches.  Whats
> more, it is a bit faster too :)

It's not fixed in 2.5.15/16.  I don't know about your patches.

-Andi
