From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: Add debug info to track down GSO checksum bug
Date: Mon, 19 Jan 2009 22:16:06 +1100
Message-ID: <20090119111606.GA2575@gondor.apana.org.au>
References: <20090116072251.GA13327@gondor.apana.org.au> <20090118.220803.257200823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41569 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755152AbZASLQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 06:16:10 -0500
Content-Disposition: inline
In-Reply-To: <20090118.220803.257200823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 10:08:03PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 16 Jan 2009 18:22:51 +1100
> 
> > net: Add debug info to track down GSO checksum bug
> > 
> > I'm trying to track down why people're hitting the checksum warning
> > in skb_gso_segment.  As the problem seems to be hitting lots of
> > people and I can't reproduce it or locate the bug, here is a patch
> > to print out more details which hopefully should help us to track
> > this down.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Herbert, do you still want me to add this debugging hack to
> the tree?

Yes please do unless there is a better way in finding the bug
and fixing it :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
