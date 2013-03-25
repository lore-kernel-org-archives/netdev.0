From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 25 Mar 2013 16:23:08 -0400 (EDT)
Message-ID: <20130325.162308.2256591153052830191.davem@davemloft.net>
References: <20130319.175612.1450380502469601673.davem@davemloft.net>
	<CALnjE+rjnWs7z3_R3k6Fy_8jzYb7jJL-LnkjypTBmsyXs-xuhA@mail.gmail.com>
	<20130325.153934.1155634067907894585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab3CYUXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 16:23:12 -0400
In-Reply-To: <20130325.153934.1155634067907894585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 25 Mar 2013 15:39:34 -0400 (EDT)

> From: Pravin Shelar <pshelar@nicira.com>
> Date: Mon, 25 Mar 2013 12:30:46 -0700
> 
>> On Tue, Mar 19, 2013 at 2:56 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Pravin Shelar <pshelar@nicira.com>
>>> Date: Tue, 19 Mar 2013 14:38:11 -0700
>>>
>>>> On Tue, Mar 19, 2013 at 2:26 PM, David Miller <davem@davemloft.net> wrote:
>>>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>>>> Date: Tue, 19 Mar 2013 14:21:41 -0700
>>>>>
>>>>>> Doesn't build with this patch alone (ie. not bisectable).
>>>>>>
>>>>>>   CC [M]  net/ipv6/ip6_gre.o
>>>>>> net/ipv6/ip6_gre.c:41:27: fatal error: net/ip_tunnel.h: No such file or directory
>>>>>> compilation terminated.
>>>>>
>>>>> Oh well, too late, it's all already in my tree.
>>>>
>>>> sorry about that.
>>>> I am sending update patch soon.
>>>
>>> There is nothing for you to send, what's in my tree is not changing.
>> 
>> I do not see these patches in net-next and now there are few conflicts
>> due GRE commits.
>> Do you want me to send updated patches against latest net-next?
> 
> You need to send whatever relative fixes are necessary.

Actually I see where the confusion is.

I thought I had applied v3 of this series, looks like I didn't,
so yes you should respin this fixing the build problems Stephen
pointed out.

Thanks.
