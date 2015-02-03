From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/4] rhashtable: Add iterators and use them
Date: Wed, 4 Feb 2015 07:32:13 +1100
Message-ID: <20150203203213.GA23177@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41736 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966353AbbBCUcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 15:32:19 -0500
Content-Disposition: inline
In-Reply-To: <20150203201750.GA22474@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2015 at 07:17:50AM +1100, Herbert Xu wrote:
> 
> > ERROR: "rhashtable_walk_start" [net/netfilter/nft_hash.ko] undefined!
> 
> Oops, I missed an export on that symbol.  I'll fix it up and
> repost.

OK here is the repost without the hash_rnd patch.

The first patch fixes a potential crash with nft_hash destroying
the table during a shrinking process.  While the next patch adds
rhashtable iterators to replace current manual walks used by
netlink and netfilter.  The final two patches make use of these
iterators in netlink and netfilter.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
