From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Mon, 4 Aug 2008 11:05:07 +0800
Message-ID: <20080804030507.GA7091@gondor.apana.org.au>
References: <E1KPpI7-0001jn-00@gondolin.me.apana.org.au> <4896703E.1070203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38215 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753861AbYHDDFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 23:05:47 -0400
Content-Disposition: inline
In-Reply-To: <4896703E.1070203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 10:58:06AM +0800, Wei Yongjun wrote:
>
> You need this patch to let sctp under IPv6 do the correct thing.

Good point.

> ipv6: Do not drop packet if skb->local_df is set to true
> 
> The old code will drop IPv6 packet if ipfragok is not set, since ipfragok is
> obsoleted, will be instead by used skb->local_df, so this check must be 
> changed
> to skb->local_df.
> 
> This patch fix this problem and not drop packet if skb->local_df is set to
> true.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
