From: David Miller <davem@davemloft.net>
Subject: Re: udp_diag: Fix socket skipping within chain
Date: Tue, 27 Jan 2015 00:03:11 -0800 (PST)
Message-ID: <20150127.000311.103045565357925532.davem@davemloft.net>
References: <20150123210240.GA1569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756989AbbA0IDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:03:12 -0500
In-Reply-To: <20150123210240.GA1569@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 24 Jan 2015 08:02:40 +1100

> While working on rhashtable walking I noticed that the UDP diag
> dumping code is buggy.  In particular, the socket skipping within
> a chain never happens, even though we record the number of sockets
> that should be skipped.
> 
> As this code was supposedly copied from TCP, this patch does what
> TCP does and resets num before we walk a chain.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
