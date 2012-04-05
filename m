From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Do not send queries on multicast group leaves
Date: Wed, 04 Apr 2012 21:17:39 -0400 (EDT)
Message-ID: <20120404.211739.2070899876354223753.davem@davemloft.net>
References: <20120404110119.GA11576@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab2DEBRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 21:17:45 -0400
In-Reply-To: <20120404110119.GA11576@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 4 Apr 2012 19:01:20 +0800

> bridge: Do not send queries on multicast group leaves
> 
> As it stands the bridge IGMP snooping system will respond to
> group leave messages with queries for remaining membership.
> This is both unnecessary and undesirable.  First of all any
> multicast routers present should be doing this rather than us.
> What's more the queries that we send may end up upsetting other
> multicast snooping swithces in the system that are buggy.
> 
> In fact, we can simply remove the code that send these queries
> because the existing membership expiry mechanism doesn't rely
> on them anyway.
> 
> So this patch simply removes all code associated with group
> queries in response to group leave messages.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
