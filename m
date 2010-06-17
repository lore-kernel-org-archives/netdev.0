From: David Miller <davem@davemloft.net>
Subject: Re: udp: Add UFO to NETIF_F_SOFTWARE_GSO
Date: Wed, 16 Jun 2010 18:08:12 -0700 (PDT)
Message-ID: <20100616.180812.212689313.davem@davemloft.net>
References: <20100615062104.GA4779@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755009Ab0FQBIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 21:08:01 -0400
In-Reply-To: <20100615062104.GA4779@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 15 Jun 2010 16:21:04 +1000

> udp: Add UFO to NETIF_F_SOFTWARE_GSO
> 
> This patch adds UFO to the list of GSO features with a software
> fallback.  This allows UFO to be used even if the hardware does
> not support it.
> 
> In particular, this allows us to test the UFO fallback, as it
> has been reported to not work in some cases.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks.
