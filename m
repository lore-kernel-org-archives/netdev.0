From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NET]: Get rid of alloc_skb code duplication
Date: Tue, 17 Apr 2007 14:03:47 +0100
Message-ID: <20070417130347.GA2632@infradead.org>
References: <20070417115746.GA20287@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48966 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbXDQNDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 09:03:52 -0400
Content-Disposition: inline
In-Reply-To: <20070417115746.GA20287@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 09:57:46PM +1000, Herbert Xu wrote:
> Hi Dave:
> 
> [NET]: Get rid of alloc_skb code duplication
> 
> The skb initialisation code is shared between alloc_skb and
> alloc_skb_from_cache.  Now I don't know what actually uses
> the latter so perhaps we could simply get rid of it.

It was put in for Xen, but if you as the resident beat the crap out
of Xen networking guru don't know about it we should probably just
kill it.  Especially as we usually kill dead code pretty fast.

