From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 6/8]  pxa: make lubbock to use smc91x platform data
Date: Fri, 20 Jun 2008 09:23:07 +0800
Message-ID: <485B067B.1080207@gmail.com>
References: <485A3E4A.6070706@gmail.com> <alpine.LFD.1.10.0806191243400.2982@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:51385 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbYFTBXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 21:23:15 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5446297rvb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 18:23:14 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0806191243400.2982@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Pitre wrote:
> On Thu, 19 Jun 2008, Eric Miao wrote:
> 
>> Signed-off-by: Eric Miao <eric.miao@marvell.com>
> 
> This (and 7/8 and 8/8) are a bit unfortunate.  Maybe not as visible on 
> Lubbock which has a SMC91C94 which can do 10mbps only, but the others 
> will have poorer performances because of those patches.  Did you compare 
> performances, let's say with netperf, before and after those patches are 
> applied?
> 
> I understand your goal of wanting to have a single kernel image that 
> dynamically can select the right bus access method for all the concerned 
> platforms.  But I think you'll see that the runtime overhead has a 
> significant impact on network throughput and CPU usage.
> 
> I think that some other solution should be explored such that when only 
> one machine type (or machine types with the same bus config) is 
> configured then the compile time optimizations should remain.  Something 
> based on the machine_is_lubbock(), machine_is_Mainstone(), and so on, 
> which becomes constants with the right kernel configuration.
> 

OK, I know your concern. Let's see if we can work this out in another way.

> 
> Nicolas

