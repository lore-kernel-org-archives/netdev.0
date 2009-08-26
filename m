From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 19:05:20 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
References: <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nhorman@tuxdriver.com, Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:53601 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbZHZXFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:05:21 -0400
In-Reply-To: <20090826.154410.95005620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 26 Aug 2009, David Miller wrote:

> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 26 Aug 2009 18:39:22 -0400
> 
> > Ok, I'm rather tired of arguing.  Dave, I'll leave this in your hands.
> 
> I've gotten this kind of urging, both in private and in public, from
> both of you now.  And I'm sorry, that's not how this works.
> 
> It is not my job to somehow force you turkeys how to work effectively
> together. :-)
> 
> What we can do is ask Mr. Rostedt to asses the situation and give
> his feedback.
> 
> So if Steven could give some feedback about this specific situation
> that would be great and might help us move forward.

OK, here's my thought on the matter.

How about Neil try out doing all he can with the existing TRACE_EVENT 
work. I'm sure Ingo and myself would be fine with helping him with any 
issues he comes up with. If there is something that he hates about it, 
that really makes his user space code messy, then he can put the ball back 
in our court, and Ingo and I will need to come up with a solution.

If we truly hit a show stopper, than we can always fall back to the ftrace 
plugin. But until we find out for sure that TRACE_EVENT is not good 
enough, then we should try that out.

How's that sound?

-- Steve

