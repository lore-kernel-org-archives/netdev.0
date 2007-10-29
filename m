From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Mon, 29 Oct 2007 20:53:28 +0800
Message-ID: <20071029125328.GA5453@gondor.apana.org.au>
References: <20070306012010.GA25763@gondor.apana.org.au> <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1107 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752383AbXJ2Myq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 08:54:46 -0400
Content-Disposition: inline
In-Reply-To: <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 03:33:20PM +0900, Mitsuru Chinen wrote:
> Hello Herbert,
> 
> Let me ask a question about this patch.
> After this patch was applied, 2 of the protocol stack behaviors were
> changed when it receives a UDP datagram with broken checksum:
> 
>  1. udp6InDatagrams is incremented instead of udpInErrors
>  2. In userland, recvfrom() replies an error with EAGAIN.
>     recvfrom() wasn't aware of such a packet before.
> 
> Are these changes intentional?

It wasn't my intention if that's what you mean :)

However, this would've happened with the old code anyway if
someone had a filter attached so this isn't new.

If it's a problem then we should just get it fixed.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
