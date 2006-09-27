From: Rick Jones <rick.jones2@hp.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 10:57:07 -0700
Message-ID: <451ABB73.1050606@hp.com>
References: <20060926145113.7a6791c8@freekitty>	<4519A1D6.1050802@pobox.com>	<20060926150947.3d538547@freekitty>	<451A7603.1030204@roinet.com> <451AAFFE.2020607@hp.com> <451AB9CB.6010906@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:4021 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1030499AbWI0R5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 13:57:08 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <451AB9CB.6010906@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Rick Jones wrote:
> 
>>> With mii-tool we can do the command below and work with a half duplex 
>>> hub and a full duplex switch.
>>> mii-tool -A 10baseT-FD,10baseT-HD eth0
>>
>>
>> Why, and how often, is that really necessary?
> 
> 
> This is a bit of a hypothetical discussion of course, but I can imagine 
> a lot of users with 100mbit switches in their homes (imagine all the 
> DSL/cable routers out there...) that want to stop their nic from 
> attempting to negotiate 1000mbit.

That would be covered by autosense right?  IIRC there haven't been issues with 
speed sensing, just duplex negotiation right?

> Another scenario: forcing the NIC to negotiate only full-duplex speeds. 
> Not only fun if you try it against a hub, but possibly useful.
> 
> For us it's much more interesting because we try every damn impossible 
> configuration anyway and see what gives (or breaks).
> 
> Anyway, a patch to make ethtool do this was merged as Jeff Kirsher 
> pointed out, so you can do this now with ethool too.

I'm just worried (as in Fear Uncertainty and Doubt) that having people set the 
allowed things to negotiate isn't really any more robust than stright-up 
hardcodes and perpetuates the (IMO) myth that one shouldn't autoneg on general 
principle.

rick

> 
> Cheers,
> 
> Auke

