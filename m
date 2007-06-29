From: Ben Greear <greearb@candelatech.com>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 08:33:06 -0700
Message-ID: <46852632.5050707@candelatech.com>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>	 <46840AF5.4020209@trash.net>	 <20070628.212032.108743475.davem@davemloft.net>	 <1183117415.5156.61.camel@localhost>  <4684F41B.9080309@trash.net> <1183121670.5188.16.camel@localhost> <46850450.6040608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42547 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825AbXF2PdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 11:33:21 -0400
In-Reply-To: <46850450.6040608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Right, but the current bridging code always uses promiscous mode
> and its nice to avoid that if possible. Looking at the code, it
> should be easy to avoid though by disabling learning (and thus
> promisous mode) and adding unicast filters for all static fdb entries.
>   
I am curious about why people are so hot to do away with promisc mode.  
It seems to me
that in a modern switched environment, there should only very rarely be 
unicast packets received
on an interface that does not want to receive them.

Could someone give a quick example of when I am wrong and promisc mode 
would allow
a NIC to receive a significant number of packets not really destined for it?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


