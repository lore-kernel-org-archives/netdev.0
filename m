From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: net: rps: support 802.1Q
Date: Fri, 19 Aug 2011 13:22:03 +0800
Message-ID: <CABa6K_EG7ccoKk4YDFc4us269pA7BRaFhb_1XhoedR1cJ+GeXQ@mail.gmail.com>
References: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com> <20110818.220805.1212231373721016529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52447 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab1HSFWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:22:25 -0400
Received: by eyx24 with SMTP id 24so1606881eyx.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 22:22:24 -0700 (PDT)
In-Reply-To: <20110818.220805.1212231373721016529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 1:08 PM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 19 Aug 2011 13:05:53 +0800
>
>> For the 802.1Q packets, if the NIC doesn't support hw-accel-vlan-rx, RPS
>> won't inspect the internal 4 tuples to generate skb->rxhash, so this kind
>> of traffic can't get any benefit from RPS.
>>
>> This patch adds the support for 802.1Q to RPS.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Looks fine, applied to net-next, thanks!
>

Thanks for applying it. I have another patch which adds the support
for PPPOE session messages. Do you think it worth doing?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
