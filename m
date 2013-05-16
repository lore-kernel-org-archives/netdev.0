From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 15:02:39 -0700 (PDT)
Message-ID: <20130516.150239.2187164031807939707.davem@davemloft.net>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	<1368725693.3301.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	maze@google.com, andy@greyhouse.net, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab3EPWCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:02:40 -0400
In-Reply-To: <1368725693.3301.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 May 2013 10:34:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In some situations, we need to disable TSO on bonding slaves.
> 
> bonding device automatically unset TSO in bond_fix_features(), and
> performance is not good because :
> 
> 1) We consume more cpu cycles.
> 
> 2) GSO segmentation has some bugs leading to out of order TCP packets
> if this segmentation is done before virtual device. This particular
> problem will be addressed in a separate patch.
> 
> This patch allows TSO being set/unset on the bonding master,
> so that GSO segmentation is done after bonding layer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, but:

> +static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
> +	netdev_features_t mask)

I fixed the mask argument indentation when I commited this.

Thakns.
