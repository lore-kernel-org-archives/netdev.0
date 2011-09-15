From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/14] skb fragment API: convert network drivers (part
 II)
Date: Thu, 15 Sep 2011 15:41:47 -0400 (EDT)
Message-ID: <20110915.154147.1373009952462410742.davem@davemloft.net>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934532Ab1IOTlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:41:52 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 31 Aug 2011 11:46:48 +0100

> The following series converts the second batch of network drivers to the
> SKB pages fragment API introduced in 131ea6675c76. I expect there will
> be ~4 similarly sized batches to convert all the drivers over.
> 
> This is part of my series to enable visibility into SKB paged fragment's
> lifecycles, [0] contains some more background and rationale but
> basically the completed series will allow entities which inject pages
> into the networking stack to receive a notification when the stack has
> really finished with those pages (i.e. including retransmissions,
> clones, pull-ups etc) and not just when the original skb is finished
> with, which is beneficial to many subsystems which wish to inject pages
> into the network stack without giving up full ownership of those page's
> lifecycle. It implements something broadly along the lines of what was
> described in [1].

Series applied, thanks.
