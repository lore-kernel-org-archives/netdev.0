From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 11:54:20 -0400
Message-ID: <20091030155420.GA8345@gondor.apana.org.au>
References: <20091029.213816.35637194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bphilips@suse.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33445 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932469AbZJ3PyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 11:54:23 -0400
Content-Disposition: inline
In-Reply-To: <20091029.213816.35637194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> I agree that we should report something consistent before interface
> up and 'no' is probably the best.
> 
> I remember fixing something similar in other drivers a few months
> ago.

Can't we do this in one spot rather than having every driver
duplicate this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
