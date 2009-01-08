From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 08 Jan 2009 13:11:32 -0800
Message-ID: <49666C04.6050605@candelatech.com>
References: <20090108093430.0f966738@extreme>	<20090108.112420.102641584.davem@davemloft.net>	<20090108121220.789325a6@extreme> <20090108.125830.142298950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50541 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756273AbZAHVLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:11:42 -0500
In-Reply-To: <20090108.125830.142298950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 8 Jan 2009 12:12:20 -0800
> 
>> What about this?
>>
>> If it works (still testing), I'll submit it.
> 
> So what is your plan?
> 
> Make the routing daemons depend upon the non-default
> behavior in order to act correctly?

They could check and take corrective action or tell the user
to set it one way or another.  Robust and complex apps already
have to check all sorts of things anyway.

> Or is it to gradually get people to use the non-default
> (via distribution sysctl settings etc.) and eventually
> make it the default?
> 
> I disagree with both plans, and with that the facility
> is basically useless.
> 
> We absolutely have to live with the behavior we have now,
> and for a long time if not forever.

It could be argued we need to have the default behaviour stay
the same, but that's no reason to keep things difficult for
people/programs flexible enough to deal with change.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

