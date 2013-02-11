From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] skbuff: create skb_panic() to let caller
 specify panic
Date: Mon, 11 Feb 2013 13:52:27 -0500 (EST)
Message-ID: <20130211.135227.648991997734970671.davem@davemloft.net>
References: <1360484610-11432-1-git-send-email-sakiwit@gmail.com>
	<20130210182451.GA1602@minipsycho.orion>
	<20130210234651.GD2496@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759586Ab3BKSwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 13:52:30 -0500
In-Reply-To: <20130210234651.GD2496@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sun, 10 Feb 2013 16:46:52 -0700

> From: Jiri Pirko <jiri@resnulli.us>
> Date: Sun, 10 Feb 2013 19:24:51 +0100
>>
>> How about to leave skb_under_panic() and skb_over_panic() wrapping
>> functions there just to wrap "skb_panic(skb, sz, addr, __func__);" call?
>> 
>> Seems nice that to state the name in str...
> 
> That's really a good idea. If David drops again, I'll implement it.

I like Jiri's idea, please implement it.
