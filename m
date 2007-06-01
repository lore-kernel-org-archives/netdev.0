From: David Miller <davem@davemloft.net>
Subject: Re: [NET] gso: Fix GSO feature mask in sk_setup_caps
Date: Thu, 31 May 2007 22:16:22 -0700 (PDT)
Message-ID: <20070531.221622.62660702.davem@davemloft.net>
References: <20070601051349.GA13244@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753357AbXFAFQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 01:16:09 -0400
In-Reply-To: <20070601051349.GA13244@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 1 Jun 2007 15:13:49 +1000

> [NET] gso: Fix GSO feature mask in sk_setup_caps
> 
> This isn't a bug just yet as only TCP uses sk_setup_caps for GSO.
> However, if and when UDP or something else starts using it this is
> likely to cause a problem if we forget to add software emulation
> for it at the same time.
> 
> The problem is that right now we translate GSO emulation to the
> bitmask NETIF_F_GSO_MASK, which includes every protocol, even
> ones that we cannot emulate.
> 
> This patch makes it provide only the ones that we can emulate.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch, applied, thanks Herbert.

I don't think it's worth bothering -stable with this one,
agreed?
