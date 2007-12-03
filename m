From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] SMC911X: Fix using of dereferenced skb after netif_rx
Date: Mon, 3 Dec 2007 21:11:41 +1100
Message-ID: <20071203101141.GA23549@gondor.apana.org.au>
References: <4753B74D.4070505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dustin McIntire <dustin@sensoria.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3995 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751494AbXLCKL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 05:11:59 -0500
Content-Disposition: inline
In-Reply-To: <4753B74D.4070505@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 03:59:09PM +0800, Wang Chen wrote:
> After netif_rx(), skb will be freed. So get the
> skb->len before netif_rx().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Please send driver patches to Jeff Garzik <jgarzik@pobox.com>.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
