From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: restore conditional call to
 napi_complete_done()
Date: Mon, 10 Nov 2014 21:13:30 -0500 (EST)
Message-ID: <20141110.211330.1246867583617109895.davem@davemloft.net>
References: <20141107.170053.1003349690694025765.davem@redhat.com>
	<1415642488.9613.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1415657240.9613.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbaKKCNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:13:32 -0500
In-Reply-To: <1415657240.9613.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Nov 2014 14:07:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 1a28817282 ("mlx4: use napi_complete_done()") we ended up
> calling napi_complete_done() in the case NAPI poll consumed all its
> budget.
> 
> This added extra interrupt pressure, this patch restores proper
> behavior.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 1a28817282 ("mlx4: use napi_complete_done()")

Applied, thanks Eric.
