From: David Miller <davem@davemloft.net>
Subject: Re: Increasing skb->mark size
Date: Sun, 29 Nov 2015 23:49:55 -0500 (EST)
Message-ID: <20151129.234955.2156041834628417171.davem@davemloft.net>
References: <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
	<20151129.205854.160622377475841200.davem@davemloft.net>
	<565BCC42.7020701@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, Matt.Bennett@alliedtelesis.co.nz,
	netdev@vger.kernel.org
To: Luuk.Paulussen@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbK3Et7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 23:49:59 -0500
In-Reply-To: <565BCC42.7020701@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Date: Mon, 30 Nov 2015 04:10:43 +0000

> On 11/30/2015 02:58 PM, David Miller wrote:
>> If you guys, really anyone, can find a way to remove some other 32-bit 
>> item from sk_buff, you can expand skb->mark to 64-bits. But otherwise, 
>> I'm going to be strongly against it. sk_buff is already enormous and 
>> larger than it should be. So I'm going to resist any change that makes 
>> it even larger. Thanks. 
> Would the level of objection be the same if this was done as an 
> "extended mark" field under a configurable off-by-default option?

Every distribtion will turn the option on.

Config options hiding "cost" is never an argument to bloat
a critical core datstructure up, sorry.
