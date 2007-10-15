From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/10] [BRIDGE]: Unshare skb upon entry
Date: Mon, 15 Oct 2007 16:04:16 +0800
Message-ID: <20071015080416.GA29580@gondor.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4q-00030k-00@gondolin.me.apana.org.au> <471314A0.5080500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2064 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754349AbXJOIEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:04:46 -0400
Content-Disposition: inline
In-Reply-To: <471314A0.5080500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 09:20:00AM +0200, Patrick McHardy wrote:
>
> I guess we can remove the unsharing from br_netfilter.c now.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Well caught!

In fact this would have been a bug before my patch if it ever
triggered (fortunately it shouldn't with the stock kernel).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
