From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of	netif_rx()
Date: Thu, 03 Apr 2008 18:19:41 +0200
Message-ID: <47F5039D.1070007@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com> <20080331094823.GA11651@elte.hu> <47F0B66C.6080404@cosmosbay.com> <20080331101237.GA12324@elte.hu> <47F1FE0A.9090501@cosmosbay.com> <20080403140600.GA4507@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.97]:22148 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589AbYDCQTy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 12:19:54 -0400
In-Reply-To: <20080403140600.GA4507@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek a =E9crit :
> Hi!
>
>  =20
>>> the rule on x86 should be something like this: on 4K=20
>>> stacks and 64-bit [which have irqstacks] free stack=20
>>> space can go as low as 25%. On 8K stacks [which doesnt=20
>>>      =20
> ...
>  =20
>>   32 bits and 4K stacks (separate irq stacks) : can use=20
>>   up to 25% of stack
>>    =20
>
> I think ingo meant 'up to 75% used'.
>
>
>  =20
Patch is OK, my english might be a litle bit unsual :)




