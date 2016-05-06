From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sfc: Support setting rss_cpus to 'cores',
 'packages' or 'hyperthreads'
Date: Fri, 06 May 2016 15:38:29 -0400 (EDT)
Message-ID: <20160506.153829.1292994792261109577.davem@davemloft.net>
References: <572A29AF.1040607@solarflare.com>
	<572A2B00.7060301@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152AbcEFTib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:38:31 -0400
In-Reply-To: <572A2B00.7060301@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 4 May 2016 18:01:52 +0100

> These settings autoconfigure the number of RSS channels to match the number of
> CPUs present.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

I can't believe I allowed this 'rss_cpus' thing into the tree to begin with.

It's completely wrong and is exactly the kind of thing we are trying
to actively avoid in network drivers.

If another network driver wants to provide the same facility they will
add a module parameter with a slightly different name, a different
set of valid choices, and different semantics.

Define a proper global, stable, tree-wide mechanism to configure these
kinds of things and use that instead.

Thanks.
