From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Congestion Avoidance Monitoring Tools
Date: Fri, 21 Apr 2006 08:19:17 -0700
Message-ID: <20060421081917.34ea952b@localhost.localdomain>
References: <1145597174.12413.17.camel@piet2.bluelane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60346 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932354AbWDUPT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 11:19:29 -0400
To: piet@bluelane.com
In-Reply-To: <1145597174.12413.17.camel@piet2.bluelane.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Apr 2006 22:26:14 -0700
Piet Delaney <piet@bluelane.com> wrote:

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

2.6.13 still had lots of problems, things didn't really get working
right till 2.6.15 or later. Especially with TSO.

I have a tool using kprobe's see http://developer.osdl.org/shemminger/prototypes/tcpprobe.tar.gz
I try to keep it up to date with current kernel and build process, last used it
on 2.6.16.
