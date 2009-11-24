From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvlan: fix gso_max_size setting
Date: Tue, 24 Nov 2009 09:08:17 +0800
Message-ID: <20091124010817.GB13660@gondor.apana.org.au>
References: <4B0A64E2.8090203@trash.net> <20091123.101013.40629093.davem@davemloft.net> <4B0B087B.3020000@trash.net> <20091123.142207.14190542.davem@davemloft.net> <4B0B0DA1.7010403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754690AbZKXBIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 20:08:16 -0500
Content-Disposition: inline
In-Reply-To: <4B0B0DA1.7010403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2009 at 11:33:05PM +0100, Patrick McHardy wrote:
> 
> Perhaps we should simply fall back to software in that case.
> Compile tested only.

Sure.

Since ixgbe appears to be the only driver in our entire tree
that has this limitation, I think it might make more sense to
move this special-case check into it and get it to do software
GSO just like tg3 does for a few other cases that the hardware
can't handle.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
