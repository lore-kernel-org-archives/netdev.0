From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: Statically initialize init_net.dev_base_head
Date: Wed, 18 Jul 2012 14:56:11 -0700
Message-ID: <500730FB.4060204@intel.com>
References: <20120718.132010.1765790775051953381.davem@davemloft.net> <20120718202159.GA30706@hmsreliant.think-freely.org> <50071D11.7080207@intel.com> <20120718.133243.1384365436939730847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, mark.d.rustad@intel.com,
	netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44284 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab2GRV4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 17:56:12 -0400
In-Reply-To: <20120718.133243.1384365436939730847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 1:32 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Wed, 18 Jul 2012 13:31:13 -0700
>
>> On 7/18/2012 1:21 PM, Neil Horman wrote:
>>> On Wed, Jul 18, 2012 at 01:20:10PM -0700, David Miller wrote:
>>>> From: Neil Horman <nhorman@tuxdriver.com>
>>>> Date: Wed, 18 Jul 2012 16:11:49 -0400
>>>>
>>>>> On Wed, Jul 18, 2012 at 12:06:07PM -0700, Mark Rustad wrote:
>>>>>> This change eliminates an initialization-order hazard most
>>>>>> recently seen when netprio_cgroup is built into the kernel.
>>>>>>
>>>>>> With thanks to Eric Dumazet for catching a bug.
>>>>>>
>>>>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>>>    ...
>>>>> I think dave was going to take John Fastabends patch from earlier
>>>>> today, but
>>>>> this works just as well.  Long term I'm going to look into delaying
>>>>> initzlization for cgroups, as it creates a strange initialization
>>>>> state when you
>>>>> have a module_init routine registered.
>>>>
>>>> Neil, any particular preference between John's and Mark's version
>>>> of the fix?
>>>>
>>> I think they're both perfectly good.  If I had to choose I'd say
>>> Marks, just
>>> because its done by initializing data, rather than adding more code to
>>> run every
>>> time we create a cgroup.
>>>
>>> Neil
>>>
>>
>> Fine by me if we take this version instead.
>
> I think that's what I'll do, sorry for all the trouble John :)
>

No problem. For what its worth verified this resolved the netprio
issue on my system as expected.
