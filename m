From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: Interfamily support for IPSEC BEET
Date: Fri, 19 Oct 2007 22:22:22 +0800
Message-ID: <E1Iisk2-0003qj-00@gondolin.me.apana.org.au>
References: <200710191307.55589.joakim.koskela@hiit.fi>
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4184 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752047AbXJSOWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 10:22:32 -0400
In-Reply-To: <200710191307.55589.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela <joakim.koskela@hiit.fi> wrote:
> Hi,
> 
> Here's an updated version of the patch adding support for ipv4/ipv6
> interfamily addressing for the ipsec BEET (Bound End-to-End Tunnel)
> mode, as specified by the ietf draft found at:
> 
> http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-07.txt
> 
> The previous implementation required that both address pairs in the SA
> were of the same family. This patch enables mixing ipv4 and ipv6
> addresses. All combinations (4-4, 4-6, 6-4, 6-6) have been tested.
> 
> The generic interfamily fixes have been chopped off from this into
> separate patches.

Please hold onto this.  I've got a more generic version of this
that doesn't duplicate the inter-family logic between BEET mode
and tunnel mode.

Instead I've created a generic function that reads info from the
inner header and puts them in an address-neutral format which is
then picked up by either BEET or tunnel mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
