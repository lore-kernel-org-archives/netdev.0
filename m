From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH] ipv6: fib: fix fib dump restart
Date: Thu, 24 Apr 2014 10:43:15 -0400
Message-ID: <53592303.4060100@fb.com>
References: <53591645.7010609@fb.com> <1398349084.29914.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51985 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753344AbaDXOmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:42:32 -0400
In-Reply-To: <1398349084.29914.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/24/2014 10:18 AM, Eric Dumazet wrote:
> On Thu, 2014-04-24 at 09:48 -0400, Chris Mason wrote:
>> From: Kumar Sundararajan <kumar@fb.com>
>>
>> When the ipv6 fib changes during a table dump, the walk is
>> restarted and the number of nodes dumped are skipped. But the existing
>> code doesn't advance to the next node after a node is skipped. This can
>> cause the dump to loop or produce lots of duplicates when the fib
>> is modified during the dump.
>>
>> This change advances the walk to the next node if the current node is
>> skipped after a restart.
>>
>> Signed-off-by: Chris Mason <clm@fb.com>
>> ---
>>   net/ipv6/ip6_fib.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> Hi Chris
>
> Who wrote the patch exactly ?
>
> If Kumar did, you need to put the
> "Signed-off-by: Kumar Sundararajan <kumar@fb.com>" before your own

Kumar did write it, I'll grab a sob from him.

-chris
