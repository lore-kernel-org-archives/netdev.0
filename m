From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Thu, 27 May 2010 20:24:29 +1000
Message-ID: <20100527102429.GA9017@gondor.apana.org.au>
References: <20100526102758.GA25914@gondor.apana.org.au> <20100526152019.GA11985@linux-mips.org> <20100526221601.GA3369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38284 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757821Ab0E0KYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 06:24:37 -0400
Content-Disposition: inline
In-Reply-To: <20100526221601.GA3369@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 08:16:01AM +1000, Herbert Xu wrote:
> 
> OK, it looks like my patch doesn't work because the transport
> header isn't set on the forwarding path.  Here's an updated patch:
> 
> ipv6: Add GSO support on forwarding path

Actually, this patch is still not quite right for the GSO case.
Right now it's only adding the IP header size, not the full header
size.

I need to think a bit more about this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
