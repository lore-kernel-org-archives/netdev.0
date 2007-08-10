From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 15:40:02 -0700
Message-ID: <46BCE942.1030107@candelatech.com>
References: <20070810202426.GA25050@havoc.gtf.org>	<46BCD263.6050807@garzik.org>	<46BCD47C.9060408@candelatech.com> <20070810.151039.31642625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50560 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759088AbXHJWkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 18:40:15 -0400
In-Reply-To: <20070810.151039.31642625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>

>> I believe LRO is going to have to be disabled for routing/bridging,
>> so the stack will probably need to become aware of it at some point...
> 
> The packet will be GSO'd on output I believe, so it won't
> break anything.
> 
> Alternatively, we could make the driver only LRO accumulate if the
> packet is unicast and matches one of the MAC's programmed into the
> chip.

I think even this would fail if you are doing something clever with
NAT or other iptables stuff.  Probably we're going to have to put this
in the hands of the users..who hopefully can determine whether they
can allow LRO or not...

For GSO on output, is there a generic fallback for any driver that
does not specifically implement GSO?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

