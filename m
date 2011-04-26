From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6 4/4] xfrm: Fix integer underrun on zero sized
	replay windows
Date: Tue, 26 Apr 2011 16:01:24 +1000
Message-ID: <20110426060124.GE18896@gondor.apana.org.au>
References: <20110426053923.GF5495@secunet.com> <20110426054232.GI5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36129 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab1DZGBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 02:01:48 -0400
Content-Disposition: inline
In-Reply-To: <20110426054232.GI5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 07:42:32AM +0200, Steffen Klassert wrote:
> The check if the replay window is contained within one subspace or
> spans over two subspaces causes an unwanted integer underrun on
> zero sized replay windows when we subtract minus one. We fix this by
> changeing this check to avoid the subtraction.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
