From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: leaf_walk_rcu should not compute key if
 key is less than pn->key
Date: Tue, 27 Oct 2015 18:15:38 -0700 (PDT)
Message-ID: <20151027.181538.2065720176501734630.davem@davemloft.net>
References: <20151027220352.1312.18265.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brak@gameservers.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbJ1A66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:58:58 -0400
In-Reply-To: <20151027220352.1312.18265.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 27 Oct 2015 15:06:45 -0700

> We were computing the child index in cases where the key value we were
> looking for was actually less than the base key of the tnode.  As a result
> we were getting incorrect index values that would cause us to skip over
> some children.
> 
> To fix this I have added a test that will force us to use child index 0 if
> the key we are looking for is less than the key of the current tnode.
> 
> Fixes: 8be33e955cb9 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")
> Reported-by: Brian Rak <brak@gameservers.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied and queued up for -stable, thanks.
