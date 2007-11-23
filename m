From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] add compare_ether_addr_unaligned
Date: Fri, 23 Nov 2007 21:26:32 +0800
Message-ID: <20071123132631.GI18862@gondor.apana.org.au>
References: <20071123000922.C44009D4A1F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1157 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752493AbXKWN0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 08:26:48 -0500
Content-Disposition: inline
In-Reply-To: <20071123000922.C44009D4A1F@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 12:09:22AM +0000, Daniel Drake wrote:
> David Miller found a problem in a wireless driver where I was using
> compare_ether_addr() on potentially unaligned data. Document that
> compare_ether_addr() is not safe for use everywhere, and add an equivalent
> function that works regardless of alignment.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Patch applied to net-2.6.  Thanks.

I presume there will be some follow-on work to use this function?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
