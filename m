From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: avoid double copy in
 skb_gro_receive()
Date: Tue, 11 Dec 2012 13:45:19 -0500 (EST)
Message-ID: <20121211.134519.1844951486135447108.davem@davemloft.net>
References: <1355251109.27891.114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab2LKSpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:45:20 -0500
In-Reply-To: <1355251109.27891.114.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 11 Dec 2012 10:38:29 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> __copy_skb_header(nskb, p) already copied p->cb[], no need to copy
> it again.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
