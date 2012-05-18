From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix module unload for good
Date: Fri, 18 May 2012 13:55:22 -0400 (EDT)
Message-ID: <20120518.135522.1346891514958043726.davem@davemloft.net>
References: <1337334746.3403.114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965082Ab2ERRzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:55:25 -0400
In-Reply-To: <1337334746.3403.114.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 11:52:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit c57b5468406 (pktgen: fix crash at module unload) did a very poor
> job with list primitives.
> 
> 1) list_splice() arguments were in the wrong order 
> 
> 2) list_splice(list, head) has undefined behavior if head is not
> initialized.
> 
> 3) We should use the list_splice_init() variant to clear pktgen_threads
> list.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
