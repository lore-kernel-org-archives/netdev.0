From: Tom Young <tyo@ee.unimelb.edu.au>
Subject: Re: Congestion Avoidance Monitoring Tools
Date: Fri, 21 Apr 2006 15:59:55 +1000
Message-ID: <1145599196.2534.38.camel@penguin>
References: <1145597174.12413.17.camel@piet2.bluelane.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from loki.ee.unimelb.edu.au ([128.250.76.73]:1413 "EHLO
	loki.ee.unimelb.edu.au") by vger.kernel.org with ESMTP
	id S1751194AbWDUGm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 02:42:56 -0400
To: piet@bluelane.com
In-Reply-To: <1145597174.12413.17.camel@piet2.bluelane.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-20 at 22:26 -0700, Piet Delaney wrote:
> I'm upgrading our 2.6.12 kernel to 2.6.13, which includes significant
> congestion avoidance code additions and changes. I was wondering if
> there are any tools folks can recommend for testing the kernel to make
> sure the congestion avoidance code is operating correctly. For 
> example the displaying of the congestion window as a function of time
> while undergoing convergence. For causing congestion I could modify 
> a kernel to discard packets once in a while on a lab gateway and hit 
> it with iperf. HP's netperf looks interesting. 
> 
> Any suggestions?
> 
> 
> -piet
> 

Hi,

Try having a look at the output of 'ss -i' (you may need to update to
the latest iproute2 tools). You could either try and parse the text
output of that or use the same inet_diag interface that ss uses to poll
for the data it at regular intervals.

-- 
Thomas Young
http://cubinlab.ee.unimelb.edu.au/~tyo/
Research Assistant
CUBIN Research Centre - University of Melbourne

