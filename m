From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.18 1/3] tg3: Remove unnecessary tx_lock
Date: Tue, 6 Jun 2006 20:17:01 +1000
Message-ID: <20060606101701.GA26751@gondor.apana.org.au>
References: <1551EAE59135BE47B544934E30FC4FC041BCBA@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59401 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751123AbWFFKRY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 06:17:24 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BCBA@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 10:10:56PM -0700, Michael Chan wrote:
>
> In places where we don't call tg3_netif_stop() before tg3_full_lock(),
> we are typically doing one of the following:
> 
> - changing tg3_flags or tg3_flags2
> - reprogramming MAC address
> - reprogramming interrupt coalescing values
> - reprogramming the PHY
> - setting the rx mode

OK, thanks for checking.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
