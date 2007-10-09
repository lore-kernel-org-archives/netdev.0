From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [IPSEC] ah: Remove keys from ah_data structure
Date: Mon, 08 Oct 2007 17:14:58 -0700 (PDT)
Message-ID: <20071008.171458.69084453.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnq-0000o3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42762
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbXJIAO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:14:59 -0400
In-Reply-To: <E1Ieqnq-0000o3-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:38 +0800

> [IPSEC] ah: Remove keys from ah_data structure
> 
> The keys are only used during initialisation so we don't need to carry them
> in esp_data.  Since we don't have to allocate them again, there is no need
> to place a limit on the authentication key length anymore.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

And if I liked the ESP side, how can I not like this patch :-)

Also applied, thanks Herbert!
