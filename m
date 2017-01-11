From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gro: Enter slow-path if there is no tailroom
Date: Tue, 10 Jan 2017 21:29:11 -0500 (EST)
Message-ID: <20170110.212911.71346127320993214.davem@davemloft.net>
References: <1484079841.21472.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        slavash@mellanox.com, willemb@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbdAKC3O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:29:14 -0500
In-Reply-To: <1484079841.21472.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jan 2017 12:24:01 -0800

> From: Herbert Xu <herbert@gondor.apana.org.au>
> 
> The GRO path has a fast-path where we avoid calling pskb_may_pull
> and pskb_expand by directly accessing frag0.  However, this should
> only be done if we have enough tailroom in the skb as otherwise
> we'll have to expand it later anyway.
> 
> This patch adds the check by capping frag0_len with the skb tailroom.
> 
> Fixes: cb18978cbf45 ("gro: Open-code final pskb_may_pull")
> Reported-by: Slava Shwartsman <slavash@mellanox.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Eric Dumazet <edumazet@google.com>


Applied and queued up for -stable.
