From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: Kill unused tx_dropped
Date: Wed, 06 Jul 2011 01:51:30 -0700 (PDT)
Message-ID: <20110706.015130.1891031419074080114.davem@davemloft.net>
References: <20110705.234930.2282002049899864045.davem@davemloft.net>
	<1309940240.2292.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab1GFIvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 04:51:35 -0400
In-Reply-To: <1309940240.2292.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jul 2011 10:17:20 +0200

> Then we should also kill tx_dropped from percpu stats ?
> 
> Here is a patch on top of yours
> 
> [PATCH] veth: Kill unused tx_dropped
> 
> Followup to commit f82528bc13a (Exclude duplicated checking for
> iface-up) : We no longer need percpu tx_dropped field.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good to me, applied, thanks!
