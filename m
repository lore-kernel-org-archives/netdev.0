From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr (fwd)
Date: Tue, 22 May 2007 07:28:04 +1000
Message-ID: <20070521212804.GB6234@gondor.apana.org.au>
References: <E1Hpdw3-0006CY-00@gondolin.me.apana.org.au> <4651CAA9.4050908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@greenkey.net,
	davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4699 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756790AbXEUV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:28:16 -0400
Content-Disposition: inline
In-Reply-To: <4651CAA9.4050908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 06:36:57PM +0200, Patrick McHardy wrote:
> 
> The IP stack shouldn't be too hard, we currently set skb->dev in
> ip_output, after that we only have the POST_ROUTING hook and ip_fragment
> which care. It wouldn't help with ipip/ip_gre though, at that point
> skb->dev must point to the tunnel device.

I think that should be OK though.  Once you pass through ipip/ip_gre's
transmit function, you're conceptually a locally generated packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
