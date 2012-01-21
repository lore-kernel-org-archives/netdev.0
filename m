From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sat, 21 Jan 2012 09:48:52 -0800
Message-ID: <4F1AFA84.5050201@candelatech.com>
References: <4F035BDE.5060409@candelatech.com> <20120103.145931.2188599484081157576.davem@davemloft.net> <4F035F2C.1000003@candelatech.com> <m3fwf9gdjm.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53665 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab2AURtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 12:49:09 -0500
In-Reply-To: <m3fwf9gdjm.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2012 09:39 AM, Krzysztof Halasa wrote:
> Ben Greear<greearb@candelatech.com>  writes:
>
>>>> As far as I can tell, no other interfaces are auto-created
>>>> in this manner.
>>>
>>> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
>>> net/{ipv4,ipv6}/
>>
>> So, no changing the behaviour?
>
> Perhaps making it CONFIGurable would be safe enough, not that I like
> CONFIG options for all tiny details (one may argue it's not a tiny
> detail).
>
> Haven't looked at the actual code.

Seems like it could be a run-time configurable, maybe module or boot option
or sysctl or something.

I haven't looked any more at the code either...maybe next week (tm).

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
