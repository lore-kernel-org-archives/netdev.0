From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: account for skb allocation failures
Date: Tue, 12 Jul 2011 22:09:28 -0700 (PDT)
Message-ID: <20110712.220928.1378183859534982472.davem@davemloft.net>
References: <1310520703.2634.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ajit.khaparde@emulex.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab1GMFJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 01:09:33 -0400
In-Reply-To: <1310520703.2634.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jul 2011 03:31:43 +0200

> If we cannot allocate new skbs in RX completion handler, we should
> increase netdevice rx_dropped counter, not spam console messages.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
> Note: This driver uses u64 fields without proper synch on 32bit arches.

Applied to net-next-2.6, thanks.
