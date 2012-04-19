From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: GRO_MERGED_FREE consumes packets
Date: Thu, 19 Apr 2012 14:25:10 -0400 (EDT)
Message-ID: <20120419.142510.2116612273311986378.davem@davemloft.net>
References: <1334855260.2395.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab2DSSZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:25:13 -0400
In-Reply-To: <1334855260.2395.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Apr 2012 19:07:40 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> As part of GRO processing, merged skbs should be consumed, not freed, to
> not confuse dropwatch/drop_monitor.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
