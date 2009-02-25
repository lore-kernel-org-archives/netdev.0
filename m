From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm selector generating IKE
Date: Wed, 25 Feb 2009 08:33:30 +0800
Message-ID: <20090225003330.GA29906@gondor.apana.org.au>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60143 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752014AbZBYAdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 19:33:40 -0500
Content-Disposition: inline
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 09:23:39AM -0800, Paul Moore wrote:
> are you sure that works. the xfrm code in the kernel does not look at
> the policy selector when checking port numbers to see if it should reuse
> an existing SA. It only looks at the selector on the SA - this is why
> racoon has a problem. The policy selector has the correct portness in it
> but the SA does not. I have not tested it but I suspect openswan has the
> same issue since it passes in an empty SA selector

Yes I'm sure it works :) It uses the reqid field to tie policies
to the SAs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
