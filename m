From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: xps: fix reordering issues
Date: Thu, 23 May 2013 18:29:39 -0700 (PDT)
Message-ID: <20130523.182939.1656578741039330554.davem@davemloft.net>
References: <1369331060.3301.396.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758000Ab3EXB3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:29:40 -0400
In-Reply-To: <1369331060.3301.396.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 May 2013 10:44:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 3853b5841c01a ("xps: Improvements in TX queue selection")
> introduced ooo_okay flag, but the condition to set it is slightly wrong.
> 
> In our traces, we have seen ACK packets being received out of order,
> and RST packets sent in response.
> 
> We should test if we have any packets still in host queue.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
