From: Ben Greear <greearb@candelatech.com>
Subject: Re: increase the number of routing tables
Date: Mon, 30 Jan 2012 09:26:25 -0800
Message-ID: <4F26D2C1.7030108@candelatech.com>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com> <1327804887.2805.20.camel@edumazet-laptop> <4F24B2E9.3010600@candelatech.com> <20120129.160152.1463516627658543873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, simonchennj@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40452 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab2A3R0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:26:32 -0500
In-Reply-To: <20120129.160152.1463516627658543873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2012 01:01 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Sat, 28 Jan 2012 18:46:01 -0800
>
>> On 01/28/2012 06:41 PM, Eric Dumazet wrote:
>>> Its is possible, but probably not scalable.
>>
>> I've run with a few thousand routing tables and probably 5000 or so
>> rules.  It seems to run OK....
>>
>>> You really should not have too many "ip rule" entries, since they are
>>> evaluated linearly.
>>
>> For every packet, or maybe just until conn-track gets an entry
>> for the connection?
>
> When the routing cache is removed, using a huge number of rules is not
> going to be something you want to do any more because the rule table
> will be inspected on every route lookup.

Well, that sounds like a reason to keep the routing cache around,
even if it isn't used by default, perhaps.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
