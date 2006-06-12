From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are never delivered
Date: Mon, 12 Jun 2006 16:18:09 +1000
Message-ID: <E1FpfkX-0000EL-00@gondolin.me.apana.org.au>
References: <20060611.212913.70218067.davem@davemloft.net>
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org, kaber@coreworks.de,
	jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57361 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750957AbWFLGTR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 02:19:17 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060611.212913.70218067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Probably a better way to handle this is to correct the
> INDATAGRAMS value by decrementing it when we notice that
> the checksum is incorrect in a deferred manner.

I think sunrpc should instead increment the appropriate counters directly
as otherwise checksum errors won't be recorded correctly for sunrpc packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
