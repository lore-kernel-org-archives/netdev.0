From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in IPSEC?
Date: Thu, 3 Aug 2006 11:19:59 +1000
Message-ID: <20060803011959.GB4958@gondor.apana.org.au>
References: <34d8b2fe0608020808r7539ccc9h3f9a0beb5819d0a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:28687 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932105AbWHCBUJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 21:20:09 -0400
To: Louis Croisez <louis.croisez@gmail.com>
Content-Disposition: inline
In-Reply-To: <34d8b2fe0608020808r7539ccc9h3f9a0beb5819d0a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2006 at 05:08:39PM +0200, Louis Croisez wrote:
> 
> I think that 96 bits for the truncated version of the hmac is not
> enough with respect to RFC 2104, p5 ?1 :
> "... We recommend that the output length to be not less than half the
> length of the hash output ... and not less than 80 bits ..."
> 
> I thing that the truncated length should be 128 bits in this case...
> Do you agree?

(To recap our sha256 IPsec implementation truncates the output to 96
bits while the last IETF draft on sha256 and the general HMAC RFC
requires 128 bits)

Yes I agree with your assessment.

Changing it is nasty though since we don't know how many Linux users
have deployed this.

Also, we should keep in mind that the IETF has given up on sha256
altogether.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
