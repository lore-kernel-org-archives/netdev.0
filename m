From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH 2/6 net-next] inet: drop ->bind_conflict
Date: Thu, 12 Jan 2017 16:04:31 -0500
Message-ID: <1484255071.11807.0@smtp.office365.com>
References: <1484165171-19210-1-git-send-email-jbacik@fb.com>
        <1484166164-21250-1-git-send-email-jbacik@fb.com>
        <20170112.145640.2151487482259137455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: <hannes@stressinduktion.org>, <kraigatgoog@gmail.com>,
        <eric.dumazet@gmail.com>, <tom@herbertland.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43859 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750730AbdALVE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:04:56 -0500
In-Reply-To: <20170112.145640.2151487482259137455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 2:56 PM, David Miller <davem@davemloft.net> 
wrote:
> From: Josef Bacik <jbacik@fb.com>
> Date: Wed, 11 Jan 2017 15:22:40 -0500
> 
>>  diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>>  index 56d756e..dc07734 100644
>>  --- a/net/ipv4/tcp_ipv4.c
>>  +++ b/net/ipv4/tcp_ipv4.c
>>  @@ -63,6 +63,7 @@
>>   #include <linux/times.h>
>>   #include <linux/slab.h>
>> 
>>  +#include <net/addrconf.h>
>>   #include <net/net_namespace.h>
>>   #include <net/icmp.h>
>>   #include <net/inet_hashtables.h>
> 
> I don't see what this has to do with this change.

Ugh sorry, that's a left over from when I had the protocol specific 
callback for the saddr_equal stuff, I'll fix that up.  Thanks,

Josef
