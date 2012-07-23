From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 15:22:20 -0700 (PDT)
Message-ID: <20120723.152220.822947775372843073.davem@davemloft.net>
References: <20120723.140737.822125500680433996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717Ab2GWWWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 18:22:21 -0400
In-Reply-To: <20120723.140737.822125500680433996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 23 Jul 2012 14:07:37 -0700 (PDT)

> On input packet processing, rt->rt_iif will be zero if we should
> use skb->dev->ifindex.
> 
> Since we access rt->rt_iif consistently via inet_iif(), that is
> the only spot whose interpretation have to adjust.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Julian, as you seem to have feared, this turns out to not work.

We zap the skb->dev apparently, so I'll need to come up with
a different scheme to handle this.
