From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than
 10 times.
Date: Wed, 04 Aug 2010 14:13:50 -0700
Message-ID: <4C59D80E.3020804@candelatech.com>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com> <20100804140012.577b2195@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49525 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600Ab0HDVNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 17:13:54 -0400
In-Reply-To: <20100804140012.577b2195@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2010 02:00 PM, Stephen Hemminger wrote:
> On Mon, 28 Jun 2010 22:55:59 -0700
> greearb@gmail.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> The default remains at 10 for backwards compatibility.
>>
>> For instance:
>>   # ip addr flush dev eth2
>>   *** Flush remains incomplete after 10 rounds. ***
>>   # ip -l 20 addr flush dev eth2
>>   *** Flush remains incomplete after 20 rounds. ***
>>   # ip -loops 0 addr flush dev eth2
>>   #
>>
>> This is useful for getting rid of large numbers of IP
>> addresses in scripts.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> The current userspace driven flush behavior is crap.
> There really should be an atomic flush netlink message
> with kernel support.

No argument from me, but I've no time to figure out how
to do that properly.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
