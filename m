From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-2.6.25] qdisc: new rate limiter
Date: Sat, 08 Dec 2007 13:59:11 -0800
Message-ID: <475B13AF.9090507@candelatech.com>
References: <20071207162618.35715892@freepuppy.rosehill> <475A0804.1060006@trash.net> <475A0959.20701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:41731 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbXLHV7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 16:59:18 -0500
In-Reply-To: <475A0959.20701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Stephen Hemminger wrote:
>>>
>>> +struct tc_rlim_qopt
>>> +{
>>> +    __u32   limit;        /* fifo limit (packets) */
>>> +    __u32    rate;        /* bits per sec */
>>>   
>>
>> This seems a bit small, 512mbit is the maximum rate.
>
> Its 4gbit of course, so I guess its enough :)
Even 4Gbps is well within the means of today's commodity 
hardware...seems easier to bump
to 64 bits now rather than have to make some backwards-compat hack a 
year from now...

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


