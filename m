From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 22:19:53 +0800
Message-ID: <20080725141953.GA19418@gondor.apana.org.au>
References: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl> <E1KMO85-00052z-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35269 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751303AbYGYOT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 10:19:59 -0400
Content-Disposition: inline
In-Reply-To: <E1KMO85-00052z-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 10:18:45PM +0800, Herbert Xu wrote:
> 
> Pick one of these:
> 
> 1) You have less RAM;
> 2) Your memory fragmentation has deteriorated;
> 3) Most likely: you were just lucky :)

Actually even more likely, someone has sent you a huge packet
which triggered this (> 32K if I remember your trace correctly).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
