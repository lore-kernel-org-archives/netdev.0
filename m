From: Brice Goglin <brice@myri.com>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 14:29:07 +0200
Message-ID: <48D39B13.60401@myri.com>
References: <20080918.193815.175549834.davem@davemloft.net> <1221824281.3103.8.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1889 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750876AbYISM2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 08:28:07 -0400
In-Reply-To: <1221824281.3103.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Thu, 2008-09-18 at 19:38 -0700, David Miller wrote:
> [...]
>   
>> So on a multiqueue card with 2 RX queues and 2 TX queues we'd
>> have names like:
>>
>> 	eth0-rx-0
>> 	eth0-rx-1
>> 	eth0-tx-0
>> 	eth0-tx-1
>>
>> So let's make an effort to get this done right in 2.6.28 and meanwhile
>> Arjan can add the irqbalanced code.
>>     
>
> What about the case where an interrupt is shared between RX and TX
> completions?  Our hardware is very flexible in this regard, but based on
> performance testing prior to the introduction of TX multiqueue we
> currently allocate multiple interrupts for RX completions and share the
> first with TX completions.
>   

myri10ge uses the same interrupts for TX and RX. The current name is
eth%d:slice-%d but we could change it if there's a consensus.

Brice

