From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/6] 6lowpan: fix fragmentation on sending
 side
Date: Mon, 24 Feb 2014 20:31:38 -0500 (EST)
Message-ID: <20140224.203138.676703794377468037.davem@davemloft.net>
References: <1393009142-1694-3-git-send-email-alex.aring@gmail.com>
	<20140224.185213.1069306984692624378.davem@davemloft.net>
	<20140225012155.GA16712@omega>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbaBYBbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 20:31:39 -0500
In-Reply-To: <20140225012155.GA16712@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Tue, 25 Feb 2014 02:21:57 +0100

> In this case I can be sure we talking with ARPHRD_IEEE802154 devices only.

This doesn't mean anything.

The qdisc layer can be involved no matter what.  Once you call
dev_queue_xmit(), all bets are off wrt. the SKB control block.
It is not your's to use past that point.
