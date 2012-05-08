From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Tue, 08 May 2012 03:31:20 -0400 (EDT)
Message-ID: <20120508.033120.1272130362698029549.davem@davemloft.net>
References: <1336454744.4328.2.camel@jlt3.sipsolutions.net>
	<20120508.022647.1186809783650560801.davem@davemloft.net>
	<1336458936.29640.2.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab2EHHcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 03:32:31 -0400
In-Reply-To: <1336458936.29640.2.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 07 May 2012 23:35:36 -0700

> On Tue, 2012-05-08 at 02:26 -0400, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Tue, 08 May 2012 07:25:44 +0200
>> 
>> > I suppose I could fix those first and then later change the type, but I
>> > think having a "compare_ether_addr" function that returns *false* when
>> > they *match* would be rather confusing. I'd rather have
>> > "equal_ether_addr()" that returns *true* when they match.
>> > 
>> > I guess we could introduce equal_ether_addr() though and slowly convert,
>> > keeping compare_ether_addr() as a sort of wrapper around it.
>> 
>> Indeed, this is one way to proceed.
> 
> perhaps is_equal_ether_addr or is_same_ether_addr instead?

Hmmm, my first choice would have been "eth_addr_equal()"
