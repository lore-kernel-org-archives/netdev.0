From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp_cubic: refine Hystart delay threshold
Date: Tue, 09 Dec 2014 14:58:56 -0500 (EST)
Message-ID: <20141209.145856.1280304544503810169.davem@davemloft.net>
References: <1417738429.22424.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com,
	ycheng@google.com, sangtae.ha@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaLIT66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:58:58 -0500
In-Reply-To: <1417738429.22424.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Dec 2014 16:13:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 2b4636a5f8ca ("tcp_cubic: make the delay threshold of HyStart
> less sensitive"), HYSTART_DELAY_MIN was changed to 4 ms.
> 
> The remaining problem is that using delay_min + (delay_min/16) as the
> threshold is too sensitive.
> 
> 6.25 % of variation is too small for rtt above 60 ms, which are not
> uncommon.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
