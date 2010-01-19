From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] IFix IPv6 GSO type checks in Intel
	ethernet drivers
Date: Wed, 20 Jan 2010 11:39:34 +1300
Message-ID: <20100119223934.GA30140@gondor.apana.org.au>
References: <1263934927.1635.24.camel@w-sridhar.beaverton.ibm.com> <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41407 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750775Ab0ASXFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 18:05:47 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2010 at 01:11:00PM -0800, Brandeburg, Jesse wrote:
>
> Looks fine, thanks!  The current code in net-next and 2.6.32 both have 
> exactly the same condition in skb_is_gso_v6, so I'm not sure that this 
> patch alone will fix any issues, FYI.  If this patch is part of another 
> set or dependent upon another for the actual change in behavior mentioned 
> in the comment, I think it should be noted or sent in a series.

skb_is_gso_v6 does an & test instead of == so the patch is definitely
not a noop.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
