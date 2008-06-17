From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: fix fragmentation for ipv4 xfrm tunnel
Date: Tue, 17 Jun 2008 14:44:03 +1000
Message-ID: <20080617044403.GA8825@gondor.apana.org.au>
References: <20080616125946.GE9886@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35650 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751328AbYFQEoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 00:44:10 -0400
Content-Disposition: inline
In-Reply-To: <20080616125946.GE9886@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 02:59:46PM +0200, Steffen Klassert wrote:
> When generating the ip header for the transformed packet
> we just copy the frag_off field of the ip header from the original packet
> to the ip header of the new generated packet. If we receive a packet
> as a chain of fragments, all but the last of the new generated packets
> have the IP_MF flag set. We have to mask the frag_off field to only
> keep the IP_DF flag from the original packet. This got lost with git commit
> 
> 36cf9acf93e8561d9faec24849e57688a81eb9c5
> [IPSEC]: Separate inner/outer mode processing on output
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Good catch!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
