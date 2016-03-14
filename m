From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: diag: add a scheduling point in
 inet_diag_dump_icsk()
Date: Mon, 14 Mar 2016 19:38:37 -0400 (EDT)
Message-ID: <20160314.193837.2161977859793491820.davem@davemloft.net>
References: <1457995200.31401.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbcCNXij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 19:38:39 -0400
In-Reply-To: <1457995200.31401.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Mar 2016 15:40:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> On loaded TCP servers, looking at millions of sockets can hold
> cpu for many seconds, if the lookup condition is very narrow.
> 
> (eg : ss dst 1.2.3.4 )
> 
> Better add a cond_resched() to allow other processes to access
> the cpu.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
