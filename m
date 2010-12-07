From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix xfrm_state_migrate leak
Date: Tue, 7 Dec 2010 17:31:57 +0800
Message-ID: <20101207093157.GA4845@gondor.apana.org.au>
References: <20101207092856.GL4639@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Thomas Egerer <thomas.egerer@secunet.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60105 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036Ab0LGJcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 04:32:04 -0500
Content-Disposition: inline
In-Reply-To: <20101207092856.GL4639@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 07, 2010 at 10:28:56AM +0100, Steffen Klassert wrote:
> From: Thomas Egerer <thomas.egerer@secunet.com>
> 
> xfrm_state_migrate calls kfree instead of xfrm_state_put to free
> a failed state. According to git commit 553f9118 this can cause
> memory leaks.
> 
> Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch.  Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
