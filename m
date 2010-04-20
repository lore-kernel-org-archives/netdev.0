From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: add a missing ntohs()
Date: Tue, 20 Apr 2010 21:30:16 +0800
Message-ID: <20100420133016.GA21788@gondor.apana.org.au>
References: <1271769605.7895.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:43022 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754620Ab0DTNa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:30:26 -0400
Content-Disposition: inline
In-Reply-To: <1271769605.7895.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 03:20:05PM +0200, Eric Dumazet wrote:
> Found by code review and sparse endianness warning, I am not sure this
> patch is valid.
> 
> Thanks
> 
> [PATCH] bridge: add a missing ntohs()
> 
> grec_nsrcs is in network order, we should convert to host horder in
> br_multicast_igmp3_report()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Eric!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
