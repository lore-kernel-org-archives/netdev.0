From: Piet Delaney <piet@bluelane.com>
Subject: Re: Congestion Avoidance Monitoring Tools
Date: Fri, 21 Apr 2006 00:25:27 -0700
Message-ID: <1145604327.5901.16.camel@piet2.bluelane.com>
References: <1145597174.12413.17.camel@piet2.bluelane.com>
	 <1145599196.2534.38.camel@penguin>  <200604210857.19084.ak@suse.de>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Piet Delaney <piet@bluelane.com>,
	Tom Young <tyo@ee.unimelb.edu.au>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:50451 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S1751224AbWDUHZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 03:25:31 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200604210857.19084.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 08:57 +0200, Andi Kleen wrote:
> On Friday 21 April 2006 07:59, Tom Young wrote:
> > On Thu, 2006-04-20 at 22:26 -0700, Piet Delaney wrote:
> > > I'm upgrading our 2.6.12 kernel to 2.6.13, which includes significant
> > > congestion avoidance code additions and changes. I was wondering if
> > > there are any tools folks can recommend for testing the kernel to make
> > > sure the congestion avoidance code is operating correctly. For 
> > > example the displaying of the congestion window as a function of time
> > > while undergoing convergence. For causing congestion I could modify 
> > > a kernel to discard packets once in a while on a lab gateway and hit 
> > > it with iperf. HP's netperf looks interesting. 
> > > 
> > > Any suggestions?
> > > 
> > > 
> > > -piet
> > > 
> > 
> > Hi,
> > 
> > Try having a look at the output of 'ss -i' (you may need to update to
> > the latest iproute2 tools). You could either try and parse the text
> > output of that or use the same inet_diag interface that ss uses to poll
> > for the data it at regular intervals.
> 
> Another way is to use tcptrace on a tcpdump file
> (http://jarok.cs.ohiou.edu/software/tcptrace/) 
> It finds a lot of statistics about the dumped TCP connections.

Tcptrace looks pretty good, graphing the sequence numbers as a function
of time was one of the features I'm looking for.

> 
> Newer ethereal also has some TCP plotting functions that are useful.
> They don't display the congestion window directly, but you can see it indirectly.

I never tried the ethereal graph facility, looks like another great
idea.


Thanks,
-piet

> 
> -Andi
-- 
---
piet@bluelane.com

