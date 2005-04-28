From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Fri, 29 Apr 2005 07:26:41 +1000
Message-ID: <E1DRGWv-0003aa-00@gondolin.me.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: markb@wetlettuce.com (Mark Broadbent)
In-Reply-To: <E1DRFqC-00028H-Qi@tigger>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mark Broadbent <markb@wetlettuce.com> wrote:
> The interrupt handling code in the tulip network driver appears to use a non 
> IRQ safe spinlock in an interrupt context.  The following patch should correct 
> this.

This is bogus.  Interrupts are already disabled when you're in the
interrupt handler.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
