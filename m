From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 01:30:07 +0200
Message-ID: <20090826233007.GA5082@elte.hu>
References: <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net> <alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com> <20090826.160910.187803108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, nhorman@tuxdriver.com, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50481 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbZHZXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 19:30:25 -0400
Content-Disposition: inline
In-Reply-To: <20090826.160910.187803108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Steven Rostedt <rostedt@goodmis.org>
> Date: Wed, 26 Aug 2009 19:05:20 -0400 (EDT)
> 
> > How about Neil try out doing all he can with the existing TRACE_EVENT 
> > work. I'm sure Ingo and myself would be fine with helping him with any 
> > issues he comes up with. If there is something that he hates about it, 
> > that really makes his user space code messy, then he can put the ball back 
> > in our court, and Ingo and I will need to come up with a solution.
> > 
> > If we truly hit a show stopper, than we can always fall back to the ftrace 
> > plugin. But until we find out for sure that TRACE_EVENT is not good 
> > enough, then we should try that out.
> > 
> > How's that sound?
> 
> That works for me, thanks Steven!
> 
> I'll revert Neil's change from net-next-2.6 and we can work on a 
> usable solution, long-term.

thanks David!

Also, my prior offer to help out with the TRACE_EVENT conversion 
stands as well, plus more TRACE_EVENT() tracepoints would be welcome 
too in the networking code.

It's a very useful feature and they are a lot easier (and more 
decentralized) to add than new tracing plugins.

Thanks,

	Ingo
