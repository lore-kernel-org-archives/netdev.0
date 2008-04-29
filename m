From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 09:41:07 +0800
Message-ID: <20080429014107.GA16700@gondor.apana.org.au>
References: <48161D99.5070303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43672 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751730AbYD2BlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 21:41:09 -0400
Content-Disposition: inline
In-Reply-To: <48161D99.5070303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick:

On Mon, Apr 28, 2008 at 08:55:21PM +0200, Patrick McHardy wrote:
> I ran into occasional BUGs in scatterlist.h, which turned
> out the be caused by accessing an uninitialized scatterlist
> entry from eseqiv. I'm not sure whether this patch is correct
> since I'm seeing invalid packets with and without this patch
> (probably related to HIFN though) and I don't understand why
> scatterwalk_sg_next() returns either a scatterlist or a
> struct page dependant on the length, but at least it fixes
> the BUG() for me :)

Can you attach the BUG output please?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
