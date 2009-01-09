From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 9 Jan 2009 17:30:55 +1100
Message-ID: <20090109063055.GA6949@gondor.apana.org.au>
References: <20090109041952.GA12087@gondor.apana.org.au> <4966DABD.1000203@pobox.com> <20090109051500.GA12836@gondor.apana.org.au> <4966E0ED.9090905@pobox.com> <20090109053520.GA13219@gondor.apana.org.au> <4966EE86.3030704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56893 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755436AbZAIGbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 01:31:07 -0500
Content-Disposition: inline
In-Reply-To: <4966EE86.3030704@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 01:28:22AM -0500, Jeff Garzik wrote:
>
> Not quite true...  it touches the driver's rx-csum hook.

Only because we never put the RX offload flag in a place that's
independent of the driver.  Also GRO never sets the RX offload
flag (or clears it).

> Well, whichever.  Overall, if [GS]GRO remains I am happy to take patches  
> supporting it in the userspace utility...

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
