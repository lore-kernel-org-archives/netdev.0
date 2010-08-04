From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: fix on the TX path
Date: Wed, 4 Aug 2010 15:06:21 +0800
Message-ID: <20100804070621.GB370@gondor.apana.org.au>
References: <1280893158-22103-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59688 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758259Ab0HDHGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:06:31 -0400
Content-Disposition: inline
In-Reply-To: <1280893158-22103-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 11:39:18AM +0800, Changli Gao wrote:
> On the TX path, skb->data points to the ethernet header, not the network
> header. So when validating the packet length for accessing we should
> take the ethernet header into account.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for cathing this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
