From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 10:30:06 -0400
Message-ID: <20090417143006.GB2723@hmsreliant.think-freely.org>
References: <200904171257.n3HCvOba029938@post.webmailer.de> <20090417132848.GA2723@hmsreliant.think-freely.org> <49E88F2A.4010301@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41929 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbZDQOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:30:17 -0400
Content-Disposition: inline
In-Reply-To: <49E88F2A.4010301@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 04:16:10PM +0200, Oliver Hartkopp wrote:
> Hi Neil,
> 
> >> Initalizing kallsyms db
> >> dropwatch> start
> >> Enabling monitoring...
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Failed activation request, error: Operation now in progress
> >> Shutting down ...
> >> vwagwolkf320:/home/hartko/dropwatch/src# 
> 
> Indeed i only get this the second time.
> 
> The first time i get
> 
> hartko@vwagwolkf320:~/dropwatch/src$ ./dropwatch
> Initalizing kallsyms db
> dropwatch> start
> Enabling monitoring...
> Kernel monitoring activated.
> Issue Ctrl-C to stop monitoring
> 
> But Ctrl-C does not work. I only get 100% CPU load on the CPU executing dropwatch.
> 
> After killing the process, i get the above originally described behaviour.
> 
Thats interesting, can't say I've ever seen that behavior before.  I'm building
the latest net-next kernel on my s32 bit system right now, I'll let you know
what I come up with.

> 
> >>
> >> And in my kernel log i get at the same time:
> >> [ 7070.568482] netlink: 60 bytes leftover after parsing attributes.
> 
> And this comes every time, i invoke dropwatch.
> 
I'll watch for this.

> I'm running a debian system here on a Dell 830 Laptop with Core2Duo and the
> latest linux-2.6 git
> 
Thank you

> Regards,
> Oliver
> 
> ps. Do i need to be root to run dropwatch?
> 
IIRC, at the moment you do yes, since NETLINK_GENERIC family lookups are
restricted to root access only.  I hope to change that one day

Neil

> 
