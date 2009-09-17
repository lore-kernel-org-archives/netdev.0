From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [crash] kernel BUG at net/core/pktgen.c:3503!
Date: Thu, 17 Sep 2009 21:51:55 +0400
Message-ID: <20090917175155.GC8817@lenovo>
References: <20090911.202543.52533792.davem@davemloft.net> <20090915183647.GA11628@elte.hu> <20090915185112.GA17587@lenovo> <20090917.102923.174779685.davem@davemloft.net> <20090917174448.GA9548@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:41262 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbZIQRvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:51:54 -0400
Content-Disposition: inline
In-Reply-To: <20090917174448.GA9548@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Ingo Molnar - Thu, Sep 17, 2009 at 07:44:48PM +0200]
...
| 
| > 
| > Ingo, does Cyrill's patch help?
| 
| For now i've turned pktgen off in my tests. Will check it again once 
| things have calmed down somewhat.
| 
| Also, i just tried to reproduce the pktgen crash with latest -git and 
| the config i sent - no luck, so i cannot test Cyrill's patch either.
| 
| Btw., we are seeing some other preempt count and task related 
| weirdnesses as well in other code, maybe it's related. No good pattern 
| yet to act upon.
| 
| Anyway - please disregard this bugreport until i've investigated it 
| closer.
| 
| 	Ingo
| 

I'm unable to reproduce this issue too. I was trying
many ways (under kvm) -- no bug triggered. Though on
a system for which I had done this patch in first place
the bug was been hitting all the time (but it contains
custom vcpu management code, which is not our case here).

	-- Cyrill
