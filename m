From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2] rhashtable: Warn if min_size or max_size are
 not a power of two
Date: Fri, 20 Mar 2015 08:49:33 +1100
Message-ID: <20150319214933.GA11937@gondor.apana.org.au>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
 <20150319210239.GB9601@gondor.apana.org.au>
 <20150319211546.GA4190@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45199 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbbCSVti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20150319211546.GA4190@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 09:15:46PM +0000, Thomas Graf wrote:
>
> rht_grow_above_75() checks the old table size:
> 
> (!ht->p.max_size || tbl->size < ht->p.max_size);
> 
> If you specify max_size = 3, it grows the table to tbl->size = 4.
> This can be avoided if max_size is a power of two.

OK let's fix the test then.  The easiest way would be to round
max_size up to the next power of 2.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
