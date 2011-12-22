From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Fix bug in ofo queue pruning MIB stats
Date: Wed, 21 Dec 2011 19:33:15 -0500 (EST)
Message-ID: <20111221.193315.2134174670572741208.davem@davemloft.net>
References: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab1LVAd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 19:33:59 -0500
In-Reply-To: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Wed, 21 Dec 2011 15:50:01 -0800

> Linux MIB LINUX_MIB_OFOPRUNED is supposed to count the number of packets
> dropped from the out-of-order queue due to socket buffer overrun. Instead
> of counting the number of skbs freed, it counts the number of calls make to
> __skb_queue_purge() which is not what the user (see f.e. netstat) is expecting.
> Fix this by  incrementing the counter correctly.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

I disagree, this is an event, and the counter is counting how many times
we prune the out of order queue, not how many packets we prune from that
queue.
