From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 20:34:27 -0400
Message-ID: <20090827003427.GB30341@infradead.org>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	rostedt@goodmis.org, fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35700 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbZH0Aef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 20:34:35 -0400
Content-Disposition: inline
In-Reply-To: <20090826223922.GA25318@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 06:39:22PM -0400, Neil Horman wrote:
> Steven specifically told me to submit the patch to the subsystem maintainer that
> I'm adding tracepoints for, and the only feedback I got on it was his one
> question, the answer to which I assume satisfied him, due to that there was no
> subseuqent discussion.  I'm going to ignore your previous emails, because,
> despite the various advantages of just using plain TRACE_EVENTs because you
> provide the ftrace interface, and I found it useful.  Your observation is
> correct, I like it, and thats what I wanted to use, so I used it.  If you don't
> want people to use it, don't provide it.

Neil, this attitude is a perfect way to end up on a shitlist.  I think
there is a fair case to make you didn't know that the ftrace plugin was
wrong when you did, but now you do.  And btw, I completely agree with
Ingo here - the TRACE_EVENT stuff is extremly userful to get borader
pictures of what's going on.  E.g. the combination of my unfortunately
not yet included xfs tracer and blktrace allowed debugging quite a lot
of interesting issues.

So instead of playing jackass here listen to what is the right approach
for it and fix it up.  It'll help us all in the end.


Looking forward to the day when plain DECLARE_TRACE goes away so people
can't "accidentally" use it.
