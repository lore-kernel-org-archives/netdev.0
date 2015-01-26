From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 10:31:00 +1100
Message-ID: <20150126233100.GA31108@gondor.apana.org.au>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight@ACULAB.COM, tgraf@suug.ch, ying.xue@windriver.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45769 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757473AbbAZXbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 18:31:37 -0500
Content-Disposition: inline
In-Reply-To: <20150126224216.GA30551@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 09:42:16AM +1100, Herbert Xu wrote:
> 
> As otherwise we'd be looking at fixing the existing users (in
> particular, nft_hash) properly which might take a lot more time.

I take that back.  Looks like my walkers would be no good for
netfilter anyway since it wants to do nested walks, meaning no
locks can be taken.

So I think I'll just have to tackle netfilter first in which case
the walk function would be no use anyway since I could just fix
netlink by itself.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
