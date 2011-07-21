From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: v3.0-rc* intermittent network failure: how to debug?
Date: Thu, 21 Jul 2011 16:32:18 +0200
Message-ID: <20110721143218.GA10595@electric-eye.fr.zoreil.com>
References: <1311256194.2980.18.camel@castor.rsk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56268 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1GUOrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 10:47:52 -0400
Content-Disposition: inline
In-Reply-To: <1311256194.2980.18.camel@castor.rsk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Kennedy <richard@rsk.demon.co.uk> :
> I keep seeing a total network failure on v3.0.0-rc* , it is highly
> intermittent, anything from 1 hour to 12+, and I don't have a reliable
> test case.
> When it fails I lose all network comms, but there are no errors in the
> system log, no hung tasks reported, nothing. But after it fails the
> machine hangs during shutdown, it just never turns off. So I guess
> something is getting stuck but I can't find it.

Assuming the kernel hangs late enough, you can try the "reboot=" kernel
parameter and see if a value in arch/x86/include/asm/emergency-restart.h
makes a difference.

> Can you suggest how to find out what going on? 

Switch into text mode before starting the reboot sequence then send a
magic sysrq T or W ?

> I'm going to add a serial console and see if that helps.

It will help, especially with the kilometer long output of sysrq.

> this is on a x86_64, via_velocity currently running 3.0.0-rc7 latest.
> 
> all suggestions gratefully received

Last via-velocity change in mainline dates back to may 25 (see
d10358de8d70aaeb965a974d56e9b72f6c6dbb3a). Were you previously fine
with a recent enough kernel to rule it out ?

-- 
Ueimor
