From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove sk_init() helper
Date: Thu, 27 Sep 2012 18:42:30 -0400 (EDT)
Message-ID: <20120927.184230.1860684890668420276.davem@davemloft.net>
References: <1348608733.26828.3492.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891Ab2I0Wmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:42:31 -0400
In-Reply-To: <1348608733.26828.3492.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Sep 2012 23:32:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems sk_init() has no value today and even does strange things :
> 
> # grep . /proc/sys/net/core/?mem_*
> /proc/sys/net/core/rmem_default:212992
> /proc/sys/net/core/rmem_max:131071
> /proc/sys/net/core/wmem_default:212992
> /proc/sys/net/core/wmem_max:131071
> 
> We can remove it completely.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
