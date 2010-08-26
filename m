From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative addresses.
Date: Thu, 26 Aug 2010 14:19:30 -0700
Message-ID: <4C76DA62.8040109@candelatech.com>
References: <20100825.212456.71107442.davem@davemloft.net>	<4C76B770.4030800@candelatech.com>	<4C76C73F.4080206@hp.com> <20100826.131801.246519955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46726 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab0HZVTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 17:19:34 -0400
In-Reply-To: <20100826.131801.246519955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 01:18 PM, David Miller wrote:
> From: Brian Haley<brian.haley@hp.com>
> Date: Thu, 26 Aug 2010 15:57:51 -0400
>
>> But then we get a message for an address that can't be used because
>> it hasn't passed DAD, I'm not so sure that is a good thing,
>> especially if we don't get notified when it passes DAD.
>
> I think that we shouldn't send notifications for an address that can't
> even be used.  So essentially I argue against this patch in any form :)

In our case, we enable IPv6 in user-space, and then we want to get some
immediate indication that indeed the process is working as expected.

In other cases, we want to remove all IPv6 addresses, so if we have not
even been notified that the IP exists, then we cannot know how to delete it.

In my patch, we still get the update when DAD completes, so applications
can take note of the flags if they care about the details.

We've been running this patch for several years, and it has not caused
any obvious problems with other tools, so I think it's safe enough.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

