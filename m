From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] fib_trie: Only display main table in
 /proc/net/route
Date: Wed, 11 Mar 2015 21:22:28 -0400 (EDT)
Message-ID: <20150311.212228.1581184934531828534.davem@davemloft.net>
References: <20150311233536.1696.1657.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbCLBWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:22:30 -0400
In-Reply-To: <20150311233536.1696.1657.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 11 Mar 2015 16:36:08 -0700

> When we merged the tries for local and main I had overlooked the iterator
> for /proc/net/route.  As a result it was outputting both local and main
> when the two tries were merged.
> 
> This patch resolves that by only providing output for aliases that are
> actually in the main trie.  As a result we should go back to the original
> behavior which I assume will be necessary to maintain legacy support.
> 
> Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks Alex.

Please don't put empty lines between Fixes: tags and the signoffs
and acks, they belong together.
