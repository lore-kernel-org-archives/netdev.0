From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: rename ir_loc_port to ir_num
Date: Thu, 10 Oct 2013 14:39:26 -0400 (EDT)
Message-ID: <20131010.143926.1108289725747317852.davem@davemloft.net>
References: <1381388677.4971.65.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab3JJSj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 14:39:27 -0400
In-Reply-To: <1381388677.4971.65.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Oct 2013 00:04:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 634fb979e8f ("inet: includes a sock_common in request_sock")
> I forgot that the two ports in sock_common do not have same byte order :
> 
> skc_dport is __be16 (network order), but skc_num is __u16 (host order)
> 
> So sparse complains because ir_loc_port (mapped into skc_num) is
> considered as __u16 while it should be __be16
> 
> Let rename ir_loc_port to ireq->ir_num (analogy with inet->inet_num),
> and perform appropriate htons/ntohs conversions.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>

Applied, thanks Eric.
