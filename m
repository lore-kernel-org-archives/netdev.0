From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 14:16:32 -0400
Message-ID: <20091030181632.GA9530@gondor.apana.org.au>
References: <20091029.213816.35637194.davem@davemloft.net> <20091030155420.GA8345@gondor.apana.org.au> <20091030.111027.234994529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bphilips@suse.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55895 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932778AbZJ3SQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:16:36 -0400
Content-Disposition: inline
In-Reply-To: <20091030.111027.234994529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 11:10:27AM -0700, David Miller wrote:
. 
> Because the driver must start in state with carrier off anyways,
> so that we get the transition event when the device comes up
> from link down to link up.

Well we want all drivers to start in state NOCARRIER.  However,
a freshly allocated netdev has the NOCARRIER bit off.  This means
every single driver has to set the NOCARRIER bit.

It would seem much easier to ensure that the NOCARRIER bit is set
in a newly allocated netdev.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
