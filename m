From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Fri, 24 Feb 2012 04:13:58 -0500 (EST)
Message-ID: <20120224.041358.1660069480800524360.davem@davemloft.net>
References: <20120221081827.GF31660@secunet.com>
	<20120221.142455.1647947327897905941.davem@davemloft.net>
	<20120224090837.GA15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756352Ab2BXJPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 04:15:16 -0500
In-Reply-To: <20120224090837.GA15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 24 Feb 2012 10:08:38 +0100

> Actually the whole tree is invalid in such cases. So instead of
> replacing each single entry of the tree, we could just replace
> the old tree with a fresh initialized inet_peer_base. The old
> tree could be removed later with a delayed work queue.
> 
> When rt_cache_invalidate() is invoked, all we have to do is to
> replace the root node with a peer_fake_node and to add the old root
> node to a garbage collecting list. The old tree will be destroyed
> with a work queue later.
> 
> We would not even need a genid and we could also get rid of the
> redirect_genid handling.

It sounds like a great idea.
