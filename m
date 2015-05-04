From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Remove max_size setting
Date: Sun, 03 May 2015 23:27:21 -0400 (EDT)
Message-ID: <20150503.232721.113045176775125145.davem@davemloft.net>
References: <20150501002759.GA31660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbEDD1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:27:23 -0400
In-Reply-To: <20150501002759.GA31660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 1 May 2015 08:27:59 +0800

> We currently limit the hash table size to 64K which is very bad
> as even 10 years ago it was relatively easy to generate millions
> of sockets.
> 
> Since the hash table is naturally limited by memory allocation
> failure, we don't really need an explicit limit so this patch
> removes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
