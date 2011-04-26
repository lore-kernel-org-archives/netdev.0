From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6 1/4] xfrm: Fix replay window size calculation
	on initialization
Date: Tue, 26 Apr 2011 15:41:07 +1000
Message-ID: <20110426054107.GB18896@gondor.apana.org.au>
References: <20110426053923.GF5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43248 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab1DZFlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 01:41:14 -0400
Content-Disposition: inline
In-Reply-To: <20110426053923.GF5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 07:39:24AM +0200, Steffen Klassert wrote:
> On replay initialization, we compute the size of the replay
> buffer to see if the replay window fits into the buffer.
> This computation lacks a mutliplication by 8 because we need
> the size in bit, not in byte. So we might return an error
> even though the replay window would fit into the buffer.
> This patch fixes this issue.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
