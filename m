From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove dead code after sk_data_ready
 change
Date: Fri, 22 Aug 2014 21:09:15 -0700 (PDT)
Message-ID: <20140822.210915.471034540859251652.davem@davemloft.net>
References: <1408764612.5604.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbaHWEQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 00:16:40 -0400
In-Reply-To: <1408764612.5604.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Aug 2014 20:30:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As a followup to commit 676d23690fb ("net: Fix use after free by
> removing length arg from sk_data_ready callbacks"), we can remove
> some useless code in sock_queue_rcv_skb() and rxrpc_queue_rcv_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch, applied.
