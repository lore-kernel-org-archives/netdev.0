From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Fri, 04 May 2012 02:54:33 -0400 (EDT)
Message-ID: <20120504.025433.1474691040952890731.davem@davemloft.net>
References: <20120503154142.GB27671@redhat.com>
	<20120503.135532.1038384417514973419.davem@davemloft.net>
	<20120503210826.GA30504@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab2EDGyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 02:54:40 -0400
In-Reply-To: <20120503210826.GA30504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 4 May 2012 00:10:24 +0300

> Hmm we orphan skbs when we loop them back so how about reusing the
> skb->destructor for this?

That's one possibility.

But I fear we're about to toss Ian into yet another rabbit hole. :-)

Let's try to converge on something quickly as I think integration of
his work has been delayed enough as-is.
