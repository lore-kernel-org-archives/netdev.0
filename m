From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Fri, 28 Aug 2009 23:42:10 -0700 (PDT)
Message-ID: <20090828.234210.62256310.davem@davemloft.net>
References: <20090827235506.624381734@vyatta.com>
	<20090828.233320.168126607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org, tglx@linutronix.de
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbZH2Gl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:41:56 -0400
In-Reply-To: <20090828.233320.168126607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 28 Aug 2009 23:33:20 -0700 (PDT)

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 27 Aug 2009 16:55:06 -0700
> 
>> The biggest change is switching to monotonic clock (ktime) and
>> high resolution timers for the interpacket delay.
> 
> Ok, even though there were some issues with the TX return
> values wrt. VLANS, I've applied all of this.
> 
> The cleanups were good and hrtimers and ktime_t are definitely
> the direction this code should go in.
> 
> It would be good if this new stuff got a lot of testing and debugging
> though.

BTW, to make this build in all cases I had to add a symbol export
for hrtimer_init_on_stack().
