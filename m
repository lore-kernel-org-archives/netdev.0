From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Wed, 13 Aug 2008 11:21:29 +1000
Message-ID: <20080813012129.GA29996@gondor.apana.org.au>
References: <20080812233753.GA29155@gondor.apana.org.au> <20080812.175532.137434164.davem@davemloft.net> <20080813010935.GA29815@gondor.apana.org.au> <20080812.181731.249504809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41860 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753666AbYHMBVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:21:41 -0400
Content-Disposition: inline
In-Reply-To: <20080812.181731.249504809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 06:17:31PM -0700, David Miller wrote:
>
> It seems pointless for us to add features like mmap() support and
> auxdata if the most important client library and tool users of these
> features never take it up.

Well auxdata at least is used by dhcp-common and therefore dhcp-client
and dhcp-server.

> libpcap and tcpdump have been notoriously difficult in this area.

Yes the disconnect between the kernel community and the rest is
large.  The only successful examples seems to be where the user-
space code is maintained by a kernel developer, e.g., iproute.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
