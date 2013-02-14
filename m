From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert skb->csum_(start|offset) integrity
 BUG_ON() to WARN_ON() & drop
Date: Thu, 14 Feb 2013 13:00:11 -0500 (EST)
Message-ID: <20130214.130011.1650629621355208039.davem@davemloft.net>
References: <20130213234843.GB21829@casper.infradead.org>
	<20130213.193759.1094469499685059296.davem@davemloft.net>
	<20130214101853.GC21829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758307Ab3BNSAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:00:14 -0500
In-Reply-To: <20130214101853.GC21829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 14 Feb 2013 10:18:53 +0000

> On 02/13/13 at 07:37pm, David Miller wrote:
> Maybe it's my general dislike of BUG_ON() in the processing
> path, especially if the bug condition can be influenced remotely.
> It looks absolutely doable to trigger the previously mentioned
> partial acking & collapsing on purpose by a malicious receiver
> even with an MTU of 1500. I believe we should avoid total DoS
> in future similar situations that we don't think of yet.

I heard that people can very effectively protect themselves from DoS's
by not using Infiniband. :-)
