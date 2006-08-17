From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6936] BUG: warning at net/core/dev.c:1171/skb_checksum_help()
Date: Thu, 17 Aug 2006 10:13:50 +1000
Message-ID: <20060817001349.GA3225@gondor.apana.org.au>
References: <200608151829.k7FITxKM006438@fire-2.osdl.org> <20060816012900.GA23430@gondor.apana.org.au> <20060816110631.42b20c77@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:9485 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932146AbWHQAOW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 20:14:22 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060816110631.42b20c77@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 11:06:31AM -0700, Stephen Hemminger wrote:
>
> agree. I assume this came in with the new GSO for 2.6.18 or do we need
> to fix 2.6.17 as well.

I think 2.6.17 should be fine because it would only happen there if
the underlying device itself had an inconsistent configuration (TX
checksum off and SG/TSO on).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
