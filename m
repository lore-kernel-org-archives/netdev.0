From: David Miller <davem@davemloft.net>
Subject: Re: Increasing skb->mark size
Date: Mon, 30 Nov 2015 22:55:51 -0500 (EST)
Message-ID: <20151130.225551.1151915829635053889.davem@davemloft.net>
References: <565BCC42.7020701@alliedtelesis.co.nz>
	<20151129.234955.2156041834628417171.davem@davemloft.net>
	<565CE5E8.9010002@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, Matt.Bennett@alliedtelesis.co.nz,
	netdev@vger.kernel.org
To: Luuk.Paulussen@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbLADzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 22:55:53 -0500
In-Reply-To: <565CE5E8.9010002@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Date: Tue, 1 Dec 2015 00:12:24 +0000

> On 11/30/2015 05:49 PM, David Miller wrote:
>> From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
>> Date: Mon, 30 Nov 2015 04:10:43 +0000
>>
>>> On 11/30/2015 02:58 PM, David Miller wrote:
>>>> If you guys, really anyone, can find a way to remove some other 32-bit
>>>> item from sk_buff, you can expand skb->mark to 64-bits. But otherwise,
>>>> I'm going to be strongly against it. sk_buff is already enormous and
>>>> larger than it should be. So I'm going to resist any change that makes
>>>> it even larger. Thanks.
>>> Would the level of objection be the same if this was done as an
>>> "extended mark" field under a configurable off-by-default option?
>> Every distribtion will turn the option on.
>>
>> Config options hiding "cost" is never an argument to bloat
>> a critical core datstructure up, sorry.
>>
> Fair enough, although if most distributions would turn it on, it does 
> suggest that it is interesting...

Lots of things are interesting and useful to many people.

Even the most useful feature I would balk at it's implementation
if it bloated up sk_buff.  Period.

You don't understand what the core issue is, which is sk_buff size
which has an effect on all users.
