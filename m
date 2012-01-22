From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sun, 22 Jan 2012 08:48:53 -0800
Message-ID: <4F1C3DF5.8070802@candelatech.com>
References: <4F035F2C.1000003@candelatech.com> <m3fwf9gdjm.fsf@intrepid.localdomain> <4F1AFA84.5050201@candelatech.com> <20120121.134036.1565691107664746948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36744 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab2AVQtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 11:49:09 -0500
In-Reply-To: <20120121.134036.1565691107664746948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2012 10:40 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Sat, 21 Jan 2012 09:48:52 -0800
>
>> On 01/21/2012 09:39 AM, Krzysztof Halasa wrote:
>>> Ben Greear<greearb@candelatech.com>   writes:
>>>
>>>>>> As far as I can tell, no other interfaces are auto-created
>>>>>> in this manner.
>>>>>
>>>>> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
>>>>> net/{ipv4,ipv6}/
>>>>
>>>> So, no changing the behaviour?
>>>
>>> Perhaps making it CONFIGurable would be safe enough, not that I like
>>> CONFIG options for all tiny details (one may argue it's not a tiny
>>> detail).
>>>
>>> Haven't looked at the actual code.
>>
>> Seems like it could be a run-time configurable, maybe module or boot
>> option
>> or sysctl or something.
>
> I would seriously prefer that you not do this.

Just to make sure I understand you:  You dislike any possible method of changing
the behaviour, not just the ones I listed?

If I do post a patch, it will be just for comment should someone
else want to carry the patch privately, and I'll just carry the patch
in my tree.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
