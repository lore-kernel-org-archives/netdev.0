From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 14:58:11 +1000
Message-ID: <20060531045811.GA6977@gondor.apana.org.au>
References: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56580 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751697AbWEaE6Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:58:25 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael:

On Tue, May 30, 2006 at 09:51:03PM -0700, Michael Chan wrote:
>
> > That's why I suggest that every NIC that uses this feature be forced
> > to do what TG3 does so only BH disabling is needed.  Once that's done
> > they can just use xmit_lock and everyone will be happy again.
> 
> As long as the tx completion is all done in NAPI, it can use BH
> disabling
> without irq disabling.

Yes, TG3 does not disable IRQs when taking its TX lock.  So do you see
any problems with replacing the TG3 TX lock using xmit_lock?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
