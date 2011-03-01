From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 20:35:19 +0800
Message-ID: <20110301123519.GA7453@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net> <20110226005718.GA19889@gondor.apana.org.au> <20110227110205.GE9763@canuck.infradead.org> <20110227110614.GA6246@gondor.apana.org.au> <20110228113659.GA20726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44551 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab1CAMfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:35:31 -0500
Content-Disposition: inline
In-Reply-To: <20110228113659.GA20726@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
> Here are the patches I used.  Please don't them yet as I intend
> to clean them up quite a bit.

OK here is the version ready for merging (please retest them
though as I have changed things substantially).

The main change is that the legacy UDP code path is now gone
so we use the same UDP header generation whether corking is on
or off.

I will add IPv6 support in a later patch set.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
