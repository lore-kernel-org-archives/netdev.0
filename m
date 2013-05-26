From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2 V2] tcp: Remove another indentation level
 in tcp_rcv_state_process
Date: Sat, 25 May 2013 23:23:09 -0700 (PDT)
Message-ID: <20130525.232309.1565467248424392703.davem@davemloft.net>
References: <1369454556.2080.4.camel@joe-AO722>
	<1369455898.3301.466.camel@edumazet-glaptop>
	<1369456573.2080.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ycheng@google.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab3EZGXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:23:10 -0400
In-Reply-To: <1369456573.2080.15.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 24 May 2013 21:36:13 -0700

> case TCP_SYN_RECV: can have another indentation level removed
> by converting
> 
> 	if (acceptable) {
> 		...;
> 	} else {
> 		return 1;
> 	}
> 
> to
> 	if (!acceptable)
> 		return 1;
> 	...;
> 
> Reflow code and comments to fit 80 columns.
> 
> Another pure cleanup patch.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Improved-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
