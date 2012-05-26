From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 20:11:50 -0400 (EDT)
Message-ID: <20120525.201150.1782581593120395710.davem@davemloft.net>
References: <4FC0063E.8080209@fb.com>
	<20120525.185131.2017517041016424794.davem@davemloft.net>
	<4FC01F1B.1080009@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: asharma@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC01F1B.1080009@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arun Sharma <asharma@fb.com>
Date: Fri, 25 May 2012 17:08:59 -0700

> On 5/25/12 3:51 PM, David Miller wrote:
>> From: Arun Sharma<asharma@fb.com>
>> Date: Fri, 25 May 2012 15:22:54 -0700
>>
>>> On 5/25/12 1:47 PM, Eric Dumazet wrote:
>>>> On Fri, 2012-05-25 at 13:15 -0700, Arun Sharma wrote:
>>>>> The algorithm is based on ipv4 and alloc_large_system_hash().
>>>>>
>>>>
>>>> Why is it needed at all ?
>>>>
>>>> IPv4 has a route cache with potentially millions of entries, not IPv6.
>>>
>>> With the default size of 4096 for the ipv6 routing table, entries can
>>> get garbage collected and hosts could lose their default route and
>>> therefore lose connectivity.
>>>
>>> We actually saw it happen.
>>
>> Under no circumstances should administrator configured ipv6 routes be
>> garbage collected, that is a bug.
> 
> These were not admin configured routes. They were discovered via ipv6
> neighbor discovery.

Then such default routes should either be:

1) Passed over by GC

2) Trigger neighbour discovery when GC'd
