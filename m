From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Tue, 01 Apr 2014 12:20:16 -0400 (EDT)
Message-ID: <20140401.122016.1850526829984133014.davem@davemloft.net>
References: <1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
	<20140328.171253.1863144825039621848.davem@davemloft.net>
	<BF3270C86E8B1349A26C34E4EC1C44CB2C8A255E@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbaDAQUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:20:18 -0400
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C8A255E@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Tue, 1 Apr 2014 15:19:48 +0000

>> > By grouping the key and hash together, with some reserved fields
>> > (which the setter should initially require to be equal to zero), it
>> > should be possible to fill in support for numbered RSS contexts later
>> > without yet another new structure and operations.
> 
> 
>> If that is the case, why don't we add from the start a "u32 rss_context;"
>> field that has to be set to zero for now?
> 
> The current structure has got three u32 reserved fields already. We could use one of them when the support is added.

Just do as I said, naming one of those to "rss_context" now, and require
that it be zero.
