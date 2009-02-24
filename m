From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm selector generating IKE
Date: Tue, 24 Feb 2009 10:08:39 +0800
Message-ID: <20090224020839.GC18696@gondor.apana.org.au>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56349 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752296AbZBXCIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 21:08:54 -0500
Content-Disposition: inline
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2009 at 05:31:29PM -0800, Paul Moore wrote:
> Do you know which version of *swan generates xfrm selectors when it does
> an SA ADD or UPDATE. I downloaded openswan 2.6.19 and it does not

The selector logic doesn't work very well with nested tunnels
which is why I didn't use it for the original Openswan port.
We rely on the policy selector instead to do the job.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
