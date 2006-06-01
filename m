From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Thu, 1 Jun 2006 10:42:35 +1000
Message-ID: <20060601004235.GA19459@gondor.apana.org.au>
References: <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net> <1149110429.3078.5.camel@rh4> <20060531.170908.46214247.davem@davemloft.net> <20060601002525.GA19220@gondor.apana.org.au> <1149116466.4022.5.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22035 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965098AbWFAAmy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 20:42:54 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1149116466.4022.5.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 04:01:06PM -0700, Michael Chan wrote:
> 
> Oh, I thought your idea was to keep the LLTX and just replace tx_lock
> with xmit_lock in tg3. But I suppose we can also clear LLTX, remove the
> tx_lock in hard_start_xmit and convert the rest to avoid changing
> netpoll.

That's what I meant.  This has the advantage that things like AF_PACKET
won't see duplicate packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
