From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 14:14:00 -0700
Message-ID: <506B5918.605@intel.com>
References: <1349121884.12401.721.camel@edumazet-glaptop> <1349192133.12401.768.camel@edumazet-glaptop> <1349192919.12401.778.camel@edumazet-glaptop> <20121002.142502.1702895723099297167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de, davej@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37534 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932275Ab2JBVNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 17:13:53 -0400
In-Reply-To: <20121002.142502.1702895723099297167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2012 11:25 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 02 Oct 2012 17:48:39 +0200
>
>> [PATCH] ipv4: properly cache forward routes
>>
>> commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
>> introduced a regression for forwarding.
>>
>> This was hard to reproduce but the symptom was that packets were
>> delivered to local host instead of being forwarded.
>>
>> Add a separate cache (nh_rth_forward) to solve the problem.
>>
>> Many thanks to Chris Clayton for his patience and help.
>>
>> Reported-by: Chris Clayton <chris2553@googlemail.com>
>> Bisected-by: Chris Clayton <chris2553@googlemail.com>
>> Reported-by: Dave Jones <davej@redhat.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Thanks for figuring this out, I'll think about this more
> deeply.
I think something may have been missed in this patch.

With it applied to net-next I am unable to remove the ixgbe driver after
running a routing traffic test.  The specific message I am getting is:
    unregister_netdevice: waiting for eth2 to become free. Usage count = -7

Thanks,

Alex
