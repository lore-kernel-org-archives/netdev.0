From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:rfs: adjust table size checking
Date: Sun, 08 Feb 2015 21:56:37 -0800 (PST)
Message-ID: <20150208.215637.801300675160754948.davem@davemloft.net>
References: <1423456753.31870.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbBIF4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 00:56:38 -0500
In-Reply-To: <1423456753.31870.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 08 Feb 2015 20:39:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Make sure root user does not try something stupid.
> 
> Also make sure mask field in struct rps_sock_flow_table
> does not share a cache line with the potentially often dirtied
> flow table.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 567e4b79731c ("net: rfs: add hash collision detection")

Applied, thanks Eric.
