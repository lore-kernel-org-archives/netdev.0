From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: esp4: Use high-order sequence number bits for IV generation
Date: Wed, 13 May 2015 12:18:35 +0200
Message-ID: <20150513101834.GA8928@secunet.com>
References: <20150513072610.GA27424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40192 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240AbbEMKSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 06:18:41 -0400
Content-Disposition: inline
In-Reply-To: <20150513072610.GA27424@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 03:26:10PM +0800, Herbert Xu wrote:
> I noticed we were only using the low-order bits for IV generation
> when ESN is enabled.  This is very bad because it means that the
> IV can repeat.  We must use the full 64 bits.

Ugh. This is bad, indeed.

> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Patch applied to the ipsec tree, thanks!
