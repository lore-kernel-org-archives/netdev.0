From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 14:31:53 -0700 (PDT)
Message-ID: <20110621.143153.1051393424299525425.davem@davemloft.net>
References: <4E0074CF.8070003@inliniac.net>
	<20110621.034627.30677905865798284.davem@davemloft.net>
	<BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab1FUVcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 17:32:04 -0400
In-Reply-To: <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 21 Jun 2011 21:05:24 +0800

> On Tue, Jun 21, 2011 at 6:46 PM, David Miller <davem@davemloft.net> wrote:
>> From: Victor Julien <victor@inliniac.net>
>> Date: Tue, 21 Jun 2011 12:39:11 +0200
>>
>>> The hash based on skb->rxhash, does that result in a "flow" based
>>> distribution over the listeners? So all packets sharing a tuple
>>> being sent to the same socket?
>>
>> Yes, that's exactly right.
> 
> But not for fragments, in additional.

That's a fundamental issue in the RFS code which I've proposed
solutions for.
