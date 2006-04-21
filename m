From: Andi Kleen <ak@suse.de>
Subject: Re: Congestion Avoidance Monitoring Tools
Date: Fri, 21 Apr 2006 08:57:18 +0200
Message-ID: <200604210857.19084.ak@suse.de>
References: <1145597174.12413.17.camel@piet2.bluelane.com> <1145599196.2534.38.camel@penguin>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: piet@bluelane.com, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52932 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751152AbWDUG5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 02:57:37 -0400
To: Tom Young <tyo@ee.unimelb.edu.au>
In-Reply-To: <1145599196.2534.38.camel@penguin>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 April 2006 07:59, Tom Young wrote:
> On Thu, 2006-04-20 at 22:26 -0700, Piet Delaney wrote:
> > I'm upgrading our 2.6.12 kernel to 2.6.13, which includes significant
> > congestion avoidance code additions and changes. I was wondering if
> > there are any tools folks can recommend for testing the kernel to make
> > sure the congestion avoidance code is operating correctly. For 
> > example the displaying of the congestion window as a function of time
> > while undergoing convergence. For causing congestion I could modify 
> > a kernel to discard packets once in a while on a lab gateway and hit 
> > it with iperf. HP's netperf looks interesting. 
> > 
> > Any suggestions?
> > 
> > 
> > -piet
> > 
> 
> Hi,
> 
> Try having a look at the output of 'ss -i' (you may need to update to
> the latest iproute2 tools). You could either try and parse the text
> output of that or use the same inet_diag interface that ss uses to poll
> for the data it at regular intervals.

Another way is to use tcptrace on a tcpdump file
(http://jarok.cs.ohiou.edu/software/tcptrace/) 
It finds a lot of statistics about the dumped TCP connections.

Newer ethereal also has some TCP plotting functions that are useful.
They don't display the congestion window directly, but you can see it indirectly.

-Andi
