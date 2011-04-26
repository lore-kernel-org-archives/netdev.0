From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6 2/4] esp6: Fix scatterlist initialization
Date: Tue, 26 Apr 2011 15:41:58 +1000
Message-ID: <20110426054158.GC18896@gondor.apana.org.au>
References: <20110426053923.GF5495@secunet.com> <20110426054023.GG5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57215 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab1DZFmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 01:42:22 -0400
Content-Disposition: inline
In-Reply-To: <20110426054023.GG5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 07:40:23AM +0200, Steffen Klassert wrote:
> When we use IPsec extended sequence numbers, we may overwrite
> the last scatterlist of the associated data by the scatterlist
> for the skb. This patch fixes this by placing the scatterlist
> for the skb right behind the last scatterlist of the associated
> data. esp4 does it already like that.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
