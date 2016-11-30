From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 2/2] esp6: Fix integrity verification when ESN are
 used
Date: Wed, 30 Nov 2016 13:17:39 +0100
Message-ID: <20161130121738.GX3541@gauss.secunet.com>
References: <f3c5eaa5-d1a3-cc7a-1bd8-20fa2c961770@strongswan.org>
 <20161130095837.GB3138@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tobias Brunner <tobias@strongswan.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48306 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbcK3MRr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 07:17:47 -0500
Content-Disposition: inline
In-Reply-To: <20161130095837.GB3138@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 05:58:38PM +0800, Herbert Xu wrote:
> On Tue, Nov 29, 2016 at 05:05:25PM +0100, Tobias Brunner wrote:
> > When handling inbound packets, the two halves of the sequence number
> > stored on the skb are already in network order.
> > 
> > Fixes: 000ae7b2690e ("esp6: Switch to new AEAD interface")
> > Signed-off-by: Tobias Brunner <tobias@strongswan.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied to the ipsec tree, thanks a lot everyone!
