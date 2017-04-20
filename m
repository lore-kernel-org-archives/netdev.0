From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 11/16] esp: Use a synchronous crypto algorithm on
 offloading.
Date: Thu, 20 Apr 2017 17:06:17 +0800
Message-ID: <20170420090617.GA8325@gondor.apana.org.au>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:32808 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S943925AbdDTJHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 05:07:03 -0400
Content-Disposition: inline
In-Reply-To: <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 10:55:10AM +0200, Steffen Klassert wrote:
> We need a fallback algorithm for crypto offloading to a NIC.
> This is because packets can be rerouted to other NICs that
> don't support crypto offloading. The fallback is going to be
> implemented at layer2 where we know the final output device
> but can't handle asynchronous returns fron the crypto layer.

Can you explain why we can't handle async algorithms on the fallback
path?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
