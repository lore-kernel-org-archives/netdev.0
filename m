From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: fix wild pointer
Date: Fri, 30 Jul 2010 15:18:38 +0800
Message-ID: <20100730071838.GA7256@gondor.apana.org.au>
References: <1280446906-29032-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49082 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab0G3HSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 03:18:47 -0400
Content-Disposition: inline
In-Reply-To: <1280446906-29032-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 30, 2010 at 07:41:46AM +0800, Changli Gao wrote:
> pskb_may_pull() may change skb pointers, so adjust icmph after pskb_may_pull().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
