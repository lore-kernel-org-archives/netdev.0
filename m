From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sun, 24 Jan 2010 14:36:23 +1300
Message-ID: <20100124013623.GA12335@gondor.apana.org.au>
References: <1264260580.373.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anders@netinsight.net, Jie.Yang@atheros.com,
	netdev@vger.kernel.org, 565404@bugs.debian.org,
	Xiong.Huang@atheros.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47103 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752523Ab0AXBgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 20:36:41 -0500
Content-Disposition: inline
In-Reply-To: <1264260580.373.77.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> wrote:
> 
> Based on the TCP sequence numbers, it seems that the length of the
> broken packet is correct but its IP header is wrong.
> 
> My understanding is that the length of the TCP payload in a GSO skb must
> always be a multiple of the gso_size, so that hardware is not required
> to adjust length fields.  So I see several possible explanations:

No, there is no such requirement.  The trailer skb can be of any
size less than or equal to gso_size.

However, if the hardware assumed this then yes it would explain
the problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
