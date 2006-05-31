From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 15:33:38 +1000
Message-ID: <20060531053338.GA7334@gondor.apana.org.au>
References: <1551EAE59135BE47B544934E30FC4FC041BC92@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:31237 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751710AbWEaFdv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 01:33:51 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BC92@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 10:30:25PM -0700, Michael Chan wrote:
> 
> I also don't see any problem. It looks like we don't have to set
> xmit_lock_owner, right?

Right, unless you want to call dev_queue_xmit recursively :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
