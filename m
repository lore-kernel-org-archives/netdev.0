From: "David S. Miller" <davem@davemloft.net>
Subject: Re: possible bug in net/core/pktgen.c (2.6.10 kernel)
Date: Tue, 18 Jan 2005 12:41:00 -0800
Message-ID: <20050118124100.17b7f47a.davem@davemloft.net>
References: <200501141129.21461.dsp@llnl.gov>
	<16874.25146.335366.990655@robur.slu.se>
	<200501180935.25419.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, robert.olsson@its.uu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Peterson <dsp@llnl.gov>
In-Reply-To: <200501180935.25419.dsp@llnl.gov>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2005 09:35:25 -0800
Dave Peterson <dsp@llnl.gov> wrote:

> On Sunday 16 January 2005 04:46 am, Robert Olsson wrote:
> > Dave Peterson writes:
> >  > I found a piece of code that looks problematic in the 2.6.10 kernel.
> >  > The following code appears starting on line 746 in function inject()
> >  > of net/core/pktgen.c:
> >  >                                         schedule();
> >  >                                 else
> >  >                                         do_softirq();
> >
> >  Thanks!
> >  So it should be?
> 
> Cool!  Looks like a fix to me.

I'm still a little bit confused on this one.

Since when does do_softirq() need preemption disabled
around calls to it?

do_softirq() disabled hard IRQs during the duration of it's
execution, thus effectively disabling preemption.

What is the problematic case again?
