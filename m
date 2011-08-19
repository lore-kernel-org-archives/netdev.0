From: David Miller <davem@davemloft.net>
Subject: Re: net: rps: support 802.1Q
Date: Thu, 18 Aug 2011 22:26:52 -0700 (PDT)
Message-ID: <20110818.222652.888994167657545475.davem@davemloft.net>
References: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com>
	<20110818.220805.1212231373721016529.davem@davemloft.net>
	<CABa6K_EG7ccoKk4YDFc4us269pA7BRaFhb_1XhoedR1cJ+GeXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab1HSF05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:26:57 -0400
In-Reply-To: <CABa6K_EG7ccoKk4YDFc4us269pA7BRaFhb_1XhoedR1cJ+GeXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Aug 2011 13:22:03 +0800

> On Fri, Aug 19, 2011 at 1:08 PM, David Miller <davem@davemloft.net> wrote:
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Fri, 19 Aug 2011 13:05:53 +0800
>>
>>> For the 802.1Q packets, if the NIC doesn't support hw-accel-vlan-rx, RPS
>>> won't inspect the internal 4 tuples to generate skb->rxhash, so this kind
>>> of traffic can't get any benefit from RPS.
>>>
>>> This patch adds the support for 802.1Q to RPS.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>
>> Looks fine, applied to net-next, thanks!
>>
> 
> Thanks for applying it. I have another patch which adds the support
> for PPPOE session messages. Do you think it worth doing?

Sure.
