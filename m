From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 17:08:59 -0700
Message-ID: <4FC01F1B.1080009@fb.com>
References: <1337976934-18065-1-git-send-email-asharma@fb.com> <1337978820.10135.1.camel@edumazet-glaptop> <4FC0063E.8080209@fb.com> <20120525.185131.2017517041016424794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47911 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752474Ab2EZAJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 20:09:14 -0400
In-Reply-To: <20120525.185131.2017517041016424794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/25/12 3:51 PM, David Miller wrote:
> From: Arun Sharma<asharma@fb.com>
> Date: Fri, 25 May 2012 15:22:54 -0700
>
>> On 5/25/12 1:47 PM, Eric Dumazet wrote:
>>> On Fri, 2012-05-25 at 13:15 -0700, Arun Sharma wrote:
>>>> The algorithm is based on ipv4 and alloc_large_system_hash().
>>>>
>>>
>>> Why is it needed at all ?
>>>
>>> IPv4 has a route cache with potentially millions of entries, not IPv6.
>>
>> With the default size of 4096 for the ipv6 routing table, entries can
>> get garbage collected and hosts could lose their default route and
>> therefore lose connectivity.
>>
>> We actually saw it happen.
>
> Under no circumstances should administrator configured ipv6 routes be
> garbage collected, that is a bug.

These were not admin configured routes. They were discovered via ipv6 
neighbor discovery.

  -Arun
