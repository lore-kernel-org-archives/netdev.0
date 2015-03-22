From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 10:53:08 +1100
Message-ID: <20150322235308.GA9373@gondor.apana.org.au>
References: <20150322215612.GA8274@gondor.apana.org.au>
 <20150322.185850.927485035002538859.davem@davemloft.net>
 <20150322230848.GA8989@gondor.apana.org.au>
 <20150322.195003.654000183854114521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	roland@purestorage.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47201 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbbCVXxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:53:10 -0400
Content-Disposition: inline
In-Reply-To: <20150322.195003.654000183854114521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 07:50:03PM -0400, David Miller wrote:
>
> BTW I asked for feedback when I posted the patches which created this
> situation, and the multiply with the random input was believed to have
> sufficient entropy and not create a situation any worse,
> asymptotically, than what we had beforehand.

I know.  I just didn't know at the time or I would have objected :)

> Perhaps the ipv6 case can be improved, by using a u32 random input
> for each u32 of the address being hashed.

See my follow-up email.  The multiplication is useless against
an adversary, even if you multiply it against a secret odd value
because there is a bit-to-bit correspondence between the key and
the final hash value.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
