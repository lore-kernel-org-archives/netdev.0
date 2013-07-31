From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_orphan() changes
Date: Wed, 31 Jul 2013 16:44:30 -0700 (PDT)
Message-ID: <20130731.164430.2259553453745469164.davem@davemloft.net>
References: <1375225875.10515.36.camel@edumazet-glaptop>
	<20130731.152458.92056892741307118.davem@davemloft.net>
	<1375310691.10515.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab3GaXoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:44:30 -0400
In-Reply-To: <1375310691.10515.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Jul 2013 15:44:51 -0700

> On Wed, 2013-07-31 at 15:24 -0700, David Miller wrote:
> 
>> Applied, but personally I would have considered adding an
>> else clause checking BUG_ON(skb->sk), or are you not so
>> confident in your assertion? :-)
> 
> I considered this but this was adding a significant overhead, as this
> is an inline function.
> 
> What about doing that for a limited time, say until 3.12 is released ?

That sounds like a great idea.
