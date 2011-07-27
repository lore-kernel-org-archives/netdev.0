From: David Miller <davem@davemloft.net>
Subject: Re: gro: Only reset frag0 when skb can be pulled
Date: Wed, 27 Jul 2011 06:17:19 -0700 (PDT)
Message-ID: <20110727.061719.1278203020782685803.davem@davemloft.net>
References: <20110727131008.GA28825@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab1G0NRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 09:17:23 -0400
In-Reply-To: <20110727131008.GA28825@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 27 Jul 2011 21:10:08 +0800

> gro: Only reset frag0 when skb can be pulled
> 
> Currently skb_gro_header_slow unconditionally resets frag0 and
> frag0_len.  However, when we can't pull on the skb this leaves
> the GRO fields in an inconsistent state.
> 
> This patch fixes this by only resetting those fields after the
> pskb_may_pull test.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.

I'll queue this up for -stable too.
