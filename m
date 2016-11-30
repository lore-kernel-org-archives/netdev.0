From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] esp4: Fix integrity verification when ESN are
 used
Date: Wed, 30 Nov 2016 13:17:01 +0100
Message-ID: <20161130121701.GW3541@gauss.secunet.com>
References: <091e32fb-ad85-4dc8-2864-f2b97141f097@strongswan.org>
 <20161130095827.GA3138@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tobias Brunner <tobias@strongswan.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48256 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbcK3MRF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 07:17:05 -0500
Content-Disposition: inline
In-Reply-To: <20161130095827.GA3138@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 05:58:27PM +0800, Herbert Xu wrote:
> On Tue, Nov 29, 2016 at 05:05:20PM +0100, Tobias Brunner wrote:
> > When handling inbound packets, the two halves of the sequence number
> > stored on the skb are already in network order.
> > 
> > Fixes: 7021b2e1cddd ("esp4: Switch to new AEAD interface")
> > Signed-off-by: Tobias Brunner <tobias@strongswan.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to the ipsec tree, thanks!
