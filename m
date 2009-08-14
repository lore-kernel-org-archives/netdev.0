From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 14 Aug 2009 19:25:43 -0400
Message-ID: <20090814232543.GA28599@hmsreliant.think-freely.org>
References: <20090807170600.9a2eff2e.billfink@mindspring.com> <20090807221211.GA16874@localhost.localdomain> <20090807205442.32918186.billfink@mindspring.com> <20090808015612.GA17710@localhost.localdomain> <20090814164412.be5daa74.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53870 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbZHNXZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:25:53 -0400
Content-Disposition: inline
In-Reply-To: <20090814164412.be5daa74.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2009 at 04:44:12PM -0400, Bill Fink wrote:
> On Fri, 7 Aug 2009, Neil Horman wrote:
> 
> > On Fri, Aug 07, 2009 at 08:54:42PM -0400, Bill Fink wrote:
> > > On Fri, 7 Aug 2009, Neil Horman wrote:
> > > 
> > > > You're timing is impeccable!  I just posted a patch for an ftrace module to help
> > > > detect just these kind of conditions:
> > > > http://marc.info/?l=linux-netdev&m=124967650218846&w=2
> > > > 
> > > > Hope that helps you out
> > > > Neil
> > > 
> > > Thanks!  It could be helpful.  Do you have a pointer to documentation
> > > on how to use it?  And does it require the latest GIT kernel or could
> > > it possibly be used with a 2.6.29.6 kernel?
> > > 
> > > 						-Bill
> > 
> > It should apply to 2.6.29.6 no problem (might take a little massaging, but not
> > much).
> 
> It doesn't look like I can apply your patches to my 2.6.29.6 kernel.
> 
> For starters, there's no include/trace/events directory, so there's
> no include/trace/events/skb.h.  There is an include/trace/skb.h file,
> but there's no TRACE_EVENT defined anywhere in the kernel.
> 
> I don't suppose it's as simple as defining (from include/linux/tracepoint.h
> from Linus's GIT tree):
> 
> #define PARAMS(args...) args
> 
> #define TRACE_EVENT(name, proto, args, struct, assign, print)   \
> 	DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
> 
> So do you still think it's reasonable to try applying your patches
> to my 2.6.29.6 kernel, or should I get a newer kernel like 2.6.30.4
> or 2.6.31-rc6?
> 
> 						-Thanks
> 
> 						-Bill
> 
> 
> 
I thought the trace stuff went it around 2.6.29 but I might be mistaken.
Easiest thing to do likely would be find where in the tree those were introduced
and just apply them prior to my patches, or move to the latest kernel if you
can (at least for the purposes of testing)

Neil

