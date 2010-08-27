From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative addresses.
Date: Thu, 26 Aug 2010 21:24:23 -0700
Message-ID: <4C773DF7.8050508@candelatech.com>
References: <4C76C73F.4080206@hp.com>	<20100826.131801.246519955.davem@davemloft.net>	<4C76DA62.8040109@candelatech.com> <20100826.142755.15249596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38066 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0H0EY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:24:27 -0400
In-Reply-To: <20100826.142755.15249596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 02:27 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 26 Aug 2010 14:19:30 -0700
>
>> In our case, we enable IPv6 in user-space, and then we want to get
>> some immediate indication that indeed the process is working as
>> expected.
>
> When DAD completes, you'll get a similar indication.
>
>> In other cases, we want to remove all IPv6 addresses, so if we have
>> not even been notified that the IP exists, then we cannot know how
>> to delete it.
>
> You can add a netlink message to accomplish that.  This has been
> asked for in other contexts as well.
>
>> We've been running this patch for several years, and it has not
>> caused any obvious problems with other tools, so I think it's safe
>> enough.
>
> And your level of exposure compared to upstream is...? :-)
>
> Anyways, even if it's implemented in an error free way it's still
> not necessary the best way to go about this.

Ok, lets not worry about this patch any more then.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
