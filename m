From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 14:36:50 -0700 (PDT)
Message-ID: <20070629.143650.63998980.davem@davemloft.net>
References: <1183121670.5188.16.camel@localhost>
	<46850450.6040608@trash.net>
	<46852632.5050707@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752466AbXF2Vga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 17:36:30 -0400
In-Reply-To: <46852632.5050707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 29 Jun 2007 08:33:06 -0700

> Patrick McHardy wrote:
> > Right, but the current bridging code always uses promiscous mode
> > and its nice to avoid that if possible. Looking at the code, it
> > should be easy to avoid though by disabling learning (and thus
> > promisous mode) and adding unicast filters for all static fdb entries.
> >   
> I am curious about why people are so hot to do away with promisc mode.  
> It seems to me
> that in a modern switched environment, there should only very rarely be 
> unicast packets received
> on an interface that does not want to receive them.
> 
> Could someone give a quick example of when I am wrong and promisc mode 
> would allow
> a NIC to receive a significant number of packets not really destined for it?

You're neighbour on the switch is being pummeled with multicast traffic,
and now you get to see it all too.

Switches don't obviate the cost of promiscuous mode, you keep wanting
to discuss this and think it doesn't matter, but it does.

And some people still use hubs, believe it or not.
