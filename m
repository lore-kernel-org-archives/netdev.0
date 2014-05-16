From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: unix: Align send data_len up to
 PAGE_SIZE
Date: Fri, 16 May 2014 16:04:30 -0400 (EDT)
Message-ID: <20140516.160430.693407970902273122.davem@davemloft.net>
References: <1400169388.3782.35.camel@tkhai>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ktkhai@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874AbaEPUEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:04:32 -0400
In-Reply-To: <1400169388.3782.35.camel@tkhai>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kirill Tkhai <ktkhai@parallels.com>
Date: Thu, 15 May 2014 19:56:28 +0400

> Using whole of allocated pages reduces requested skb->data size.
> This is just a little more thriftily allocation.
>     
> netperf does not show difference with the current performance.
>     
> Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>

Applied, thank you.
