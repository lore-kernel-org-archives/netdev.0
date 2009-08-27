From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 11:34:54 +0200
Message-ID: <20090827093454.GD4260@elte.hu>
References: <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908261913030.11291@gandalf.stny.rr.com> <20090827001426.GA26475@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908262021300.18923@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52691 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbZH0JfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 05:35:10 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908262021300.18923@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> On Wed, 26 Aug 2009, Neil Horman wrote:
> > > 
> > I'm not sure how the addition of an ftrace module constitutes a change to the
> > tracing infrastructure, but whatever, yes, no biggy.  I've bugun modifying the
> > TRACE_EVENT that I added to export the data I need directly.  Should be pretty
> > straightforward.  Dave I'll have a patch up on netdev in a day or two after I
> > test it.  Steven, should this still just go to netdev with a cc to you?  I'd
> > like to avoid repeating the same confusion here a second time around if I can
> 
> Yes, please Cc myself, and Ingo on those changes. I see where the 
> confusion came. It is where the code changes. The code in 
> kernel/trace is considered ftrace internals (there's internal 
> tracing upkeep that is needed for all plugins). [...]

yeah - i pointed that out in the very first mail to David 9 days ago 
when this patch broke the build in linux-next: kernel/trace/ is like 
net/core/. It would be nice and important if the networking tree 
treated it as such in the future.
 
See the:

  [PATCH -next] trace_skb: fix build when CONFIG_NET is not enabled

discussion on lkml:

  http://lkml.org/lkml/2009/8/17/378

Thanks,

	Ingo
