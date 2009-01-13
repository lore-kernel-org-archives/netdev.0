From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
	2.6.24?
Date: Tue, 13 Jan 2009 17:32:05 +1100
Message-ID: <20090113063205.GA26047@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47386 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752689AbZAMGca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 01:32:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink@mindspring.com> wrote:
>
> If I understand you correctly, to hit this corner case, just after
> the final TCP write, there would have to be no packets in flight
> together with a zero TCP window.  To make it more bullet-proof, I
> guess after seeing a zero tcpi_unacked, an additional small delay
> should be performed, and then rechecking for a zero tcpi_unacked.
> I don't see anything else obvious (to me anyway) in the tcp_info
> that would be particularly helpful in handling this.

What's wrong with idiag_wqueue? Isn't that a much more direct
way to get this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
