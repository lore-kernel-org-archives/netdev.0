From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: reset skb->peeked when reuse orphan skb for
 next broadcast
Date: Mon, 13 Jul 2015 16:05:49 +0800
Message-ID: <20150713080549.GA8971@gondor.apana.org.au>
References: <20150710122134.21653.46736.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38627 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbGMIFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:05:52 -0400
Content-Disposition: inline
In-Reply-To: <20150710122134.21653.46736.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 03:21:34PM +0300, Konstantin Khlebnikov wrote:
> This patch clears skb->peeked set by previous recipient of broadcast.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: add05ad4e9f5 ("unix/dgram: peek beyond 0-sized skbs")

Per my earlier email, this patch is not needed if we fix the root
cause.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
