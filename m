From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: Re: v3.0-rc* intermittent network failure: how to debug?
Date: Thu, 21 Jul 2011 16:18:44 +0100
Message-ID: <1311261527.2980.26.camel@castor.rsk>
References: <1311256194.2980.18.camel@castor.rsk>
	 <20110721143218.GA10595@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lon1-post-3.mail.demon.net ([195.173.77.150]:41550 "EHLO
	lon1-post-3.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752426Ab1GUPob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 11:44:31 -0400
In-Reply-To: <20110721143218.GA10595@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-21 at 16:32 +0200, Francois Romieu wrote:
> Richard Kennedy <richard@rsk.demon.co.uk> :
> > I keep seeing a total network failure on v3.0.0-rc* , it is highly
> > intermittent, anything from 1 hour to 12+, and I don't have a reliable
> > test case.
> > When it fails I lose all network comms, but there are no errors in the
> > system log, no hung tasks reported, nothing. But after it fails the
> > machine hangs during shutdown, it just never turns off. So I guess
> > something is getting stuck but I can't find it.
> 
> Assuming the kernel hangs late enough, you can try the "reboot=" kernel
> parameter and see if a value in arch/x86/include/asm/emergency-restart.h
> makes a difference.
> 
> > Can you suggest how to find out what going on? 
> 
> Switch into text mode before starting the reboot sequence then send a
> magic sysrq T or W ?
> 
> > I'm going to add a serial console and see if that helps.
> 
> It will help, especially with the kilometer long output of sysrq.
> 
> > this is on a x86_64, via_velocity currently running 3.0.0-rc7 latest.
> > 
> > all suggestions gratefully received
> 
> Last via-velocity change in mainline dates back to may 25 (see
> d10358de8d70aaeb965a974d56e9b72f6c6dbb3a). Were you previously fine
> with a recent enough kernel to rule it out ?
> 

Thanks Francois,
I'll try the reboot= tomorrow.

I don't really know when my last know good was, it could be that
via-velocity change, but the problem is so intermittent it's difficult
to be sure. I've been trying to stress the network to make the problem
happen sooner but I've had no luck yet.

regards
Richard  

