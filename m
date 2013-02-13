From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix smatch warnings in netpoll core code
Date: Wed, 13 Feb 2013 11:57:20 -0500 (EST)
Message-ID: <20130213.115720.1571411485926797138.davem@davemloft.net>
References: <1360773162-11949-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759808Ab3BMQ5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 11:57:22 -0500
In-Reply-To: <1360773162-11949-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 13 Feb 2013 11:32:42 -0500

> Dan Carpenter contacted me with some notes regarding some smatch warnings in the
> netpoll code, some of which I introduced with my recent netpoll locking fixes,
> some which were there prior.   Specifically they were:
> 
> net-next/net/core/netpoll.c:243 netpoll_poll_dev() warn: inconsistent
>   returns mutex:&ni->dev_lock: locked (213,217) unlocked (210,243)
> net-next/net/core/netpoll.c:706 netpoll_neigh_reply() warn: potential
>   pointer math issue ('skb_transport_header(send_skb)' is a 128 bit pointer)
> 
> This patch corrects the locking imbalance (the first error), and adds some
> parenthesis to correct the second error.  Tested by myself. Applies to net-next
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.

Again, please specify in the Subject line the destination tree.
