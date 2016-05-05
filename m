From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: two more missing bh disable
Date: Thu, 05 May 2016 00:25:49 -0400 (EDT)
Message-ID: <20160505.002549.868922626404541926.davem@davemloft.net>
References: <1462386131.5535.353.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160504.170641.134283593327091145.davem@davemloft.net>
	<1462400849.13075.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbcEEEZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:25:52 -0400
In-Reply-To: <1462400849.13075.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 May 2016 15:27:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> percpu_counter only have protection against preemption.
> 
> TCP stack uses them possibly from BH, so we need BH protection
> in contexts that could be run in process context
> 
> Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
