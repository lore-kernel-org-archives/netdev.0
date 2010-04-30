From: David Miller <davem@davemloft.net>
Subject: Re: r8169 INFO: inconsistent lock state
Date: Fri, 30 Apr 2010 16:20:53 -0700 (PDT)
Message-ID: <20100430.162053.24603839.davem@davemloft.net>
References: <20100430182012.GA3329@swordfish.minsk.epam.com>
	<1272661149.2230.11.camel@edumazet-laptop>
	<20100430211556.GA4903@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sergey.senozhatsky@gmail.com,
	oleg@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755894Ab0D3XUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:20:47 -0400
In-Reply-To: <20100430211556.GA4903@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 30 Apr 2010 23:15:56 +0200

> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
>> So we have following illegal chain (process context, not softirq)
>> 
>> rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_receive_skb()
>> 
>> And normally, commit 630b943c tried to change this chain to :
>> 
>> rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_rx()
>> 
>> I have no idea why it doesnt work.
> 
> 630b943c appears to be in net-next.
> 
> Oops ?

I just tossed this into net-2.6, thanks for noticing.
