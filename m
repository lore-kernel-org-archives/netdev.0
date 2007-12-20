From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 22:00:12 +0800
Message-ID: <20071220140012.GA22495@gondor.apana.org.au>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi> <20071219.235450.170670042.davem@davemloft.net> <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi> <20071220.040037.48002365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3055 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753616AbXLTOA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 09:00:29 -0500
Content-Disposition: inline
In-Reply-To: <20071220.040037.48002365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2007 at 04:00:37AM -0800, David Miller wrote:
>
> In the most ideal sense, tcp_window_allows() should probably
> be changed to only return MSS multiples.
> 
> Unfortunately this would add an expensive modulo operation,
> however I think it would elimiate this problem case.

Well you only have to divide in the unlikely case of us being
limited by the receiver window.  In that case speed is probably
not of the essence anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
