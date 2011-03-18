From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: VLAN over GRE segfault
Date: Fri, 18 Mar 2011 14:28:59 -0500
Message-ID: <20110318192859.GA26156@gondor.apana.org.au>
References: <4D830AF9.8040007@diddi.se> <1300444047.2888.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Diddi Oscarsson <diddi@diddi.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58443 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756818Ab1CRT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:29:12 -0400
Content-Disposition: inline
In-Reply-To: <1300444047.2888.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 11:27:27AM +0100, Eric Dumazet wrote:
>
> This uncover a bug in vlan code.
> 
> We should make sure vlan devices take into account their
> real_dev->needed_headroom or we risk a crash in ipgre_header(), because
> we dont have enough room to push IP header in skb.
> 
> Reported-by: Diddi Oscarsson <diddi@diddi.se>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
