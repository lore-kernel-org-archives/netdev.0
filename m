From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 1/2] esp4: Fix integrity verification when ESN are
 used
Date: Wed, 30 Nov 2016 17:58:27 +0800
Message-ID: <20161130095827.GA3138@gondor.apana.org.au>
References: <091e32fb-ad85-4dc8-2864-f2b97141f097@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38624 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754970AbcK3J6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:58:48 -0500
Content-Disposition: inline
In-Reply-To: <091e32fb-ad85-4dc8-2864-f2b97141f097@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 05:05:20PM +0100, Tobias Brunner wrote:
> When handling inbound packets, the two halves of the sequence number
> stored on the skb are already in network order.
> 
> Fixes: 7021b2e1cddd ("esp4: Switch to new AEAD interface")
> Signed-off-by: Tobias Brunner <tobias@strongswan.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
