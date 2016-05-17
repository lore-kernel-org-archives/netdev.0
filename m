From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: fix memory limitation drift
Date: Mon, 16 May 2016 21:57:03 -0400 (EDT)
Message-ID: <20160516.215703.1101489106168609896.davem@davemloft.net>
References: <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463361398.18194.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, dave.taht@gmail.com, netdev@vger.kernel.org,
	moeller0@gmx.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933608AbcEQB5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:57:06 -0400
In-Reply-To: <1463361398.18194.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 May 2016 18:16:38 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> memory_usage must be decreased in dequeue_func(), not in
> fq_codel_dequeue(), otherwise packets dropped by Codel algo
> are missing this decrease.
> 
> Also we need to clear memory_usage in fq_codel_reset()
> 
> Fixes: 95b58430abe7 ("fq_codel: add memory limitation per queue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
