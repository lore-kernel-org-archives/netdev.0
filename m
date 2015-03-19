From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2] rhashtable: Warn if min_size or max_size are
 not a power of two
Date: Fri, 20 Mar 2015 08:02:39 +1100
Message-ID: <20150319210239.GB9601@gondor.apana.org.au>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35555 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbCSVCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:02:46 -0400
Content-Disposition: inline
In-Reply-To: <20150319194608.GA27962@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 07:46:08PM +0000, Thomas Graf wrote:
> The current code correctly limits table size to the next power of two.
> This check is solely to catch programming errors.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I don't see the point of this.  A maximum size of 3 says that
the table size should never exceed 3 which makes perfect sense.
And our current code will respect that.

So why force it to be a power of 2 just because our table sizes
happen to be powers of 2?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
