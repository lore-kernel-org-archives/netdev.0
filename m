From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp
 cache
Date: Wed, 15 Mar 2017 16:45:08 -0700 (PDT)
Message-ID: <20170315.164508.1392215340407263261.davem@davemloft.net>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
        <20170315.154044.170788541865531834.davem@davemloft.net>
        <1489618741.28631.172.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdCOXqe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 19:46:34 -0400
In-Reply-To: <1489618741.28631.172.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Mar 2017 15:59:01 -0700

> On Wed, 2017-03-15 at 15:40 -0700, David Miller wrote:
>> From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
>> Date: Wed, 15 Mar 2017 16:30:45 -0400
>> 
>> > Note that this cache was already broken for caching timestamps of
>> > multiple machines behind a NAT sharing the same address.
>> 
>> That's the documented, well established, limitation of time-wait
>> recycling.
>> 
>> People who enable it, need to consider this issue.
>> 
>> This limitation of the feature does not give us a reason to break the
>> feature even further as a matter of convenience, or to remove it
>> altogether for the same reason.
>> 
>> Please, instead, fix the bug that was introduced.
>> 
>> Thank you.
> 
> You mean revert Florian nice patches ?
> 
> This would kill timestamps randomization, and thus prevent some
> organizations to turn TCP timestamps on.
> 
> TCP timestamps are more useful than this obscure tw_recycle thing that
> is hurting innocent users.

Ok, I guess we can remove it in that case.  I'm still a bit disappointed
as I was always hoping someone would find a way to make this work even
in the presence of NAT.

I must be too optimistic.
