From: Ben Greear <greearb@candelatech.com>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 09:16:34 -0700
Message-ID: <46853062.9090009@candelatech.com>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>	 <46840AF5.4020209@trash.net>	 <20070628.212032.108743475.davem@davemloft.net>	 <1183117415.5156.61.camel@localhost>  <4684F41B.9080309@trash.net> <1183121670.5188.16.camel@localhost> <46850450.6040608@trash.net> <46852632.5050707@candelatech.com> <46852C20.8000501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54309 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758920AbXF2QQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 12:16:40 -0400
In-Reply-To: <46852C20.8000501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
>   
>> Could someone give a quick example of when I am wrong and promisc mode
>> would allow
>> a NIC to receive a significant number of packets not really destined for
>> it?
>>     
>
>
> In a switched environment it won't have a big effect, I agree.
> It might help avoid receiving unwanted multicast traffic, which
> could be more significant than unicast.
>
> Anyways, why be wasteful when it can be avoided .. :)
>   
Ok, I had forgotten about multicast, thanks for the reminder!

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


