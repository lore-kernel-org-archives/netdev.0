From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm: Always zero high-order sequence number bits
Date: Thu, 21 May 2015 12:16:50 +0200
Message-ID: <20150521101650.GQ8928@secunet.com>
References: <20150513072610.GA27424@gondor.apana.org.au>
 <20150520163810.GA13992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58417 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755337AbbEUKQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:16:56 -0400
Content-Disposition: inline
In-Reply-To: <20150520163810.GA13992@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 12:38:12AM +0800, Herbert Xu wrote:
> As we're now always including the high bits of the sequence number
> in the IV generation process we need to ensure that they don't
> contain crap.
> 
> This patch ensures that the high sequence bits are always zeroed
> so that we don't leak random data into the IV.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert!
