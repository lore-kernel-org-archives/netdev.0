From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Thu, 25 Dec 2008 07:41:53 +1100
Message-ID: <20081224204152.GB32060@gondor.apana.org.au>
References: <20081224060225.GA26084@obsidianresearch.com> <20081224085940.GA24830@gondor.apana.org.au> <20081224183355.GB26084@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43083 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750952AbYLXUmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 15:42:03 -0500
Content-Disposition: inline
In-Reply-To: <20081224183355.GB26084@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 11:33:55AM -0700, Jason Gunthorpe wrote:
>
> BTW, Herbert, if this is the way to go can you fix StrongSwan?

No I can't since I'm not a Strongswan developer :)

I've cced the people who can though.

> Mapping AUTH_HMAC_SHA2_256_128 to 'sha256' in
> src/charon/plugins/kernel_netlink/kernel_netlink_ipsec.c is not
> correct based on this discussion. It needs to be 'hmac(sha256)' and
> use this XFRMA_AUTH2 idea. Similarly for all the SHA-2 family of
> functions I guess.

Strongswan needs to drop SHA2-256-128 for now since we don't support
it currently.  Once we have XFRMA_AUTH2 it can be restored of course.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
