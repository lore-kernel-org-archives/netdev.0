From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHES] Networking fixes for -stable.
Date: Wed, 14 Nov 2012 22:31:45 -0500 (EST)
Message-ID: <20121114.223145.1718907430767854932.davem@davemloft.net>
References: <20121112.002558.46179003870204789.davem@davemloft.net>
	<1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, peter.senna@gmail.com,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992461Ab2KODbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:31:47 -0500
In-Reply-To: <1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 13 Nov 2012 19:51:26 +0000

> On Mon, 2012-11-12 at 00:25 -0500, David Miller wrote:
>> Please queue up the following networking bug fixes for
>> 3.0.x, 3.2.x, 3.4.x, and 3.6.x, respectively.
> [...]
>> From 2204849a85383fbde75680aa199142abe504adbb Mon Sep 17 00:00:00 2001
>> From: Peter Senna Tschudin <peter.senna@gmail.com>
>> Date: Sun, 28 Oct 2012 06:12:01 +0000
>> Subject: [PATCH 7/9] drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister
>>  before mdiobus_free
>> 
>> [ Upstream commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e ]
>> 
>> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
>> 
>> Calling mdiobus_free without calling mdiobus_unregister causes
>> BUG_ON(). This patch fixes the issue.
> [...]
> 
> This introduces a regresssion, as mdiobus_unregister() is not safe to
> call if the bus isn't registered.  Registration is controlled by the
> drivers that use mdio-bitbang, and they should take care of
> unregistration too - and most of them do.
> 
> This should be reverted in mainline and not applied to any stable
> series.

Ok, I'll revert.

Greg, please toss it from your -stable queue as well.

Thanks!
