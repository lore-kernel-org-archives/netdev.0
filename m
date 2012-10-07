From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gro: fix a potential crash in skb_gro_reset_offset
Date: Sun, 07 Oct 2012 14:50:10 -0400 (EDT)
Message-ID: <20121007.145010.1082292669443081397.davem@davemloft.net>
References: <1349598486.21172.2063.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab2JGSuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:50:12 -0400
In-Reply-To: <1349598486.21172.2063.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 07 Oct 2012 10:28:06 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Before accessing skb first fragment, better make sure there
> is one.
> 
> This is probably not needed for old kernels, since an ethernet frame
> cannot contain only an ethernet header, but the recent GRO addition
> to tunnels makes this patch needed.
> 
> Also skb_gro_reset_offset() can be static, it actually allows
> compiler to inline it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Eric.
