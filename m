From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] rhashtable: Round up/down min/max_size to
 ensure we respect limit
Date: Fri, 20 Mar 2015 09:41:49 +1100
Message-ID: <20150319224149.GA12641@gondor.apana.org.au>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
 <20150319210239.GB9601@gondor.apana.org.au>
 <20150319211546.GA4190@casper.infradead.org>
 <20150319214933.GA11937@gondor.apana.org.au>
 <20150319220248.GA12428@gondor.apana.org.au>
 <20150319223113.GD4190@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39746 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbCSWlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 18:41:53 -0400
Content-Disposition: inline
In-Reply-To: <20150319223113.GD4190@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 10:31:13PM +0000, Thomas Graf wrote:
> Round up min_size respectively round down max_size to the next power
> of two to make sure we always respect the limit specified by the
> user. This is required because we compare the table size against the
> limit before we expand or shrink.
> 
> Also fixes a minor bug where we modified min_size in the params
> provided instead of the copy stored in struct rhashtable.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

> ---
> Herbert: I'm fine with either approach. I figured you expected the
> user to take care of this, hence the added warning. This is perfectly
> fine with me me as well.

Thanks for fixing this.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
