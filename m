From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Tue, 08 May 2012 02:26:47 -0400 (EDT)
Message-ID: <20120508.022647.1186809783650560801.davem@davemloft.net>
References: <1336399961.4325.30.camel@jlt3.sipsolutions.net>
	<20120507.192052.181899101154654170.davem@davemloft.net>
	<1336454744.4328.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab2EHG1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 02:27:54 -0400
In-Reply-To: <1336454744.4328.2.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 08 May 2012 07:25:44 +0200

> I suppose I could fix those first and then later change the type, but I
> think having a "compare_ether_addr" function that returns *false* when
> they *match* would be rather confusing. I'd rather have
> "equal_ether_addr()" that returns *true* when they match.
> 
> I guess we could introduce equal_ether_addr() though and slowly convert,
> keeping compare_ether_addr() as a sort of wrapper around it.

Indeed, this is one way to proceed.
