From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 00:46:40 -0700 (PDT)
Message-ID: <20110705.004640.2280047904273455681.davem@davemloft.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	<1309846875.2720.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab1GEHqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:46:49 -0400
In-Reply-To: <1309846875.2720.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2011 08:21:15 +0200

> rxhash is 0 unless skb_get_rxhash() was called, or some NIC set it in RX
> path.

CONFIG_RPS is effectively on all the time for SMP builds.

If you want to make it a hard enable in that situation,
I fully support such a change. :-)

