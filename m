From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br2684: don't send frames on not-ready vcc
Date: Wed, 28 Nov 2012 12:04:15 -0500 (EST)
Message-ID: <20121128.120415.778262714601372592.davem@davemloft.net>
References: <1354058916.2534.25.camel@shinybook.infradead.org>
	<20121128.114153.737074131307295783.davem@davemloft.net>
	<1354122070.21562.89.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab2K1RER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:04:17 -0500
In-Reply-To: <1354122070.21562.89.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 28 Nov 2012 17:01:10 +0000

> On Wed, 2012-11-28 at 11:41 -0500, David Miller wrote:
>> 
>> Please:
>> 
>>         if (X ||
>>             Y ||
>>             Z)
>> 
>> not:
>> 
>>         if (X
>>             || Y
>>             || Z)
> 
> Thanks. Fixed in both Krzysztof's original pppoatm version, and my
> br2684 patch, in the git tree at git://git.infradead.org/~dwmw2/atm.git
> 
> I knew there was something else that offended me about the original,
> other than just the whitespace (which is also fixed).

Do you want me to pull that tree into net-next or is there a plan to
repost the entire series of work for a final submission?
