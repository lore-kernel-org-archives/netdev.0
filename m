From: David Miller <davem@davemloft.net>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 16:09:10 -0700 (PDT)
Message-ID: <20090826.160910.187803108.davem@davemloft.net>
References: <20090826223922.GA25318@hmsreliant.think-freely.org>
	<20090826.154410.95005620.davem@davemloft.net>
	<alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, mingo@elte.hu, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: rostedt@goodmis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753342AbZHZXI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:08:57 -0400
In-Reply-To: <alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 26 Aug 2009 19:05:20 -0400 (EDT)

> How about Neil try out doing all he can with the existing TRACE_EVENT 
> work. I'm sure Ingo and myself would be fine with helping him with any 
> issues he comes up with. If there is something that he hates about it, 
> that really makes his user space code messy, then he can put the ball back 
> in our court, and Ingo and I will need to come up with a solution.
> 
> If we truly hit a show stopper, than we can always fall back to the ftrace 
> plugin. But until we find out for sure that TRACE_EVENT is not good 
> enough, then we should try that out.
> 
> How's that sound?

That works for me, thanks Steven!

I'll revert Neil's change from net-next-2.6 and we can work on a
usable solution, long-term.
