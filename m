From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Net: Don't send ICMP_FRAG_NEEDED for GSO packets
Date: Fri, 28 Mar 2008 16:40:43 +0800
Message-ID: <20080328084043.GA22513@gondor.apana.org.au>
References: <200803281934.09308.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	John Heffner <jheffner@psc.edu>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46842 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750774AbYC1Ikt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 04:40:49 -0400
Content-Disposition: inline
In-Reply-To: <200803281934.09308.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 07:34:08PM +1100, Rusty Russell wrote:
> Commit 9af3912ec9e30509b76cb376abb65a4d8af27df3 added a new check to
> send ICMP fragmentation needed for large packets.
> 
> Unlike the check in ip_finish_output(), it doesn't check for GSO.  I
> triggered this with the GSO TUN patches, so not sure if it needs to be
> in 2.6.25 or not (do we otherwise forward GSO packets?).
> 
> Cc: John Heffner <jheffner@psc.edu>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Since this is a regression for Xen, I would say yes.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
