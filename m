From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 17:29:27 +0800
Message-ID: <20071221092927.GA32434@gondor.apana.org.au>
References: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi> <20071220.035621.147230372.davem@davemloft.net> <20071221030648.389669c4.billfink@mindspring.com> <20071221.012720.67812056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: billfink@mindspring.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, jheffner@psc.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3083 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754057AbXLUJ3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:29:43 -0500
Content-Disposition: inline
In-Reply-To: <20071221.012720.67812056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2007 at 01:27:20AM -0800, David Miller wrote:
>
> It's two shifts, and this gets scheduled along with the other
> instructions on many cpus so it's effectively free.
> 
> I don't see why this is even worth mentioning and discussing.

I totally agree.  Two shifts are way better than a branch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
