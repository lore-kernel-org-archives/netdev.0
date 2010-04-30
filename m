From: David Miller <davem@davemloft.net>
Subject: Re: OFT - reserving CPU's for networking
Date: Fri, 30 Apr 2010 15:30:38 -0700 (PDT)
Message-ID: <20100430.153038.62351857.davem@davemloft.net>
References: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
	<20100430.115715.216750975.davem@davemloft.net>
	<20100430210131.GA2833@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759795Ab0D3Wad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 18:30:33 -0400
In-Reply-To: <20100430210131.GA2833@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 30 Apr 2010 23:01:31 +0200

> Besides it seems to me that dispatching is something the NIC should
> just do directly. "RPS only CPU" would be essentially just an 
> interrupt mitigation/flow redirection scheme that a lot of NICs
> do anyways.

We've already established that the NIC can't do a complete job in all
important cases, that's why we've integrated the RPS/RFS patches in
the first place.

And we don't want it to, because the decision mechanisms for steering
that we using now are starting to get into the stateful territory and
that's verbotton for NIC offload as far as we're concerned.
