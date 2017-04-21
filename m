From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6mr: fix notification device destruction
Date: Fri, 21 Apr 2017 15:55:33 -0400 (EDT)
Message-ID: <20170421.155533.1352524502916529670.davem@davemloft.net>
References: <6d7dca26-4bc6-870c-8eb9-409f6c6b8fd5@cumulusnetworks.com>
        <20170421.153635.1878323052363882645.davem@davemloft.net>
        <44095170-e47c-ce85-d0f6-95a24da0e200@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
        dvyukov@google.com, kcc@google.com, syzkaller@googlegroups.com,
        edumazet@google.com, roopa@cumulusnetworks.com,
        torvalds@linux-foundation.org, linux-kernel@vger.kernel.org
To: nikolay@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <44095170-e47c-ce85-d0f6-95a24da0e200@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 21 Apr 2017 22:50:35 +0300

> On 21/04/17 22:36, David Miller wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Date: Fri, 21 Apr 2017 21:30:42 +0300
>> 
>>> On 21/04/17 20:42, Nikolay Aleksandrov wrote:
>>>> Andrey Konovalov reported a BUG caused by the ip6mr code which is caused
>>>> because we call unregister_netdevice_many for a device that is already
>>>> being destroyed. In IPv4's ipmr that has been resolved by two commits
>>>> long time ago by introducing the "notify" parameter to the delete
>>>> function and avoiding the unregister when called from a notifier, so
>>>> let's do the same for ip6mr.
>>  ...
>>> +CC LKML and Linus
>> 
>> Applied, thanks Nikolay and thanks Andrey for the report and testing.
>> 
>> Nikolay, how far does this bug go back?
>> 
> 
> Good question, AFAICS since ip6mr exists because it was copied from ipmr:
> commit 7bc570c8b4f7
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Thu Apr 3 09:22:53 2008 +0900
> 
>     [IPV6] MROUTE: Support multicast forwarding.

Ok will queue it up for -stable.

Thanks.
