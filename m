From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/4] net: vrf: call
 netdev_lockdep_set_classes()
Date: Thu, 09 Jun 2016 00:09:57 -0700 (PDT)
Message-ID: <20160609.000957.1216711130886558488.davem@davemloft.net>
References: <1465442964-5786-2-git-send-email-edumazet@google.com>
	<c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com>
	<CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161269AbcFIHJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:09:58 -0400
In-Reply-To: <CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 8 Jun 2016 21:01:35 -0700

> On Wed, Jun 8, 2016 at 8:41 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 6/8/16 9:29 PM, Eric Dumazet wrote:
>>>
>>> In case a qdisc is used on a vrf device, we need to use different
>>> lockdep classes to avoid false positives.
>>>
>>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>>> seqcount")
>>> Reported-by: David Ahern <dsa@cumulusnetworks.com>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>
>>
>> same result with this patch set.
>>
> 
> Are you stacking multiple vrf devices ?

Ok I'm holding off on this patch series until this is resolved.
