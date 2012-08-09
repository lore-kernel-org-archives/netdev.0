From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: must free metrics at net dismantle
Date: Thu, 09 Aug 2012 02:31:54 -0700 (PDT)
Message-ID: <20120809.023154.67798345591311114.davem@davemloft.net>
References: <1344503953.28967.575.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761Ab2HIJb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 05:31:57 -0400
In-Reply-To: <1344503953.28967.575.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Aug 2012 11:19:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We currently leak all tcp metrics at struct net dismantle time.
> 
> tcp_net_metrics_exit() frees the hash table, we must first
> iterate it to free all metrics.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
