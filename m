From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] idsn: fix wrong skb_put() used
Date: Wed, 21 Jun 2017 09:52:07 -0400 (EDT)
Message-ID: <20170621.095207.1836095159650465700.davem@davemloft.net>
References: <1498046680-22872-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdFUNwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:52:11 -0400
In-Reply-To: <1498046680-22872-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Wed, 21 Jun 2017 20:04:40 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> in my commit b952f4dff2751252db073c27c0f8a16a416a2ddc,
> -	*(u8 *)skb_put(skb_out, 1) = (u8)(accm >> 24);	\
> +	skb_put(skb_out, (u8)(accm >> 24));	\
> it should skb_put_u8()
> 
> Fixes: b952f4dff275 ("net: manual clean code which call skb_put_[data:zero])")
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Applied.
